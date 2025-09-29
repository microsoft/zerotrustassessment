<#
.SYNOPSIS

#>

function Test-Assessment-21848 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Low',
        Pillar = 'Identity',
        RiskLevel = 'Low',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce', 'External'),
        TestId = 21848,
        Title = 'Enable custom banned passwords',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking Enable custom banned passwords"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve the password protection settings
    $settings = Invoke-ZtGraphRequest -RelativeUri "settings" -ApiVersion beta

    if ($settings) {
        # The template ID '5cf42378-d67d-4f36-ba46-e8b86229381d' is specific to password protection settings
        $passwordProtectionSettings = $settings | Where-Object { $_.templateId -eq '5cf42378-d67d-4f36-ba46-e8b86229381d' }
    }
    else {
        $passwordProtectionSettings = $null
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    if ($passwordProtectionSettings) {
        $enableBannedPasswordCheck = ($passwordProtectionSettings.values | Where-Object { $_.name -eq 'EnableBannedPasswordCheck' }).value
        $bannedPasswordList = ($passwordProtectionSettings.values | Where-Object { $_.name -eq 'BannedPasswordList' }).value
        if ($bannedPasswordList -eq "") { $bannedPasswordList = $null }

        if ($enableBannedPasswordCheck -eq $true -and $null -ne $bannedPasswordList) {
            $passed = $true
        }
    }

    if ($passed) {
        $testResultMarkdown = "Custom banned passwords are properly configured with organization-specific terms to prevent predictable password patterns.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Custom banned passwords are not enabled or lack sufficient organization-specific terms, leaving the environment vulnerable to targeted password attacks.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Password protection settings"
    $tableRows = ""

    # Create a single table with all profiles
    $formatTemplate = @'

## {0}

| Enforce custom list | Custom banned password list | Number of terms |
| :------------------ | :-------------------------- | :-------------- |
{1}

'@

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/'

    if ($enableBannedPasswordCheck -eq $true) {
        $enforced = "Yes"
    }
    else {
        $enforced = "No"
    }

    # Split on tab characters to handle tab-delimited banned password entries
    if ($bannedPasswordList) {
        $bannedPasswordArray = $bannedPasswordList -split '\t'
    }
    else {
        $bannedPasswordArray = @()
    }

    # Show up to 10 banned passwords, summarize if more exist
    $maxDisplay = 10
    if ($bannedPasswordArray.Count -gt $maxDisplay) {
        $displayList = $bannedPasswordArray[0..($maxDisplay-1)] + "...and $($bannedPasswordArray.Count - $maxDisplay) more"
    }
    else {
        $displayList = $bannedPasswordArray
    }

    $tableRows += @"
| [$(Get-SafeMarkdown($enforced))]($portalLink) | $($displayList -join ', ') | $($bannedPasswordArray.Count) |`n
"@

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21848'
        Title  = "Enable custom banned passwords"
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
