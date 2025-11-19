
<#
.SYNOPSIS
    Calculates the CA summary data from sign in logs for the overiew report and adds it to the tenant info.
#>

function Add-ZtOverviewCaMfa {
	[CmdletBinding()]
	param(
		$Database
	)

	#region Utility Function
	function Get-ZtiOverviewCaMfa {
		[CmdletBinding()]
		param (
			$Results,

			$Database
		)

		$caMfa = @($Results).Where{ $_.conditionalAccessStatus -eq 'success' -and $_.authenticationRequirement -eq 'multiFactorAuthentication' }.cnt -as [int]
		$caNoMfa = @($Results).Where{ $_.conditionalAccessStatus -eq 'success' -and $_.authenticationRequirement -eq 'singleFactorAuthentication' }.cnt -as [int]
		$noCaMfa = @($Results).Where{ $_.conditionalAccessStatus -eq 'notApplied' -and $_.authenticationRequirement -eq 'multiFactorAuthentication' }.cnt -as [int]
		$noCaNoMfa = @($Results).Where{ $_.conditionalAccessStatus -eq 'notApplied' -and $_.authenticationRequirement -eq 'singleFactorAuthentication' }.cnt -as [int]

		$nodes = @(
			@{
				"source" = "User sign in"
				"target" = "No CA applied"
				"value"  = $noCaMfa + $noCaNoMfa
			},
			@{
				"source" = "User sign in"
				"target" = "CA applied"
				"value"  = $caMfa + $caNoMfa
			},
			@{
				"source" = "CA applied"
				"target" = "No MFA"
				"value"  = $caNoMfa
			},
			@{
				"source" = "CA applied"
				"target" = "MFA"
				"value"  = $caMfa
			}
		)

		$duration = Get-ZtSignInDuration -Database $Database
		$total = $noCaMfa + $noCaNoMfa + $caMfa + $caNoMfa
		$percent = Get-ZtPercentLabel -Value $caMfa -Total $total

		@{
			"description" = "Over the past $duration, $percent of sign-ins were protected by conditional access policies enforcing multifactor."
			"nodes"       = $nodes
		}
	}
	#endregion Utility Function

	$tenantInfoName = 'OverviewCaMfaAllUsers'

	$activity = "Getting Conditional Access summary"
	Write-ZtProgress -Activity $activity -Status "Processing"

	$EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
	if ($EntraIDPlan -eq "Free") {
		Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
		Add-ZtTenantInfo -Name $tenantInfoName -Value $null
		return
	}

	$sql = @"
select conditionalAccessStatus, authenticationRequirement, count(*) as cnt from SignIn
where isInteractive == true and status.errorCode == 0
group by conditionalAccessStatus, authenticationRequirement
"@

	# Example output:
	# conditionalAccessStatus   authenticationRequirement   cnt
	# success                   singleFactorAuthentication  5
	# success                   multiFactorAuthentication   2121
	# notApplied                singleFactorAuthentication  6
	# notApplied                multiFactorAuthentication   6


	$results = Invoke-DatabaseQuery -Database $Database -Sql $sql
	$caSummary = Get-ZtiOverviewCaMfa -Results $results -Database $Database
	Add-ZtTenantInfo -Name $tenantInfoName -Value $caSummary
}
