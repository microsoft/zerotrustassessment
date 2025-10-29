
<#
.SYNOPSIS
    Checks that admins are not synced from on-prem
#>

function Test-Assessment-21814 {
    [ZtTest(
    	Category = 'Privileged access',
    	ImplementationCost = 'Medium',
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

    $roles = Get-ZTRole -IncludePrivilegedRoles
    # Get all privileged roles
    # TODO: Remove filter for GA and Global Reader, limiting during testing time.
    $privilegedRoles = $roles | Where-Object { $_.displayName -in @('Global Administrator', 'Global Reader') }

    foreach ($role in $privilegedRoles) {
        Write-ZtProgress -Activity $activity -Status "Getting members in role $($role.displayName)"
        $roleMembers = Get-ZtRoleMember -RoleId $role.id
        # TODO : For groups get transitive members
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
        $testResultMarkdown += "This tenant has $onpremUserCount privileged users that are synced from on-premise.`n`n%TestResult%"
    }

    #TODO: Make user names clickable
    $mdInfo = "## Privileged Roles`n`n"
    $mdInfo += "| Role Name | User | Source | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :---: |`n"
    foreach ($role in $privilegedRoles | Sort-Object displayName) {
        foreach ($user in $role.ZtUsers) {
            if ($user.onPremisesSyncEnabled) {
                $type = "Synced from on-premise"
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
