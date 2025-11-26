function Get-ZtAssessmentResults {
	<#
	.SYNOPSIS
		Gets the results of all the Zero Trust Assessment tests

	.DESCRIPTION
		Gets the results of all the Zero Trust Assessment tests
		Ran as the last part of the assessment invocation.

		Can be used independently after the assessment command has completed to review the last results.

	.EXAMPLE
		PS C:\> Get-ZtAssessmentResults

		Gets the results of all the Zero Trust Assessment tests
	#>
	[CmdletBinding()]
	param ()

	#region Utility Functions
	function Get-ModuleLatestVersion {
		[CmdletBinding()]
		param (

		)
		if (Get-Command 'Find-Module' -ErrorAction SilentlyContinue) {
			return (Find-Module -Name ZeroTrustAssessment).Version -as [string]
		}

		return 'Unknown'
	}

	function Get-TestResultSummary {
		[CmdletBinding()]
		param (
			$TestResults
		)
		[PSCustomObject]@{
			IdentityPassed = @($TestResults).Where{ $_.TestPillar -eq 'Identity' -and $_.TestStatus -eq 'Passed' }.Count
			IdentityTotal  = @($TestResults).Where{ $_.TestPillar -eq 'Identity' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			DevicesPassed  = @($TestResults).Where{ $_.TestPillar -eq 'Devices' -and $_.TestStatus -eq 'Passed' }.Count
			DevicesTotal   = @($TestResults).Where{ $_.TestPillar -eq 'Devices' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			DataPassed     = @($TestResults).Where{ $_.TestPillar -eq 'Data' -and $_.TestStatus -eq 'Passed' }.Count
			DataTotal      = @($TestResults).Where{ $_.TestPillar -eq 'Data' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
		}
	}

	function Get-Organization {
		[CmdletBinding()]
		param (

		)
		$org = Invoke-ZtGraphRequest -RelativeUri 'organization'
		$defaultDomain = $org.verifiedDomains | Where-Object { $_.isDefault } | Select-Object -First 1
		return [PSCustomObject]@{
			TenantName = $org.displayName
			Domain     = $defaultDomain.name
		}
	}
	#endregion Utility Functions

	$mgContext = Get-MgContext
	$org = Get-Organization
	# Sort by risk then by status
	$tests = $script:__ZtSession.TestResultDetail.Value.values | Sort-Object -Property @{Expression = { $_.TestRisk } }, @{Expression = { $_.TestStatus } }

	$ztTestResults = [PSCustomObject][ordered]@{
		ExecutedAt        = Get-Date
		TenantId          = $mgContext.TenantId
		TenantName        = $org.TenantName
		Domain            = $org.Domain
		Account           = $mgContext.Account
		CurrentVersion    = $PSCmdlet.MyInvocation.MyCommand.Module.Version.ToString()
		LatestVersion     = Get-ModuleLatestVersion
		TestResultSummary = Get-TestResultSummary -TestResults $script:__ZtSession.TestResultDetail.Value.values
		Tests             = @($tests) # Use @() to ensure it's an array
		TenantInfo        = Get-ZtTenantInfo
		EndOfJson         = "EndOfJson" # Always leave this as the last property. Used by the script to determine the end of the JSON
	}

	Write-PSFMessage $ztTestResults -Level Debug -Tag ZtAssessmentResults -Target $ztTestResults
	$ztTestResults
}
