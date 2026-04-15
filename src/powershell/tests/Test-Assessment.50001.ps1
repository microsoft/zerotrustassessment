<#
.SYNOPSIS
    Queries Microsoft Defender for Cloud Secure Score recommendations and emits
    one test result per grouped recommendation.

.DESCRIPTION
    This test queries Azure Resource Graph for all MDC security assessments across
    accessible subscriptions, joined with secure score controls to get the control
    (category) for each recommendation. Assessments are grouped by
    recommendationDisplayName, and each group becomes one Infrastructure pillar
    test result with a resource table showing all affected resources.

    Status logic:
    - All NotApplicable → Skipped (with notApplicableReason)
    - Any Unhealthy → Failed
    - All Healthy → Passed

    The KQL query joins securescorecontrols with assessments to retrieve the
    controls column, description, severity, remediation steps, state, and
    Azure portal deep links.

.NOTES
    Test ID: 50001
    Category: Microsoft Defender for Cloud
    Required API: Azure Resource Graph - SecurityResources
        (microsoft.security/securescores/securescorecontrols + microsoft.security/assessments)
#>

function Test-Assessment-50001 {
    [ZtTest(
        Category = 'Microsoft Defender for Cloud',
        ImplementationCost = 'Low',
        MinimumLicense = ('N/A'),
        Pillar = 'Infrastructure',
        RiskLevel = 'High',
        Service = ('Azure'),
        SfiPillar = 'Protect infrastructure',
        TenantType = ('Workforce'),
        TestId = 50001,
        Title = 'Microsoft Defender for Cloud Secure Score Recommendations',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Defender for Cloud Secure Score Recommendations'

    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph for MDC assessments'

    # KQL query: joins securescorecontrols with assessments to get controls (category) per recommendation
    $argQuery = @'
securityresources
| where type == "microsoft.security/securescores/securescorecontrols"
| extend secureScoreName = (extract("/providers/Microsoft.Security/secureScores/([^/]*)/", 1, id))
| where secureScoreName == "ascScore"
| extend environment = (tostring(properties.environment))
| extend scope = (extract("(.*)/providers/Microsoft.Security/secureScores/", 1, id))
| where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
| extend controlDisplayName = (tostring(properties.displayName))
| extend controlName = (name)
| extend assessmentKeys = (extract_all("\"id\":\".*?/assessmentMetadata/([^\"]*)\"", tostring(properties.definition.properties.assessmentDefinitions)))
| extend notApplicableResourceCount = (toint(properties.notApplicableResourceCount))
| extend unhealthyResourceCount = (toint(properties.unhealthyResourceCount))
| extend healthyResourceCount = (toint(properties.healthyResourceCount))
| extend controlMaxScore = (toint(properties.score.max))
| extend currentScore = (todouble(properties.score.current))
    | join kind=leftouter (
    securityresources
    | where type == "microsoft.security/securescores"
    | where name == "ascScore"
    | extend environment = (tostring(properties.environment))
    | extend scopeMaxScore = (toint(properties.score.max))
    | extend scopeWeight = (toint(properties.weight))
    | parse id with scope "/providers/Microsoft.Security/secureScores" *
    | where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
    | project scope, scopeWeight, scopeMaxScore, joinOn = 1
    | join kind=leftouter (
        securityresources
        | where type == "microsoft.security/securescores"
        | where name == "ascScore"
        | extend environment = (tostring(properties.environment))
        | where (environment == "AWS" or environment == "Azure" or environment == "AzureDevOps" or environment == "DockerHub" or environment == "GCP" or environment == "GitHub" or environment == "GitLab" or environment == "JFrog")
        | extend scopeWeight = (toint(properties.weight))
        | project scopeWeight
        | summarize sumParentScopeWeight = todouble(sum(scopeWeight)), joinOn = 1
    ) on joinOn
    | project-away joinOn, joinOn1
    | project sumParentScopeWeight, scope, scopeWeight = todouble(scopeWeight), scopeMaxScore = todouble(scopeMaxScore)
) on scope
| extend scopeWeight = iff(controlMaxScore == 0, todouble(0), scopeWeight)
| summarize assessmentKeys = any(assessmentKeys),
            controlDisplayName = any(controlDisplayName),
            notApplicableResourceCount = sum(notApplicableResourceCount),
            unhealthyResourceCount = sum(unhealthyResourceCount),
            healthyResourceCount = sum(healthyResourceCount),
            controlMaxScore = max(controlMaxScore),
            sumParentScopeWeight = max(sumParentScopeWeight),
            impactRatio = sum(iff(scopeMaxScore == 0, todouble(0), scopeWeight / scopeMaxScore)),
            controlAggregatedCurrentScoreSum = sum(iff(scopeMaxScore == 0, todouble(0), scopeWeight * currentScore / scopeMaxScore)) by controlName
| extend controlAggregatedMaxScoreSum = impactRatio * controlMaxScore
| extend controlAggregatedCurrentScore = iff(controlAggregatedMaxScoreSum == 0, todouble(0), controlAggregatedCurrentScoreSum / controlAggregatedMaxScoreSum) * controlMaxScore
| extend potentialScoreIncrease = iff(sumParentScopeWeight == 0, todouble(0), (controlAggregatedMaxScoreSum - controlAggregatedCurrentScoreSum) / sumParentScopeWeight) * 100
| project controlsAssessmentsData = pack_all(), controlMaxScore
| extend assessmentKeys = controlsAssessmentsData.assessmentKeys
| extend controlData = pack(
    "controlDisplayName", controlsAssessmentsData.controlDisplayName,
    "controlName", controlsAssessmentsData.controlName,
    "assessmentKeys", controlsAssessmentsData.assessmentKeys,
    "notApplicableResourceCount", controlsAssessmentsData.notApplicableResourceCount,
    "unhealthyResourceCount", controlsAssessmentsData.unhealthyResourceCount,
    "healthyResourceCount", controlsAssessmentsData.healthyResourceCount,
    "totalResourceCount", toint(controlsAssessmentsData.notApplicableResourceCount) + toint(controlsAssessmentsData.unhealthyResourceCount) + toint(controlsAssessmentsData.healthyResourceCount),
    "maxScore", controlsAssessmentsData.controlMaxScore,
    "currentScore", controlsAssessmentsData.controlAggregatedCurrentScore,
    "potentialScoreIncrease", controlsAssessmentsData.potentialScoreIncrease)
| mv-expand assessmentKeys limit 400
| project assessmentKey = tostring(assessmentKeys), controlData
| summarize controlsData = make_set(controlData) by assessmentKey
| join kind=inner (
    securityresources
    | where type == "microsoft.security/assessments"
    | extend assessmentDetails = parse_json(properties)
    | extend resourceDetails = parse_json(assessmentDetails.resourceDetails)
    | extend fullResourceType = tostring(resourceDetails.ResourceType)
    | extend resourceType = tostring(split(fullResourceType, '/')[1])
    | extend exportedTimestamp = now()
    | extend recommendationId = id
    | extend recommendationName = tostring(split(id, '/')[array_length(split(id, '/')) - 1])
    | extend azurePortalRecommendationLink = case(
        tostring(assessmentDetails.links.azurePortal) startswith "https://", tostring(assessmentDetails.links.azurePortal),
        strcat("https://", tostring(assessmentDetails.links.azurePortal))
    )
) on $left.assessmentKey == $right.recommendationName
| project
    exportedTimestamp,
    subscriptionId,
    resourceGroup,
    resourceType,
    resourceName = tostring(resourceDetails.ResourceName),
    displayName = tostring(assessmentDetails.displayName),
    state = tostring(assessmentDetails.status.code),
    severity = tostring(assessmentDetails.metadata.severity),
    remediationSteps = tostring(assessmentDetails.metadata.remediationDescription),
    resourceId = tostring(resourceDetails.ResourceId),
    recommendationName,
    controls = controlsData,
    description = tostring(assessmentDetails.metadata.description),
    recommendationDisplayName = tostring(assessmentDetails.metadata.displayName),
    notApplicableReason = tostring(assessmentDetails.status.cause),
    firstEvaluationDate = todatetime(assessmentDetails.status.firstEvaluationDate),
    statusChangeDate = todatetime(assessmentDetails.status.statusChangeDate),
    azurePortalRecommendationLink,
    nativeCloudAccountId = tostring(resourceDetails.NativeResourceId),
    tactics = tostring(assessmentDetails.metadata.tactics[0]),
    techniques = tostring(assessmentDetails.metadata.techniques[0]),
    cloud = tostring(assessmentDetails.metadata.cloudProviders[0]),
    owner = tostring(assessmentDetails.owner),
    recommendationId
| join kind=leftouter (
    resourcecontainers
    | where type == "microsoft.resources/subscriptions"
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project
    exportedTimestamp,
    subscriptionId,
    subscriptionName,
    resourceGroup,
    resourceType,
    resourceName,
    resourceId,
    recommendationId,
    recommendationName,
    description,
    recommendationDisplayName,
    remediationSteps,
    severity,
    state,
    notApplicableReason,
    firstEvaluationDate,
    statusChangeDate,
    controls = coalesce(tostring(parse_json(controls)[0].controlDisplayName), "No Value"),
    azurePortalRecommendationLink,
    nativeCloudAccountId,
    tactics,
    techniques,
    cloud,
    owner
| order by recommendationDisplayName asc
'@

    $assessments = @()
    try {
        $assessments = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($assessments.Count) assessment records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($assessments.Count -eq 0) {
        Write-PSFMessage 'No MDC assessments found. Cloud Security Posture Management enabled.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Microsoft Defender for Cloud assessments found. Ensure Cloud Security Posture Management is enabled on your subscriptions.'
        return
    }

    # Group assessments by recommendation display name
    $groups = $assessments | Group-Object -Property recommendationDisplayName
    $testIdCounter = 50001

    foreach ($group in $groups) {
        $rows = $group.Group
        $firstRow = $rows[0]

        # Title from recommendationDisplayName
        $title = $group.Name

        # Category from controls column
        $category = $firstRow.controls

        # Risk from severity
        $risk = $firstRow.severity

        # --- Build Description ("What was checked") — shared by both skip and normal paths ---
        $descriptionText = ConvertTo-ZtMarkdown $firstRow.description
        if ([string]::IsNullOrWhiteSpace($descriptionText)) {
            $descriptionText = $firstRow.displayName
        }

        $remediationSection = ''
        if (-not [string]::IsNullOrWhiteSpace($firstRow.remediationSteps)) {
            $cleanRemediation = ConvertTo-ZtMarkdown $firstRow.remediationSteps

            $remediationSection = @"

**Remediation action**

$cleanRemediation
"@
        }

        $portalRefSection = ''
        if (-not [string]::IsNullOrWhiteSpace($firstRow.azurePortalRecommendationLink)) {
            $portalRefSection = @"

[View recommendation in Azure Portal]($($firstRow.azurePortalRecommendationLink))
"@
        }

        $descriptionMd = @"
$descriptionText
$remediationSection
"@

        # Separate rows by state
        $applicableRows = @($rows | Where-Object { $_.state -ne 'NotApplicable' })
        $notApplicableRows = @($rows | Where-Object { $_.state -eq 'NotApplicable' })

        # If all rows are NotApplicable → Skip
        if ($applicableRows.Count -eq 0) {
            $naReasons = ($notApplicableRows | ForEach-Object { $_.notApplicableReason } | Where-Object { $_ } | Select-Object -Unique) -join '; '
            if ([string]::IsNullOrWhiteSpace($naReasons)) { $naReasons = 'All resources are not applicable for this recommendation.' }

            $params = @{
                TestId         = "$testIdCounter"
                Title          = $title
                Description    = $descriptionMd
                SkippedBecause = 'NotApplicable'
                Result         = $naReasons
                Pillar         = 'Infrastructure'
                Category       = $category
                Risk           = $risk
            }
            Add-ZtTestResultDetail @params
            $testIdCounter++
            continue
        }

        # Any Unhealthy → Failed; all Healthy → Passed
        $hasUnhealthy = @($applicableRows | Where-Object { $_.state -eq 'Unhealthy' }).Count -gt 0
        $passed = -not $hasUnhealthy

        # --- Build Result ("Test result") ---
        # Resource table with clickable links (exclude NotApplicable rows)

        $tableRows = ''
        foreach ($row in $applicableRows | Sort-Object subscriptionName, resourceGroup, resourceName) {
            $subLink = "https://portal.azure.com/#resource/subscriptions/$($row.subscriptionId)"
            $subMd = "[$(Get-SafeMarkdown $row.subscriptionName)]($subLink)"

            $rgSafe = $row.resourceGroup
            $typeSafe = $row.resourceType

            $resLink = "https://portal.azure.com/#resource$($row.resourceId)"
            $resMd = "[$(Get-SafeMarkdown $row.resourceName)]($resLink)"

            $stateIcon = if ($row.state -eq 'Healthy') { '✅' } else { '❌' }

            $tableRows += "| $subMd | $rgSafe | $typeSafe | $resMd | $stateIcon |`n"
        }

        $resultMd = @"
$title

| Subscription | Resource Group | Resource Type | Resource | Status |
| :----------- | :------------- | :------------ | :------- | :----- |
$tableRows
$portalRefSection
"@

        $params = @{
            TestId             = "$testIdCounter"
            Title              = $title
            Status             = $passed
            Result             = $resultMd
            Description        = $descriptionMd
            Risk               = $risk
            Pillar             = 'Infrastructure'
            Category           = $category
        }

        Add-ZtTestResultDetail @params
        $testIdCounter++
    }
    #endregion Assessment Logic

    Write-PSFMessage "Emitted $($groups.Count) grouped MDC assessment test results (TestIds 50001-$($testIdCounter - 1))" -Tag Test -Level VeryVerbose
}
