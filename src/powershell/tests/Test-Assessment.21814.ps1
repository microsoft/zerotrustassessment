
<#
.SYNOPSIS
    Checks that admins are not synced from on-prem
#>

function Test-Assessment-21814 {
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21814,
    	Title = 'Privileged accounts are cloud native identities',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking cloud only roles"
    Write-ZtProgress -Activity $activity -Status "Getting roles"

    # Get all privileged roles
    $privilegedRoles = Get-ZTRole -IncludePrivilegedRoles

    foreach ($role in $privilegedRoles) {
        Write-ZtProgress -Activity $activity -Status "Getting members in role $($role.displayName)"
        $roleMembers = Get-ZtRoleMember -RoleId $role.id

        $roleUsers = $roleMembers | Where-Object { $_.'@odata.type' -eq "#microsoft.graph.user" }

        $ztUsers = @()
        foreach ($user in $roleUsers) {
            $ztUsers += Invoke-ZtGraphRequest -RelativeUri "users" -UniqueId $user.id -Select id, displayName, onPremisesSyncEnabled
        }
        # Add a new property to the role object to store the users
        $role | Add-Member -MemberType NoteProperty -Name "ZtUsers" -Value $ztUsers
    }

    $passed = $privilegedRoles.ZtUsers.onPremisesSyncEnabled -notcontains $true

    if ($passed) {
        $testResultMarkdown += "Validated that standing or eligible privileged accounts are cloud only accounts.`n`n%TestResult%"
    }
    else {
        $onpremUserCount = ($privilegedRoles.ZtUsers | Where-Object { $_.onPremisesSyncEnabled }).Count
        $testResultMarkdown += "This tenant has $onpremUserCount privileged users that are synced from on-premises.`n`n%TestResult%"
    }

    $mdInfo = "## Privileged roles`n`n"
    $mdInfo += "| Role name | User | Source | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :---: |`n"
    foreach ($role in $privilegedRoles | Sort-Object displayName) {
        foreach ($user in $role.ZtUsers) {
            if ($user.onPremisesSyncEnabled) {
                $type = "Synced from on-premises"
                $status = "❌"
            }
            else {
                $type = "Cloud native identity"
                $status = "✅"
            }

            $userLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}" -f $user.id
            $mdInfo += "| $($role.displayName) | [$($user.displayName)]($userLink) | $type | $status |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21814' -Title 'Privileged accounts are cloud native identities' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag PrivilegedIdentity `
        -Status $passed -Result $testResultMarkdown
}
