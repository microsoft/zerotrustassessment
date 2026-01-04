<#
.SYNOPSIS
    Information Rights Management (IRM) Enabled in SharePoint Online

.DESCRIPTION
    Information Rights Management (IRM) integration in SharePoint Online libraries is a legacy feature that has been replaced by Enhanced SharePoint Permissions (ESP). Any library using this legacy capabilitiy should be flagged to move to newer capabilities.

.NOTES
    Test ID: 35007
    Pillar: Data
    Risk Level: Low
#>

function Test-Assessment-35007 {
    [ZtTest(
        Category = 'SharePoint Online',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Low',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35007,
        Title = 'Information Rights Management (IRM) Enabled in SharePoint Online',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Information Rights Management (IRM) Status in SharePoint Online'
    Write-ZtProgress -Activity $activity -Status 'Getting SharePoint Tenant Settings'

    $spoTenant = $null
    $errorMsg = $null

    try {
        # Query: Retrieve SharePoint Online tenant IRM enablement status
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
        $passed = $null -ne $spoTenant -and $spoTenant.IrmEnabled -ne $true
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query SharePoint Tenant Settings due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Legacy IRM feature is disabled. Organizations should use modern sensitivity labels for document protection.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Legacy IRM feature is still enabled. Libraries may be using outdated protection mechanisms.`n`n"
        }

        $testResultMarkdown += "### SharePoint Online Configuration Summary`n`n"
        $testResultMarkdown += "**Tenant Settings:**`n"

        $irmEnabled = if ($null -ne $spoTenant -and $spoTenant.IrmEnabled -eq $true) { "True" } else { "False" }
        $testResultMarkdown += "* IrmEnabled: $irmEnabled`n"

        $testResultMarkdown += "`n[Manage Information Rights Management (IRM) in SharePoint Admin Center](https://admin.microsoft.com/sharepoint?page=classicSettings&modern=true)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId             = '35007'
        Title              = 'Information Rights Management (IRM) Enabled in SharePoint Online'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
