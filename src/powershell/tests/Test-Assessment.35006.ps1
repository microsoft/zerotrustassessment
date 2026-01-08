<#
.SYNOPSIS
    PDF Labeling Support in SharePoint Online

.DESCRIPTION
    PDF files stored in SharePoint Online and OneDrive for Business require separate enablement of sensitivity label support beyond the base Office file integration. When EnableSensitivityLabelforPDF is disabled, organizations create a protection gap where PDF documents remain unclassified and unprotected despite sensitivity label policies being active for Office files.

.NOTES
    Test ID: 35006
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35006 {
    [ZtTest(
        Category = 'SharePoint Online',
        ImplementationCost = 'Low',
        MinimumLicense = ('MIP_P1'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35006,
        Title = 'PDF Labeling Support in SharePoint Online',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking PDF Labeling Support in SharePoint Online'
    Write-ZtProgress -Activity $activity -Status 'Getting SharePoint Tenant Settings'

    $spoTenant = $null
    $errorMsg = $null

    try {
        # Query: Retrieve SharePoint Online tenant PDF labeling support status
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
        $passed = $null -ne $spoTenant -and $spoTenant.EnableSensitivityLabelforPDF -eq $true
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to query SharePoint Tenant Settings due to error: $errorMsg"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ PDF labeling support is enabled in SharePoint Online and OneDrive, allowing users to classify and protect PDF files.`n`n"
        }
        else {
            $testResultMarkdown = "❌ PDF labeling support is NOT enabled. PDF files cannot be labeled or protected in SharePoint and OneDrive.`n`n"
        }

        $testResultMarkdown += "### SharePoint Online Configuration Summary`n`n"
        $testResultMarkdown += "**Tenant Settings:**`n"

        $enableSensitivityLabelForPDF = if ($null -ne $spoTenant -and $spoTenant.EnableSensitivityLabelforPDF -eq $true) { "True" } else { "False" }
        $testResultMarkdown += "* EnableSensitivityLabelforPDF: $enableSensitivityLabelForPDF`n"

        $testResultMarkdown += "`n[Manage information protection in SharePoint Admin Center](https://admin.microsoft.com/sharepoint?page=classicSettings&modern=true)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId             = '35006'
        Title              = 'PDF Labeling Support in SharePoint Online'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
