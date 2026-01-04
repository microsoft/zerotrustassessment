<#
.SYNOPSIS
    Sensitivity Labels Enabled in SharePoint Online

.DESCRIPTION
    SharePoint Online and OneDrive for Business require explicit enablement of sensitivity label integration to allow users to apply Microsoft Information Protection labels to files stored in these services. When EnableAIPIntegration is disabled, organizations lose the ability to classify and protect documents at rest in their primary collaboration platform. The contant is opaque to SharePoint capabilities and Purview services like eDiscovery is not available.

.NOTES
    Test ID: 35005
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35005 {
    [ZtTest(
        Category = 'SharePoint Online',
        ImplementationCost = 'Low',
        MinimumLicense = ('MIP_P1'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35005,
        Title = 'Sensitivity Labels Enabled in SharePoint Online',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Sensitivity Labels in SharePoint Online'
    Write-ZtProgress -Activity $activity -Status 'Getting SharePoint Tenant Settings'

    $spoTenant = $null
    $errorMsg = $null

    try {
        # Query: Retrieve SharePoint Online tenant sensitivity label integration status
        $spoTenant = Get-SPOTenant -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying SharePoint Tenant Settings: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
    }
    else {
        if ($null -ne $spoTenant -and $spoTenant.EnableAIPIntegration -eq $true) {
            $passed = $true
        }
        else {
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query SharePoint Tenant Settings due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Sensitivity labels are enabled in SharePoint Online and OneDrive, allowing users to classify and protect documents stored in these services.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Sensitivity labels are NOT enabled in SharePoint Online and OneDrive. Documents cannot be labeled or protected with encryption/access controls.`n`n"
        }

        $testResultMarkdown += "### SharePoint Online Configuration Summary`n`n"
        $testResultMarkdown += "**Tenant Settings:**`n"

        $enableAIPIntegration = if ($spoTenant.EnableAIPIntegration) { "True" } else { "False" }
        $testResultMarkdown += "* EnableAIPIntegration: $enableAIPIntegration`n"

        $testResultMarkdown += "`n[Manage Information protection in SharePoint Admin Center](https://admin.microsoft.com/sharepoint?page=classicSettings&modern=true)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId             = '35005'
        Title              = 'Sensitivity Labels Enabled in SharePoint Online'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
