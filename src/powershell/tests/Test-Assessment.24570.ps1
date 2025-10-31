<#
.SYNOPSIS
    Entra Connect Sync is configured with Service Principal Credentials
#>

function Test-Assessment-24570 {
    [ZtTest(
    	Category = 'Hybrid infrastructure',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24570,
    	Title = 'Entra Connect Sync is configured with Service Principal Credentials',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Entra Connect Sync is configured with Service Principal Credentials"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Check if tenant has hybrid identity configuration
    $hybridConfigUri = 'organization?$select=onPremisesSyncEnabled,onPremisesLastSyncDateTime'
    $hybridConfig = Invoke-ZtGraphRequest -RelativeUri $hybridConfigUri -ApiVersion v1.0

    # Query users assigned to Directory Synchronization Accounts role
    $filter = "roleTemplateId eq 'd29b2b05-8046-44ba-8758-1e26182fcf32'"
    $expand = 'members($select=id,displayName,userPrincipalName,accountEnabled,userType)'

    $dirSyncRoleUri = "directoryRoles?`$filter=$([uri]::EscapeDataString($filter))&`$expand=$([uri]::EscapeDataString($expand))"

    $dirSyncRole = Invoke-ZtGraphRequest -RelativeUri $dirSyncRoleUri -ApiVersion v1.0

    if ($dirSyncRole -and $dirSyncRole.Count -ge 1) {
        $dirSyncMembers = @($dirSyncRole[0].members)
    }
    else {
        $dirSyncMembers = @()
    }

    $enabledDirSyncUsers = @()
    foreach ($member in $dirSyncMembers) {
        if ($member.accountEnabled -eq $true -and $member.'@odata.type' -eq '#microsoft.graph.user') {
            $enabledDirSyncUsers += $member
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    if ($null -eq $hybridConfig.onPremisesSyncEnabled -or $hybridConfig.onPremisesSyncEnabled -eq $false) {
        $isHybridIdentity = $false
    }
    else {
        $isHybridIdentity = $true
    }

    if (-not $isHybridIdentity -or ($isHybridIdentity -and $enabledDirSyncUsers.Count -eq 0)) {
        $passed = $true
        $testResultMarkdown = "Microsoft Entra Connect uses service principal authentication (application identity).`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "Found enabled user accounts with Microsoft Entra Connect connector permissions.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Identities for Entra Connect Sync"
    $tableRows = ""

    if ($dirSyncMembers.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Directory Synchronization Accounts Role Member | User Principal Name | Enabled | User Type |
| :--------------------------------------------- | :------------------ | :------ | :-------- |
{1}

'@

        foreach ($member in $dirSyncMembers) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}' -f $member.id
            $userName = Get-SafeMarkdown -Text $member.displayName
            $userPrincipalName = Get-SafeMarkdown -Text $member.userPrincipalName
            $enabled = if ($member.accountEnabled) {
                '❌ Yes'
            }
            else {
                '✅ No'
            }
            $userType = Get-SafeMarkdown -Text $member.userType

            $tableRows += @"
| [$userName]($portalLink) | $userPrincipalName | $enabled | $userType |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    $mdInfo = ("**Hybrid Identity Status**: {0}`n`n" -f $isHybridIdentity) + $mdInfo

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24570'
        Title  = 'Entra Connect Sync is configured with Service Principal Credentials'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
