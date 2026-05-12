<#
.SYNOPSIS
    Agents deployed to Microsoft 365 Copilot are discoverable in the Agent Registry.

.DESCRIPTION
    Confirms that the tenant's Microsoft 365 Agent Registry returns at least one
    Copilot-hosted agent package. The Agent Registry is the tenant-scoped catalogue of
    every declarative agent, connected agent, and custom Copilot extension that has
    been published to users in the tenant. A populated Registry is the baseline
    control that makes every downstream agent-governance check possible.
#>

function Test-Assessment-61005 {
    [ZtTest(
        Category = 'AI Inventory & Lifecycle',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        MinimumLicense = ('Microsoft_365_Copilot'),
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

    $activity = 'Checking Microsoft 365 Agent Registry'
    Write-ZtProgress -Activity $activity -Status 'Listing Copilot-hosted agent packages in the tenant'

    $packages = @()
    $skipped = $false

    try {
        $packages = @(Invoke-ZtGraphRequest -RelativeUri 'copilot/admin/catalog/packages' -Filter "supportedHosts/any(h:h eq 'Copilot')" -ApiVersion beta)
    }
    catch {
        # The /beta/copilot/admin/catalog/packages endpoint is gated behind the
        # Microsoft 365 Copilot Frontier program. Tenants not enrolled receive 403/404,
        # and the check is marked Skipped rather than Fail.
        if ($_.Exception.Message -match '403|Forbidden|accessDenied|404|Request_ResourceNotFound|NotFound') {
            Write-PSFMessage "Agent Registry endpoint not available for this tenant: $_" -Level Warning
            $skipped = $true
        }
        else {
            throw
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    if ($skipped) {
        Add-ZtTestResultDetail -SkippedBecause NotSupported `
            -Result 'The Microsoft 365 Agent Registry endpoint (/beta/copilot/admin/catalog/packages) is not available in this tenant. This capability is gated behind the Microsoft 365 Copilot Frontier program, or the tenant''s Microsoft 365 environment is in a cloud where the Agent Registry is not yet available.'
        return
    }

    $passed = $packages.Count -ge 1
    #endregion Assessment Logic

    #region Report Generation
    if ($passed) {
        $testResultMarkdown = "✅ Agents deployed to Microsoft 365 Copilot are visible in the Agent Registry.`n`n"
    }
    else {
        $testResultMarkdown = "❌ No agents are visible in the Microsoft 365 Agent Registry.`n`n"
    }

    $packageLimit = 1000
    $packagesTruncated = $packages.Count -gt $packageLimit
    $packagesToDisplay = if ($packagesTruncated) { $packages | Select-Object -First $packageLimit } else { $packages }

    if ($packages.Count -gt 0) {
        $testResultMarkdown += "#### [Agents visible in the Microsoft 365 Agent Registry](https://admin.microsoft.com/#/copilot)`n`n"
        $testResultMarkdown += "| Display name | Element types | Available to | Deployed to |`n"
        $testResultMarkdown += "| :--- | :--- | :--- | :--- |`n"

        foreach ($pkg in $packagesToDisplay) {
            $displayName = if ($pkg.displayName) { Get-SafeMarkdown -Text $pkg.displayName } else { '(No name)' }

            $elementTypes = if ($pkg.elementTypes) { Get-SafeMarkdown -Text ($pkg.elementTypes -join ', ') } else { '' }

            $availableTo = if ($pkg.availableTo) {
                if ($pkg.availableTo -is [string]) { $pkg.availableTo }
                else { ($pkg.availableTo | ConvertTo-Json -Compress -Depth 5) }
            }
            else { '' }

            $deployedTo = if ($pkg.deployedTo) {
                if ($pkg.deployedTo -is [string]) { $pkg.deployedTo }
                else { ($pkg.deployedTo | ConvertTo-Json -Compress -Depth 5) }
            }
            else { '' }

            $testResultMarkdown += "| $displayName | $elementTypes | $(Get-SafeMarkdown -Text $availableTo) | $(Get-SafeMarkdown -Text $deployedTo) |`n"
        }

        if ($packagesTruncated) {
            $testResultMarkdown += "`n_Note: Only the first $packageLimit agents are shown._`n"
        }
    }
    #endregion Report Generation

    $params = @{
        TestId = '61005'
        Title  = 'Agents deployed to Microsoft 365 Copilot are discoverable in the Agent Registry'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
