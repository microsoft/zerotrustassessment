<#
.SYNOPSIS
    Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management

.DESCRIPTION
    Discovers Microsoft Security Copilot capacity resources via Azure Resource Graph, then for each
    subscription that hosts a capacity confirms that at least one Consumption budget with qualifying
    notifications targets the capacity, its resource group, or the subscription.

.NOTES
    Test ID: 41216
    Workshop Task: SECOPS_111
    Pillar: SecOps
    Category: AI for security
    Required APIs:
        - Azure Resource Graph (management.azure.com) — capacity discovery
        - Consumption Budgets - List (Microsoft.Consumption/budgets) — subscription scope
#>

function Test-Assessment-41216 {
    [ZtTest(
        Category = 'AI for security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Security Copilot'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41216,
        Title = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Security Copilot SCU consumption monitoring'
    $capacityType = 'microsoft.securitycopilot/capacities'

    # Discovery: enumerate Security Copilot capacity resources across all accessible subscriptions via
    # Azure Resource Graph. This check is self-contained and does not depend on any other spec's output.
    Write-ZtProgress -Activity $activity -Status 'Discovering Security Copilot capacities via Resource Graph'

    $argQuery = @"
resources
| where type =~ '$capacityType'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where properties.state =~ 'Enabled'
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project id, name, location, resourceGroup, subscriptionId, subscriptionName, tags, provisioningState = tostring(properties.provisioningState)
"@

    $capacities = @()
    try {
        $capacities = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG query returned $($capacities.Count) Security Copilot capacity resource(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        # Invoke-ZtAzureResourceGraphRequest throws "Azure REST request failed with status <code>: ..."
        $httpStatus = $null
        if ($_.Exception.Message -match 'with status (\d+):') { $httpStatus = [int]$Matches[1] }
        $result = if ($httpStatus -in @(401, 403)) {
            '⚠️ Azure Resource Graph returned an authorization error while discovering Security Copilot capacities. Grant the assessing identity at least Reader on the subscriptions being evaluated, then re-run the assessment.'
        }
        else {
            '⚠️ Azure Resource Graph returned an unexpected error while discovering Security Copilot capacities. This is likely transient; re-run the assessment.'
        }
        $params = @{
            TestId       = '41216'
            Title        = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management'
            Status       = $false
            Result       = $result
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Spec: no capacity resources in the tenant -> Skipped (NotApplicable).
    if ($capacities.Count -eq 0) {
        Write-PSFMessage 'No Security Copilot capacity resources found — skipping.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q1: for each subscription that hosts a capacity, list the Consumption budgets.
    $subscriptionIds = @($capacities | Select-Object -ExpandProperty subscriptionId -Unique)
    $subscriptionData = @{}

    foreach ($subscriptionId in $subscriptionIds) {
        $subEntry = [PSCustomObject]@{
            Budgets         = @()
            BudgetAuthError = $false
            BudgetFailed    = $false
        }

        # Q1: Consumption Budgets - List (GET). Invoke-ZtAzureRequest auto-paginates and unwraps .value.
        Write-ZtProgress -Activity $activity -Status "Querying Consumption budgets for subscription $subscriptionId"
        $budgetsPath = "/subscriptions/$subscriptionId/providers/Microsoft.Consumption/budgets?api-version=2024-08-01"
        try {
            $subEntry.Budgets = @(Invoke-ZtAzureRequest -Path $budgetsPath -ErrorAction Stop)
        }
        catch {
            Write-PSFMessage "Consumption budgets query failed for subscription '$subscriptionId': $($_.Exception.Message)" -Tag Test -Level Warning
            if ($_.Exception.Message -match 'with status (\d+):' -and [int]$Matches[1] -in @(401, 403)) {
                $subEntry.BudgetAuthError = $true
            }
            else {
                $subEntry.BudgetFailed = $true
            }
        }

        $subscriptionData[$subscriptionId] = $subEntry
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $nowUtc = (Get-Date).ToUniversalTime()

    # Pre-classify each subscription's budgets: which ones have a qualifying notification (enabled,
    # threshold <= 90, GreaterThan[OrEqualTo], with at least one email/role/group recipient) and what
    # scope they target (explicit ResourceIds, resource groups, the capacity type, or the whole
    # subscription when unfiltered).
    foreach ($subscriptionId in $subscriptionData.Keys) {
        $budgetInfos = @()
        foreach ($budget in $subscriptionData[$subscriptionId].Budgets) {
            $qualifyingThresholds = [System.Collections.Generic.List[double]]::new()

            # A budget only alerts while now falls within its timePeriod; an expired or not-yet-started
            # budget cannot fire, so its notifications must not qualify (spec Q1: "active" budget).
            $budgetActive = $true
            $parsedBudgetDate = [datetime]::MinValue
            if ($budget.properties.timePeriod.startDate -and [datetime]::TryParse([string]$budget.properties.timePeriod.startDate, [ref]$parsedBudgetDate)) {
                if ($parsedBudgetDate.ToUniversalTime() -gt $nowUtc) { $budgetActive = $false }
            }
            if ($budget.properties.timePeriod.endDate -and [datetime]::TryParse([string]$budget.properties.timePeriod.endDate, [ref]$parsedBudgetDate)) {
                if ($parsedBudgetDate.ToUniversalTime() -lt $nowUtc) { $budgetActive = $false }
            }

            $notifications = $budget.properties.notifications
            $notificationEntries = if ($notifications) { @($notifications.PSObject.Properties) } else { @() }
            foreach ($notificationProperty in $notificationEntries) {
                $notification = $notificationProperty.Value
                $enabled = $notification.enabled -eq $true
                $operatorOk = $notification.operator -in @('GreaterThan', 'GreaterThanOrEqualTo')
                $threshold = 0.0
                $thresholdParsed = [double]::TryParse([string]$notification.threshold, [ref]$threshold)
                $hasRecipient = (@($notification.contactEmails).Count -gt 0) -or (@($notification.contactRoles).Count -gt 0) -or (@($notification.contactGroups).Count -gt 0)
                if ($budgetActive -and $enabled -and $operatorOk -and $thresholdParsed -and $threshold -le 90 -and $hasRecipient) {
                    $qualifyingThresholds.Add($threshold)
                }
            }

            # Collect the budget's filter clauses. A budget with no filter is subscription-scoped
            # (covers every resource, including the capacity). Otherwise the filter is a single
            # `dimensions`/`tags` clause or an `and` of clauses; Cost Management evaluates `and`
            # conjunctively, so ALL clauses (dimension and tag) must match a capacity for the budget to
            # apply. Each clause is kept with its kind so tags can be evaluated against the capacity tags.
            $filter = $budget.properties.filter
            $hasFilter = $null -ne $filter -and $filter.PSObject.Properties.Count -gt 0
            $filterClauses = @()
            if ($filter.dimensions) { $filterClauses += [PSCustomObject]@{ Kind = 'Dimension'; Clause = $filter.dimensions } }
            if ($filter.tags) { $filterClauses += [PSCustomObject]@{ Kind = 'Tag'; Clause = $filter.tags } }
            if ($filter.and) {
                foreach ($clause in $filter.and) {
                    if ($clause.dimensions) { $filterClauses += [PSCustomObject]@{ Kind = 'Dimension'; Clause = $clause.dimensions } }
                    if ($clause.tags) { $filterClauses += [PSCustomObject]@{ Kind = 'Tag'; Clause = $clause.tags } }
                }
            }

            $budgetInfos += [PSCustomObject]@{
                Name                 = $budget.name
                Amount               = $budget.properties.amount
                Unit                 = $budget.properties.currentSpend.unit
                TimeGrain            = $budget.properties.timeGrain
                QualifyingThresholds = @($qualifyingThresholds | Sort-Object -Unique)
                TargetsSubscription  = -not $hasFilter
                FilterClauses        = $filterClauses
            }
        }
        $subscriptionData[$subscriptionId] | Add-Member -NotePropertyName BudgetInfos -NotePropertyValue $budgetInfos -Force
    }

    # Evaluate each discovered capacity.
    $results = foreach ($capacity in $capacities) {
        $subEntry = $subscriptionData[$capacity.subscriptionId]

        $budgetName = $null
        $budgetAmount = $null
        $budgetUnit = $null
        $timeGrain = $null
        $thresholds = $null

        $budgetBlocked = $subEntry.BudgetAuthError -or $subEntry.BudgetFailed

        # Find the first qualifying budget in the capacity's subscription that targets this capacity.
        # A subscription-scoped (unfiltered) budget always covers it; a filtered budget covers it only
        # when EVERY clause matches (AND). Dimension clauses match on ResourceId/ResourceGroupName/
        # ResourceType; tag clauses match when the capacity carries the tag with a listed value. A
        # clause on a dimension we cannot evaluate fails the match rather than being ignored.
        $matchingBudget = $null
        if (-not $budgetBlocked) {
            foreach ($budgetInfo in $subEntry.BudgetInfos) {
                if ($budgetInfo.QualifyingThresholds.Count -eq 0) { continue }

                if ($budgetInfo.TargetsSubscription) { $matchingBudget = $budgetInfo; break }

                # A filtered budget must expose at least one clause and every clause must include the capacity.
                if ($budgetInfo.FilterClauses.Count -eq 0) { continue }

                $allClausesMatch = $true
                foreach ($filterClause in $budgetInfo.FilterClauses) {
                    $clause = $filterClause.Clause
                    $clauseValues = @($clause.values)
                    if ($filterClause.Kind -eq 'Tag') {
                        # Tag key match is case-insensitive; value comparison via -contains is case-insensitive.
                        $capacityTagValue = $null
                        if ($capacity.tags) {
                            $tagProperty = $capacity.tags.PSObject.Properties | Where-Object { $_.Name -ieq $clause.name } | Select-Object -First 1
                            if ($tagProperty) { $capacityTagValue = [string]$tagProperty.Value }
                        }
                        $clauseMatch = $null -ne $capacityTagValue -and ($clauseValues -contains $capacityTagValue)
                    }
                    else {
                        $clauseMatch = switch ($clause.name) {
                            'ResourceId'        { $clauseValues -contains $capacity.id }
                            'ResourceGroupName' { $clauseValues -contains $capacity.resourceGroup }
                            'ResourceType'      { $clauseValues -contains $capacityType }
                            default             { $false }
                        }
                    }
                    if (-not $clauseMatch) { $allClausesMatch = $false; break }
                }
                if ($allClausesMatch) { $matchingBudget = $budgetInfo; break }
            }
        }

        if ($matchingBudget) {
            $budgetName = $matchingBudget.Name
            $budgetAmount = $matchingBudget.Amount
            $budgetUnit = $matchingBudget.Unit
            $timeGrain = $matchingBudget.TimeGrain
            $thresholds = ($matchingBudget.QualifyingThresholds | ForEach-Object { "$_%" }) -join ', '
        }

        $rowResult =
            if ($budgetBlocked) { '⚠️ Investigate' }
            elseif ($matchingBudget) { '✅ Pass' }
            else { '❌ Fail' }

        [PSCustomObject]@{
            Name              = $capacity.name
            Id                = $capacity.id
            ResourceGroup     = $capacity.resourceGroup
            SubscriptionId    = $capacity.subscriptionId
            SubscriptionName  = $capacity.subscriptionName
            ProvisioningState = $capacity.provisioningState
            BudgetName        = $budgetName
            BudgetAmount      = $budgetAmount
            BudgetUnit        = $budgetUnit
            TimeGrain         = $timeGrain
            Thresholds        = $thresholds
            Blocked           = $budgetBlocked
            RowResult         = $rowResult
        }
    }

    # Aggregate across every discovered capacity with fail > investigate > pass precedence; pass only
    # when every capacity is covered by a qualifying budget. A single passing capacity must not mask
    # another that is unmonitored (Fail) or whose budgets could not be read (Investigate). The spec
    # defines Skipped only when discovery returns no capacity, so every returned capacity is evaluated.
    $failRows = @($results | Where-Object { $_.RowResult -eq '❌ Fail' })
    $passRows = @($results | Where-Object { $_.RowResult -eq '✅ Pass' })
    $investigateRows = @($results | Where-Object { $_.RowResult -eq '⚠️ Investigate' })

    if ($failRows.Count -gt 0) {
        # Fail wins: at least one capacity has no qualifying budget targeting it.
        $testResultMarkdown = "❌ One or more Security Copilot capacities have no Cost Management budget with qualifying notifications (enabled, threshold ≤ 90%, with an email, role, or action-group recipient) targeting the capacity, its resource group, or the subscription.`n`n%TestResult%"
    }
    elseif ($passRows.Count -gt 0 -and $investigateRows.Count -eq 0) {
        # Every capacity is covered by a qualifying budget.
        $passed = $true
        $testResultMarkdown = "✅ Every Microsoft Security Copilot (provisioned/overage) capacity is covered by a Cost Management budget with alert notifications, so SCU spend is monitored and alerted on before the cap.`n`n%TestResult%"
    }
    else {
        # No fail and not all-pass: budgets could not be read for one or more hosting subscriptions.
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Cost Management budgets could not be read for the subscription(s) that host a Security Copilot capacity. Grant the assessing identity Cost Management Reader (or Reader) on those subscriptions, then re-run the assessment.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $budgetsPortalUrl = 'https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/budgets'

    $tableRows = ''
    foreach ($item in $results | Sort-Object Name) {
        $nameLink = "[$(Get-SafeMarkdown $item.Name)](https://portal.azure.com/#resource$($item.Id))"
        $subscriptionDisplay = if (-not [string]::IsNullOrWhiteSpace($item.SubscriptionName)) { Get-SafeMarkdown $item.SubscriptionName } else { $item.SubscriptionId }

        $budgetDisplay = if ($item.BudgetName) { Get-SafeMarkdown $item.BudgetName } elseif ($item.RowResult -eq '❌ Fail') { 'No qualifying budget' } else { '—' }
        $amountDisplay = if ($null -eq $item.BudgetAmount) { '—' } elseif ($item.BudgetUnit) { '{0:N2} {1}' -f $item.BudgetAmount, $item.BudgetUnit } else { '{0:N2}' -f $item.BudgetAmount }
        $timeGrainDisplay = if ($item.TimeGrain) { $item.TimeGrain } else { '—' }
        $thresholdDisplay = if ($item.Thresholds) { $item.Thresholds } else { '—' }

        $tableRows += "| $nameLink | $subscriptionDisplay | $budgetDisplay | $amountDisplay | $timeGrainDisplay | $thresholdDisplay | $($item.RowResult) |`n"
    }

    $formatTemplate = @'


## [Security Copilot capacity budgets]({0})

| Capacity | Subscription | Budget | Amount | Time grain | Alert thresholds | Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{1}

'@

    $mdInfo = $formatTemplate -f $budgetsPortalUrl, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41216'
        Title  = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
