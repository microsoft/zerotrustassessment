<#
.SYNOPSIS

#>

function Test-Assessment-21837{
    [ZtTest(
    	Category = 'Device management',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21837,
    	Title = 'Limit the maximum number of devices per user to 10',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        # Database connection for internal user queries
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking maximum number of devices per user limit'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Retrieve device registration policy
    Write-ZtProgress -Activity $activity -Status 'Getting device registration policy'
    $policy = Invoke-ZtGraphRequest -RelativeUri 'policies/deviceRegistrationPolicy' -ApiVersion 'beta'
    $userQuota = $null
    if ($policy) { $userQuota = $policy.userDeviceQuota }

    # Evaluate compliance
    $passed = $false
    $customStatus = $null
    $entraDeviceSettingsLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview'

    if ($null -eq $userQuota) {
        $testResultMarkdown = "Policy not found. Unable to retrieve maximum device quota. [View device settings]($entraDeviceSettingsLink)"
    }
    elseif ($userQuota -le 10) {
        $passed = $true
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota"
    }
    elseif ($userQuota -gt 10 -and $userQuota -le 20) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota. Consider reducing to 10 or fewer."
    }
    else {
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota. Consider reducing to 10 or fewer."
    }


    # Query database for device count per user and display top 100 users (regardless of test result)
    Write-ZtProgress -Activity $activity -Status 'Querying database for user device counts'

    # Query to count registered devices per user from the database
    $sql = @"
SELECT
    owner.userPrincipalName as userId,
    owner.displayName as userDisplayName,
    COUNT(*) as deviceCount
FROM (
    SELECT unnest(d.registeredOwners) as owner
    FROM Device d
    WHERE d.accountEnabled = true
) owners
GROUP BY owner.userPrincipalName, owner.displayName
ORDER BY deviceCount DESC, userDisplayName ASC
LIMIT 100
"@

    $allUsers = Invoke-DatabaseQuery -Database $Database -Sql $sql

    # Build markdown summary for top 100 users with device counts
    if ($allUsers.Count -gt 0) {
        $mdUsers = @"


## Top 100 users by device count

| User | Device count |
| :--- | :----------- |

"@
        foreach ($user in $allUsers) {
            $userName = if ($user.userDisplayName) { $user.userDisplayName } else { $user.userId }
            $mdUsers += "| $userName | $($user.deviceCount) |`n"
        }
        $testResultMarkdown += $mdUsers
    }
    else {
        $testResultMarkdown += "`n`n_No device ownership data found in the database._"
    }

    $params = @{
        TestId = '21837'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
