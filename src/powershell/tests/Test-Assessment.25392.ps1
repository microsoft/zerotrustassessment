<#
.SYNOPSIS
    Validates that all Private Network Connectors are running the latest version.

.DESCRIPTION
    This test checks if all Microsoft Entra Private Network Connectors in the tenant
    are running the latest version by comparing installed versions against the
    latest release from Microsoft documentation.

.NOTES
    Test ID: 25392
    Category: Private Access
    Required API: onPremisesPublishingProfiles/applicationProxy/connectors (beta)
#>

function Test-Assessment-25392 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25392,
        Title = 'Private Access Connectors are running the latest version',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-LatestConnectorVersion {
        <#
        .SYNOPSIS
            Gets the latest Microsoft Entra Private Network Connector version from documentation.
        .OUTPUTS
            System.String - The latest version number (e.g., "1.5.4522.0") or $null if retrieval fails.
        #>
        $url = "https://raw.githubusercontent.com/MicrosoftDocs/entra-docs/refs/heads/main/docs/global-secure-access/reference-version-history.md"

        try {
            $content = Invoke-RestMethod -Uri $url -ErrorAction Stop

            if ($content -match '## Version (\d+\.\d+\.\d+\.\d+)') {
                return $matches[1]
            }
            else {
                Write-PSFMessage "Could not parse version from documentation" -Level Warning
                return $null
            }
        }
        catch {
            Write-PSFMessage "Failed to fetch connector version: $_" -Level Warning
            return $null
        }
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Private Network Connector versions'
    Write-ZtProgress -Activity $activity -Status 'Getting connectors'

    # Query Q1: Get all private network connectors
    $connectors = Invoke-ZtGraphRequest -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectors' -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $outdatedConnectors = @()
    $upToDateConnectors = @()
    $latestVersion = $null

    # Step 1: Check if any connectors exist
    if ($connectors -and $connectors.Count -gt 0) {
        # Step 2: Get the latest version from documentation
        Write-ZtProgress -Activity $activity -Status 'Getting latest version from documentation'
        $latestVersion = Get-LatestConnectorVersion
    }
    #endregion Data Collection

    #region Assessment Logic
    if (-not $connectors -or $connectors.Count -eq 0) {
        $testResultMarkdown = "ℹ️ No private network connectors found in this tenant.`n`n%TestResult%"
        $passed = $true  # No connectors means nothing to check - pass by default
    }
    elseif (-not $latestVersion) {
        $testResultMarkdown = "⚠️ Could not retrieve the latest connector version from documentation. Manual verification required.`n`n%TestResult%"
        $passed = $false # Fail if we can't verify
    }
    else {
        # Step 3: Compare versions
        Write-ZtProgress -Activity $activity -Status 'Comparing connector versions'

        foreach ($connector in $connectors) {
            $connectorVersion = $connector.version
            # Use -ge to account for preview versions or documentation lag
            $isUpToDate = [version]$connectorVersion -ge [version]$latestVersion

            $connectorInfo = [PSCustomObject]@{
                Id          = $connector.id
                MachineName = $connector.machineName
                Version     = $connectorVersion
                IsUpToDate  = $isUpToDate
            }

            if ($isUpToDate) {
                $upToDateConnectors += $connectorInfo
            }
            else {
                $outdatedConnectors += $connectorInfo
            }
        }

        # Step 4: Determine pass/fail status
        if ($outdatedConnectors.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ All private network connectors are running the latest version ($latestVersion).`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ At least one private network connector is not running the latest version ($latestVersion).`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($connectors -and $connectors.Count -gt 0 -and $latestVersion) {
        $reportTitle = "Connector version assessment"
        $tableRows = ""

        $mdInfo += "`n## $reportTitle`n`n"
        $mdInfo += "**Latest available version**: $latestVersion`n`n"
        $mdInfo += "**Total connectors**: $($connectors.Count)`n"
        $mdInfo += "**Up to date**: $($upToDateConnectors.Count)`n"
        $mdInfo += "**Outdated**: $($outdatedConnectors.Count)`n`n"

        # Show outdated connectors first (if any)
        if ($outdatedConnectors.Count -gt 0) {
            $formatTemplate = @'
### ❌ Outdated connectors

| ID | Machine Name | Current Version |
| :-- | :----------- | :-------------- |
{0}

'@
            foreach ($connector in ($outdatedConnectors | Sort-Object -Property MachineName)) {
                $tableRows += "| $($connector.Id) | $(Get-SafeMarkdown $connector.MachineName) | $($connector.Version) |`n"
            }
            $mdInfo += $formatTemplate -f $tableRows
        }

        # Show up-to-date connectors
        if ($upToDateConnectors.Count -gt 0) {
            $tableRows = ""
            $formatTemplate = @'
### ✅ Up-to-date connectors

| ID | Machine Name | Current Version |
| :-- | :----------- | :-------------- |
{0}

'@
            foreach ($connector in ($upToDateConnectors | Sort-Object -Property MachineName)) {
                $tableRows += "| $($connector.Id) | $(Get-SafeMarkdown $connector.MachineName) | $($connector.Version) |`n"
            }
            $mdInfo += $formatTemplate -f $tableRows
        }
    }
    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25392'
        Title  = 'Private Access Connectors are running the latest version'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params

}
