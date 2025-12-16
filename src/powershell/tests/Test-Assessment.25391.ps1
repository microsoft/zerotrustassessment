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
        UserImpact = 'Medium'
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
    $allConnectors = @()
    #endregion Data Collection

    #region Assessment Logic
    if (-not $connectors -or $connectors.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "⚠️ No private network connectors found in this tenant. Configure connectors to enable Private Access."
    }
    else {
        # Step 2: Check for statuses
        Write-ZtProgress -Activity $activity -Status 'Checking connector statuses'

        # Transform connectors to result objects with status display
        $allConnectors = $connectors | ForEach-Object {
            [PSCustomObject]@{
                MachineName = $_.machineName
                ExternalIp  = $_.externalIp
                Version     = $_.version
                Status      = if ($_.status -eq 'active') { '✅ Active' } else { '❌ Inactive' }
                IsActive    = $_.status -eq 'active'
            }
        }

        # Determine pass/fail - all connectors must be active
        $passed = ($allConnectors | Where-Object { -not $_.IsActive }).Count -eq 0

        $testResultMarkdown = if ($passed) {
            "All Private Network Access connectors are active and healthy`n`n%TestResult%"
        } else {
            "One or more Private Network Access connectors are inactive or unhealthy`n`n%TestResult%"
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
        foreach ($connector in ($allConnectors | Sort-Object IsActive, MachineName)) {
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
