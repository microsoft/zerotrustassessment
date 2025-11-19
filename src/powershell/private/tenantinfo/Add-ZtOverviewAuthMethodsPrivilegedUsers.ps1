
<#
.SYNOPSIS
    Calculates auth methods registered by privileged users.
#>

function Add-ZtOverviewAuthMethodsPrivilegedUsers {
	[CmdletBinding()]
	param(
		$Database
	)
	$activity = "Getting privileged user authentication methods summary"
	Write-ZtProgress -Activity $activity -Status "Processing"

	#region Utility Functions
	function Get-ZtiPrivUserAuthMethodCountSingleFactor {
		[CmdletBinding()]
		param (
			$Database
		)

		$sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where len(methodsRegistered) = 0
    and cast(id as varchar) in
    (select principalId from vwRole)
"@
		$results = Invoke-DatabaseQuery -Database $Database -Sql $sql
		$results.count
	}

	function Get-ZtiPrivUserAuthMethodCount {
	[CmdletBinding()]
	param (
		$Database,

		[string]
		$MethodTypes
	)
	$sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where list_has_any([$MethodTypes], methodsRegistered)
    and cast(id as varchar) in
    (select principalId from vwRole)
"@
	$results = Invoke-DatabaseQuery -Database $Database -Sql $sql
	$results.count
}

	function Get-ZtiOverviewAuthMethodsPrivilegedUsers {
		[CmdletBinding()]
		param (
			$Database
		)

		$singleFactor = Get-ZtiPrivUserAuthMethodCountSingleFactor -Database $Database
		$phone = Get-ZtiPrivUserAuthMethodCount -Database $Database -MethodTypes "'mobilePhone'"
		$authenticator = Get-ZtiPrivUserAuthMethodCount -Database $Database -MethodTypes "'microsoftAuthenticatorPush', 'softwareOneTimePasscode', 'microsoftAuthenticatorPasswordless'"
		$passkey = Get-ZtiPrivUserAuthMethodCount -Database $Database -MethodTypes "'passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator'"
		$whfb = Get-ZtiPrivUserAuthMethodCount -Database $Database -MethodTypes "'windowsHelloForBusiness'"

		$nodes = @(
			@{
				"source" = "Users"
				"target" = "Single factor"
				"value"  = $singleFactor
			},
			@{
				"source" = "Users"
				"target" = "Phishable"
				"value"  = $phone + $authenticator
			},
			@{
				"source" = "Phishable"
				"target" = "Phone"
				"value"  = $phone
			},
			@{
				"source" = "Phishable"
				"target" = "Authenticator"
				"value"  = $authenticator
			},
			@{
				"source" = "Users"
				"target" = "Phish resistant"
				"value"  = $passkey + $whfb
			},
			@{
				"source" = "Phish resistant"
				"target" = "Passkey"
				"value"  = $passkey
			},
			@{
				"source" = "Phish resistant"
				"target" = "WHfB"
				"value"  = $whfb
			}
		)

		@{
			"description" = "Strongest authentication method registered by privileged users."
			"nodes"       = $nodes
		}
	}
	#endregion Utility Functions

	$tenantInfoName = 'OverviewAuthMethodsPrivilegedUsers'

	$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
	if ($EntraIDPlan -eq "Free") {
		Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
		Add-ZtTenantInfo -Name $tenantInfoName -Value $null
		return
	}

	$caSummary = Get-ZtiOverviewAuthMethodsPrivilegedUsers -Database $Database

	Add-ZtTenantInfo -Name $tenantInfoName -Value $caSummary
}
