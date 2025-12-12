<#
.SYNOPSIS
    Validates that all Private Network Connectors are active and healthy.

.DESCRIPTION
    This test checks if all Microsoft Entra Private Network Connectors in the tenant
    are active by checking their status via Microsoft Graph API.

.NOTES
    Test ID: 25391
    Category: Private Access
    Required API: onPremisesPublishingProfiles/applicationProxy/connectors (beta)
#>

function Test-Assessment-25391 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25391,
        Title = 'Private Access connectors are active and healthy',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Private Network Connector versions'
    Write-ZtProgress -Activity $activity -Status 'Getting connectors'

    # Query Q1: Get all private network connectors
    $connectors = Invoke-ZtGraphRequest -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectors' -ApiVersion beta
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $totalConnectors = $connectors.Count
    $activeConnectors = @()
    $inactiveConnectors = @()
    $allConnectors = @()
    #endregion Data Collection

    #region Assessment Logic
    if (-not $connectors -or $connectors.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "⚠️ No private network connectors found in this tenant. Configure connectors to enable Private Access."
        $allConnectors = @()  # Ensure empty array for report generation
    }
    else {
        # Step 2: Check for statuses
        Write-ZtProgress -Activity $activity -Status 'Checking connector statuses'

        foreach ($connector in $connectors) {
            $status = $connector.status
            $statusDisplay = if ($status -eq 'active') { '✅ Active' } else { '❌ Inactive' }

            $connectorInfo = [PSCustomObject]@{
                MachineName = $connector.machineName
                ExternalIp  = $connector.externalIp
                Version     = $connector.version
                Status      = $statusDisplay
            }

            if ($status -eq 'active') {
                $activeConnectors += $connectorInfo
            } else {
                $inactiveConnectors += $connectorInfo
            }
        }

        $allConnectors = $inactiveConnectors + $activeConnectors

        # Step 4: Determine pass/fail status
        if ($totalConnectors -eq $activeConnectors.Count) {
            $passed = $true
            $testResultMarkdown = "All Private Network Access connectors are active and healthy`n`n%TestResult%"
        } else {
            $testResultMarkdown = "One or more Private Network Access connectors are inactive or unhealthy`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if($allConnectors.Count -gt 0)
    {

    $formatTemplate = @"

## Private Access connectors status

| Machine name | Status | External ip | Version |
| :----------- | :------------ | :---------- | :------ |
{0}
"@

        $tableRows = ''
        foreach ($connector in ($allConnectors | Sort-Object @{Expression={if ($_.Status -eq '❌ Inactive') {0} else {1}}}, MachineName)) {
            $tableRows += "| $($connector.MachineName) | $($connector.Status) | $($connector.ExternalIp) | $($connector.Version) |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }


    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25391'
        Title  = 'Private Access connectors are active and healthy'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus for investigate when no connectors found
    if (-not $connectors -or $connectors.Count -eq 0) {
        $params.CustomStatus = 'Investigate'
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
