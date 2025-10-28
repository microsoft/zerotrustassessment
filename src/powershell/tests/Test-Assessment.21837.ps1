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
    $entraDeviceSettingsLink = "https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview"

    if ($null -eq $userQuota) {
        $testResultMarkdown = '**Policy not found.** Unable to retrieve maximum device quota.'
    }
    elseif ($userQuota -le 10) {
        $passed = $true
        $testResultMarkdown = "Maximum number of devices per user is set to [$userQuota]($entraDeviceSettingsLink)"
    }
    elseif ($userQuota -gt 10 -and $userQuota -le 20) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "Maximum number of devices per user is set to [$userQuota]($entraDeviceSettingsLink). Consider reducing to 10 or fewer."
    }
    else {
        $testResultMarkdown = "Maximum number of devices per user is set to [$userQuota]($entraDeviceSettingsLink). Consider reducing to 10 or fewer."
    }

    # Only check for users exceeding quota if test fails
    if (-not $passed) {
        Write-ZtProgress -Activity $activity -Status 'Querying database for users exceeding device quota'

        # Query to count registered devices per user from the database
        $sql = @"
SELECT
    unnest(d.registeredOwners).id as userId,
    u.displayName as userDisplayName,
    COUNT(*) as deviceCount
FROM Device d
LEFT JOIN [User] u ON unnest(d.registeredOwners).id = u.id
WHERE unnest(d.registeredOwners).id IS NOT NULL
GROUP BY unnest(d.registeredOwners).id, u.displayName
HAVING COUNT(*) > $userQuota
ORDER BY deviceCount DESC
LIMIT 101
"@

        $exceeding = Invoke-DatabaseQuery -Database $Database -Sql $sql

        # Limit to first 100 users
        $userLimit = 100
        $userTruncated = $false
        if ($exceeding.Count -gt $userLimit) {
            $exceeding = $exceeding[0..($userLimit-1)]
            $userTruncated = $true
        }

        # Build markdown summary for users exceeding quota
        if ($exceeding.Count -gt 0) {
            $mdUsers = "`n`n## Users exceeding device limit ($userQuota)`n`n"
            $mdUsers += '| User | Device count |`n| :--- | :----------- |`n'
            foreach ($e in $exceeding) {
                $userName = if ($e.userDisplayName) { $e.userDisplayName } else { $e.userId }
                $mdUsers += "| $userName | $($e.deviceCount) |`n"
            }
            if ($userTruncated) {
                $mdUsers += "`n_Note: Only the first 100 users are shown._"
            }
            $testResultMarkdown += $mdUsers
        }
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
