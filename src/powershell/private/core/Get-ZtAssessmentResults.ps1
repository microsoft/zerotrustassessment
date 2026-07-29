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

		if ((Get-Module -Name 'Microsoft.PowerShell.PSResourceGet') -or (Get-Command 'Find-PSResource' -ErrorAction Ignore)) {
			(Find-PSResource -Name ZeroTrustAssessment).Version -as [string]
		}
		elseif (Get-Command 'Find-Module' -ErrorAction SilentlyContinue) {
			(Find-Module -Name ZeroTrustAssessment).Version -as [string]
		}
		else {
			Write-Verbose -Message "Neither PowerShellGet nor PSResourceGet is available. Cannot determine latest module version."
		    'Unknown'
		}
	}

	function Get-TestResultSummary {
		[CmdletBinding()]
		param (
			$TestResults,
			$PreviewEnabled
		)
		$summary = [PSCustomObject]@{
			IdentityPassed = @($TestResults).Where{ $_.TestPillar -eq 'Identity' -and $_.TestStatus -eq 'Passed' }.Count
			IdentityTotal  = @($TestResults).Where{ $_.TestPillar -eq 'Identity' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			DevicesPassed  = @($TestResults).Where{ $_.TestPillar -eq 'Devices' -and $_.TestStatus -eq 'Passed' }.Count
			DevicesTotal   = @($TestResults).Where{ $_.TestPillar -eq 'Devices' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			NetworkPassed  = @($TestResults).Where{ $_.TestPillar -eq 'Network' -and $_.TestStatus -eq 'Passed' }.Count
			NetworkTotal   = @($TestResults).Where{ $_.TestPillar -eq 'Network' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			DataPassed     = @($TestResults).Where{ $_.TestPillar -eq 'Data' -and $_.TestStatus -eq 'Passed' }.Count
			DataTotal      = @($TestResults).Where{ $_.TestPillar -eq 'Data' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			InfrastructurePassed = @($TestResults).Where{ $_.TestPillar -eq 'Infrastructure' -and $_.TestStatus -eq 'Passed' }.Count
			InfrastructureTotal  = @($TestResults).Where{ $_.TestPillar -eq 'Infrastructure' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			SecOpsPassed         = @($TestResults).Where{ $_.TestPillar -eq 'SecOps' -and $_.TestStatus -eq 'Passed' }.Count
			SecOpsTotal          = @($TestResults).Where{ $_.TestPillar -eq 'SecOps' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
			AIPassed             = @($TestResults).Where{ $_.TestPillar -eq 'AI' -and $_.TestStatus -eq 'Passed' }.Count
			AITotal              = @($TestResults).Where{ $_.TestPillar -eq 'AI' -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count
		}

		# Future preview-only pillars can be added here and included only when -Preview is enabled.
		$previewPillars = @()
		if ($PreviewEnabled -and $previewPillars.Count -gt 0) {
			foreach ($previewPillar in $previewPillars) {
				$summary | Add-Member -NotePropertyName ("{0}Passed" -f $previewPillar) -NotePropertyValue (@($TestResults).Where{ $_.TestPillar -eq $previewPillar -and $_.TestStatus -eq 'Passed' }.Count)
				$summary | Add-Member -NotePropertyName ("{0}Total" -f $previewPillar) -NotePropertyValue (@($TestResults).Where{ $_.TestPillar -eq $previewPillar -and $_.TestStatus -notin 'Skipped', 'Planned' }.Count)
			}
		}

		return $summary
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
	$tests = $script:__ZtSession.TestResultDetail.Value.values

	# Restrict TestPillar on cross-referenced tests (multi-pillar arrays) based on how the
	# assessment was invoked. This runs on the main thread where RequestedPillar and PreviewEnabled
	# are always available, avoiding runspace scope issues.
	#   - Specific pillar (e.g. -Pillar AI): set TestPillar to exactly the requested pillar.
	#   - -Pillar All + preview enabled: keep full array (test appears on every tagged page).
	#   - -Pillar All + preview disabled: strip only preview-only pillars.
	$previewPillars = @()
	$_reqPillar   = $script:__ZtSession.RequestedPillar
	$_previewOn   = $script:__ZtSession.PreviewEnabled
	$_isAllPillar = (-not $_reqPillar -or $_reqPillar -eq 'All')
	foreach ($test in $tests) {
		if ($test.TestPillar -isnot [array]) { continue }
		if (-not $_isAllPillar) {
			$test.TestPillar = $_reqPillar
		} elseif (-not $_previewOn -and $previewPillars.Count -gt 0) {
			$test.TestPillar = $test.TestPillar | Where-Object { $_ -notin $previewPillars }
		}
	}

	$ztTestResults = [PSCustomObject][ordered]@{
		ExecutedAt        = Get-Date
		TenantId          = $mgContext.TenantId
		TenantName        = $org.TenantName
		Domain            = $org.Domain
		Account           = $mgContext.Account
		CurrentVersion    = $PSCmdlet.MyInvocation.MyCommand.Module.Version.ToString()
		LatestVersion     = Get-ModuleLatestVersion
		TestResultSummary = Get-TestResultSummary -TestResults $script:__ZtSession.TestResultDetail.Value.values -PreviewEnabled $script:__ZtSession.PreviewEnabled
		Tests             = @($tests) # Use @() to ensure it's an array
		TenantInfo        = Get-ZtTenantInfo
		EndOfJson         = "EndOfJson" # Always leave this as the last property. Used by the script to determine the end of the JSON
	}

	Write-PSFMessage $ztTestResults -Level Debug -Tag ZtAssessmentResults -Target $ztTestResults
	$ztTestResults
}
