function Invoke-ZtTenantDataExport {
	<#
	.SYNOPSIS
		Executes a single Entra export tasks as specified.

	.DESCRIPTION
		Executes a single Entra export tasks as specified.
		This command assumes it is called from within the parallelized export workflow started by Export-ZtTenantData.

		It is the location where we translate the configuration entries in the "export-tenant.config.psd1" config file into action.
		Also where all the tracking and metadata collecting happens, to ensure we can troubleshoot issues.

	.PARAMETER Export
		The export settings to realize.

	.PARAMETER ExportPath
		The path where the tenant data gets exported to.

	.PARAMETER DependencyTimeout
		How long we are willing to wait for another export process that we depend on to complete.
		If this time expires, our export will also fail.

	.EXAMPLE
		PS C:\> Invoke-ZtTenantDataExport -Export $_ -DependencyTimeout $dependencyTimeout -ExportPath $exportPath

		Executes the provided tenant export configuration to the path specified in $exportPath
	#>
	[CmdletBinding()]
	param (
		[hashtable]
		$Export,

		[string]
		$ExportPath,

		[Psftimespan]
		$DependencyTimeout
	)
	begin {
		$previousMessages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId)
		$result = [PSCustomObject]@{
			PSTypeName = 'ZeroTrustAssessment.ExportStatistics'
			Name       = $Export.Name
			Export     = $Export

			# Performance Metrics, in case we want to identify problematic exports
			Start      = $null
			End        = $null
			Duration   = $null

			# What Happened?
			Success    = $true
			Error      = $null
			Messages   = $null

			# Exports should have no output, but we'll catch it anyways, just in case
			Output     = $null
		}
		$workflow = $global:__PSF_Workflow
		# Dummy in case this function is run outside of the Runspace Workflow it is intended for
		if (-not $workflow) {
			$workflow = @{ Data = @{ } }
			$workflow.Data[$Export.Name] = [PSCustomObject]@{
				Status  = 'Pending'
				Name    = $Export.Name
				Updated = Get-Date
				Message = ''
			}
		}
		$identity = New-Guid
	}
	process {
		Write-PSFMessage -Message "Processing export '{0}'" -StringValues $Export.Name -Target $Export -Tag start

		#region Wait for Dependencies
		if ($Export.DependsOn) {
			$exportState = Get-ZtConfig -ExportPath $ExportPath -Property $Export.DependsOn
			$start = Get-Date
			$limit = $start.Add($DependencyTimeout)

			$workflow.Data[$Export.Name].Status = 'Waiting'
			$workflow.Data[$Export.Name].Updated = Get-Date

			while (-not $exportState -and $workflow.Data[$Export.DependsOn].Status -ne 'Done') {
				Write-PSFMessage -Message "Export '{0}' depends on '{1}', which is not yet completed" -StringValues $Export.Name, $Export.DependsOn -Once "ZeroTrust-$($Export.Name)-$($identity)" -Target $Export

				# Case: Dependency does not exist
				if (-not $workflow.Data[$Export.DependsOn]) {
					Write-PSFMessage -Level Warning -Message "Dependency '{0}' is not registered for export and has not previously been exported. No succes is possible, skipping Processing." -StringValues $Export.DependsOn, "$($workflow.Data[$Export.DependsOn].Status)" -Target $Export -Tag end
					$result.Success = $false
					$result.Error = 'Dependency Failed'
					$workflow.Data[$Export.Name].Status = 'Failed'
					$workflow.Data[$Export.Name].Updated = Get-Date
					$workflow.Data[$Export.Name].Message = "Dependency '$($Export.DependsOn)' not exported and not scheduled to be so."
					return
				}

				# Case: Dependency Failed
				if ($workflow.Data[$Export.DependsOn].Status -notin 'Pending', 'Waiting', 'InProgress', 'Done') {
					Write-PSFMessage -Level Warning -Message "Dependency '{0}' is in state '{1}', which there is no presumed way of recovery from. Skipping Processing." -StringValues $Export.DependsOn, "$($workflow.Data[$Export.DependsOn].Status)" -Target $Export -Tag end
					$result.Success = $false
					$result.Error = 'Dependency Failed'
					$workflow.Data[$Export.Name].Status = 'Failed'
					$workflow.Data[$Export.Name].Updated = Get-Date
					$workflow.Data[$Export.Name].Message = "Dependency '$($Export.DependsOn)' not expected to succeed. Status: $($workflow.Data[$Export.DependsOn].Status)"
					return
				}

				# Case: Timeout Reached
				if ($limit -lt (Get-Date)) {
					Write-PSFMessage -Level Warning -Message "Timeout waiting for dependency '{0}' to complete (current state: '{1}'). Skipping Processing." -StringValues $Export.DependsOn, "$($workflow.Data[$Export.DependsOn].Status)" -Target $Export -Tag end
					$result.Success = $false
					$result.Error = 'Dependency Failed'
					$workflow.Data[$Export.Name].Status = 'Failed'
					$workflow.Data[$Export.Name].Updated = Get-Date
					$workflow.Data[$Export.Name].Message = "Timeout waiting for dependency '$($Export.DependsOn)' to complete."
					return
				}

				Start-Sleep -Seconds 5
			}
		}
		#endregion Wait for Dependencies

		try {
			$result.Start = Get-Date
			$workflow.Data[$Export.Name].Status = 'InProgress'
			switch ($Export.Type) {
				PrivilegedGroup {
					$exportParam = $Export | ConvertTo-PSFHashtable -ReferenceCommand Export-ZtGraphEntityPrivilegedGroup
					$result.Output = Export-ZtGraphEntityPrivilegedGroup @exportParam -ExportPath $ExportPath -ErrorAction Stop
				}
				default {
					$exportParam = $Export | ConvertTo-PSFHashtable -ReferenceCommand Export-ZtGraphEntity
					$result.Output = Export-ZtGraphEntity @exportParam -ExportPath $ExportPath -ErrorAction Stop
				}
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Error executing export '{0}'" -StringValues $Export.Name -Target $Export -ErrorRecord $_
			$workflow.Data[$Export.Name].Status = 'Failed'
			$workflow.Data[$Export.Name].Updated = Get-Date
			$workflow.Data[$Export.Name].Message = "$_"
			$result.Success = $false
			$result.Error = $_
		}
		finally {
			$result.End = Get-Date
			$result.Duration = $result.End - $result.Start
			if ($workflow.Data[$Export.Name].Status -ne 'Failed') {
				$workflow.Data[$Export.Name].Status = 'Done'
				$workflow.Data[$Export.Name].Updated = Get-Date
			}
		}
		Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $Export.Name -Target $Export -Tag end
	}
	end {
		$result.Messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId) | Where-Object { $_ -notin $previousMessages }
		$result
	}
}
