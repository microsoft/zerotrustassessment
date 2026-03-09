
<#
.SYNOPSIS
    Calculates auth methods registered by all users.
#>

function Add-ZtOverviewAuthMethodsAllUsers {
	[CmdletBinding()]
	param(
		$Database
	)
	$activity = "Getting authentication methods summary"
	Write-ZtProgress -Activity $activity -Status "Processing"

	#region Helper Functions
	function Get-ZtiAllUsersAuthMethodCountSingleFactor {
		[CmdletBinding()]
		param (
			$Database
		)
		$sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where len(methodsRegistered) = 0
"@
		(Invoke-DatabaseQuery -Database $Database -Sql $sql).count
	}

	function Get-ZtiAllUsersAuthMethodCount {
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
"@
		(Invoke-DatabaseQuery -Database $Database -Sql $sql).count
	}

	function Get-ZtiOverviewAuthMethodsAllUsers {
		[CmdletBinding()]
		param (
			$Database
		)

		$singleFactor = Get-ZtiAllUsersAuthMethodCountSingleFactor -Database $Database
		$phone = Get-ZtiAllUsersAuthMethodCount -Database $Database -MethodTypes "'mobilePhone'"
		$authenticator = Get-ZtiAllUsersAuthMethodCount -Database $Database -MethodTypes "'microsoftAuthenticatorPush', 'softwareOneTimePasscode', 'microsoftAuthenticatorPasswordless'"
		$passkey = Get-ZtiAllUsersAuthMethodCount -Database $Database -MethodTypes "'passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator'"
		$whfb = Get-ZtiAllUsersAuthMethodCount -Database $Database -MethodTypes "'windowsHelloForBusiness'"

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
			"description" = "Strongest authentication method registered by all users."
			"nodes"       = $nodes
		}
	}
	#endregion Helper Functions

	$tenantInfoName = 'OverviewAuthMethodsAllUsers'

	$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
	if ($EntraIDPlan -eq "Free") {
		Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
		Add-ZtTenantInfo -Name $tenantInfoName -Value $null
		return
	}

	$caSummary = Get-ZtiOverviewAuthMethodsAllUsers -Database $Database

	Add-ZtTenantInfo -Name "OverviewAuthMethodsAllUsers" -Value $caSummary
}
