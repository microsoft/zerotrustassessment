<#
.SYNOPSIS
    Agents deployed to Microsoft 365 Copilot are discoverable in the Agent Registry.

.DESCRIPTION
    The Microsoft 365 Agent Registry is the tenant-scoped catalogue that lists every declarative agent,
    connected agent, and custom Copilot extension published to users in the tenant. This check verifies
    that at least one agent is visible in the registry, confirming the registry is populated and providing
    the baseline visibility required for all downstream agent-governance controls.

.NOTES
    Test ID: 61005
    Category: AI Inventory & Lifecycle
    Pillar: AI
    Required Permission: AgentPackage.Read.All (Delegated)
#>

function Test-Assessment-61005 {
    [ZtTest(
        Category = 'AI Inventory & Lifecycle',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        CompatibleLicense = ('AGENT_365'), # to be updated based on confirmation of license requirements
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 61005,
        Title = 'Agents deployed to Microsoft 365 Copilot are discoverable in the Agent Registry',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking agents in the Microsoft 365 Agent Registry'

    # Q1: List Copilot-hosted agent packages in the tenant
    Write-ZtProgress -Activity $activity -Status 'Retrieving Copilot agent packages from the Agent Registry'

    $agentPackages = $null
    $errorMsg = $null
    $httpStatusCode = $null

    try {
        $agentPackages = Invoke-ZtGraphRequest -RelativeUri 'copilot/admin/catalog/packages' -Filter "supportedHosts/any(h:h eq 'Copilot')" -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve Copilot agent packages: $errorMsg" -Level Warning

        if ($errorMsg.Exception.Response.StatusCode) {
            $httpStatusCode = [int]$errorMsg.Exception.Response.StatusCode.value__
        }
        elseif ($errorMsg.Exception.Message -match '(403|404)') {
            $httpStatusCode = [int]$Matches[1]
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    if ($errorMsg) {
        # 403/404 → tenant not enrolled in Frontier preview or Agent 365 license not activated
        if ($httpStatusCode -in @(403, 404)) {
            Write-PSFMessage "Agent Registry not accessible (HTTP $httpStatusCode) - tenant may not be enrolled in the required Frontier preview or lacks an Agent 365 license" -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable `
                -Result 'The tenant is not enrolled in the Microsoft 365 Copilot Frontier preview, or an Agent 365 trial or production license is not activated within the tenant, or the Microsoft 365 environment is in a cloud where the Agent Registry is not yet available.'
            return
        }

        # Other errors
        Write-PSFMessage "Unexpected error retrieving the Agent Registry (HTTP $httpStatusCode)" -Level Error
        $passed = $false
    }
    elseif (-not $agentPackages -or $agentPackages.Count -eq 0) {
        # HTTP 200 with empty value array — no agents registered
        $passed = $false
    }
    else {
        # HTTP 200 with one or more agents
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "❌ Unable to retrieve agent packages from the Microsoft 365 Agent Registry.`n`nError: $errorMsg"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Agents deployed to Microsoft 365 Copilot are visible in the Agent Registry.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No agents are visible in the Microsoft 365 Agent Registry.`n`n%TestResult%"
    }

    $mdInfo = ''

    if ($agentPackages -and $agentPackages.Count -gt 0) {
        $portalLink = 'https://admin.microsoft.com/#/copilot'
        $totalCount = $agentPackages.Count

        $formatTemplate = @'

## [Agents visible in the Microsoft 365 Agent Registry]({0})

| Display name | Element types | Available to | Deployed to |
| :----------- | :------------ | :----------- | :---------- |
{1}
'@

        $tableRows = ''
        foreach ($package in ($agentPackages | Select-Object -First 10)) {
            $displayName = Get-SafeMarkdown -Text $package.displayName

            $elementTypes = Get-SafeMarkdown -Text (if ($package.elementTypes) {
                ($package.elementTypes | Sort-Object) -join ', '
            }
            else { 'N/A' })

            $availableTo = Get-SafeMarkdown -Text (if ($package.availableTo) {
                ($package.availableTo | ForEach-Object {
                    if ($_ -is [string])     { $_ }
                    elseif ($_.displayName)  { $_.displayName }
                    elseif ($_.type)         { $_.type }
                    elseif ($_.id)           { $_.id }
                    else                     { 'unknown' }
                }) -join ', '
            }
            else { 'N/A' })

            $deployedTo = Get-SafeMarkdown -Text (if ($package.deployedTo) {
                ($package.deployedTo | ForEach-Object {
                    if ($_ -is [string])     { $_ }
                    elseif ($_.displayName)  { $_.displayName }
                    elseif ($_.type)         { $_.type }
                    elseif ($_.id)           { $_.id }
                    else                     { 'unknown' }
                }) -join ', '
            }
            else { 'N/A' })

            $tableRows += "| $displayName | $elementTypes | $availableTo | $deployedTo |`n"
        }

        $mdInfo = $formatTemplate -f $portalLink, $tableRows
        if ($totalCount -gt 10) {
            $mdInfo += "`n`n_**Note**: This table is truncated and showing the first 10 of $totalCount agents._`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61005'
        Title  = 'Agents deployed to Microsoft 365 Copilot are discoverable in the Agent Registry'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
