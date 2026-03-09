
<#
.SYNOPSIS
    Calculates the CA summary data from sign in logs for managed devices in the overiew report and adds it to the tenant info.
#>

function Add-ZtOverviewCaDevicesAllUsers {
	[CmdletBinding()]
	param(
		$Database
	)

	#region Utility Functions
	function Get-ZtiOverviewCaDevicesAllUsers {
		[CmdletBinding()]
		param (
			$Results,

			$Database
		)

		$managed = ($Results | Where-Object isManaged).cnt -as [int]
		$unmanaged = ($Results | Where-Object isManaged -EQ $false).cnt -as [int]
		$compliant = $Results.Where{ $_.isManaged -and $_.isCompliant }.cnt -as [int]
		$nonCompliant = $Results.Where{ $_.isManaged -and -not $_.isCompliant }.cnt -as [int]

		$nodes = @(
			@{
				"source" = "User sign in"
				"target" = "Unmanaged"
				"value"  = $unmanaged
			},
			@{
				"source" = "User sign in"
				"target" = "Managed"
				"value"  = $managed
			},
			@{
				"source" = "Managed"
				"target" = "Non-compliant"
				"value"  = $nonCompliant
			},
			@{
				"source" = "Managed"
				"target" = "Compliant"
				"value"  = $compliant
			}
		)

		$duration = Get-ZtSignInDuration -Database $Database
		$percent = Get-ZtPercentLabel -Value $compliant -Total ($managed + $unmanaged)
		@{
			"description" = "Over the past $duration, $percent of sign-ins were from compliant devices."
			"nodes"       = $nodes
		}
	}
	#endregion Utility Functions
	$activity = "Getting Conditional Access summary"
	Write-ZtProgress -Activity $activity -Status "Processing"

	$tenantInfoName = 'OverviewCaDevicesAllUsers'

	$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
	if ($EntraIDPlan -eq "Free") {
		Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
		Add-ZtTenantInfo -Name $tenantInfoName -Value $null
		return
	}

	$sql = @"
select deviceDetail.isManaged as isManaged, deviceDetail.isCompliant as isCompliant, count(*) as cnt from SignIn
where isInteractive == true and status.errorCode == 0
group by isManaged, isCompliant
"@

	# Example output:
	# isManaged   isCompliant   cnt
	# true       false          19
	# true       true           83
	# false      false          455


	$results = Invoke-DatabaseQuery -Database $Database -Sql $sql

	$caSummary = Get-ZtiOverviewCaDevicesAllUsers -Results $results -Database $Database

	Add-ZtTenantInfo -Name $tenantInfoName -Value $caSummary
}
