<#
.SYNOPSIS
    SPO Default Document Library Label (Tenant-Wide)

.DESCRIPTION
    SharePoint document libraries support configuring default sensitivity labels that automatically apply baseline protection to new or edited files that lack existing labels or have lower-priority labels. When the tenant-level capability DisableDocumentLibraryDefaultLabeling is enabled (set to $true), organizations block site administrators from establishing automatic baseline classification for document libraries.

.NOTES
    Test ID: 35008
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35008 {
    [ZtTest(
        Category = 'SharePoint Online',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35008,
        Title = 'SPO Default Document Library Label (Tenant-Wide)',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking SPO Default Document Library Label Capability'
    Write-ZtProgress -Activity $activity -Status 'Getting SharePoint Tenant Settings'

    $spoTenant = $null
    $errorMsg = $null

    try {
        # Query: Retrieve SharePoint tenant setting for document library default labeling capability
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
        if ($null -ne $spoTenant -and $spoTenant.DisableDocumentLibraryDefaultLabeling -eq $true) {
            $passed = $false
        }
        else {
            $passed = $true
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
            $testResultMarkdown = "✅ Default sensitivity label capability is enabled for SharePoint document libraries, allowing automatic baseline labeling.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Default sensitivity label capability is DISABLED. Site admins cannot configure library-level default labels.`n`n"
        }

        $testResultMarkdown += "### SharePoint Online Configuration Summary`n`n"
        $testResultMarkdown += "**Tenant Settings:**`n"

        $disableDocumentLibraryDefaultLabeling = if ($spoTenant.DisableDocumentLibraryDefaultLabeling) { "True" } else { "False" }
        $testResultMarkdown += "* DisableDocumentLibraryDefaultLabeling: $disableDocumentLibraryDefaultLabeling`n"
    }
    #endregion Report Generation

    $testResultDetail = @{
        TestId             = '35008'
        Title              = 'SPO Default Document Library Label (Tenant-Wide)'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultDetail
}
