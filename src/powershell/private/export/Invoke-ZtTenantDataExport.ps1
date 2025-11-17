function Invoke-ZtTenantDataExport {
	[CmdletBinding()]
	param (
		[hashtable]
		$Export
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
	}
	process {
		Write-PSFMessage -Message "Processing export '{0}'" -StringValues $Export.Name -Target $Export -Tag start

		try {
			$result.Start = Get-Date
			switch ($Export.Type) {
				PrivilegedGroup {
					$exportParam = $Export | ConvertTo-PSFHashtable -ReferenceCommand Export-ZtGraphEntityPrivilegedGroup
					$result.Output = Export-ZtGraphEntityPrivilegedGroup @exportParam -ErrorAction Stop
				}
				default {
					$exportParam = $Export | ConvertTo-PSFHashtable -ReferenceCommand Export-ZtGraphEntity
					$result.Output = Export-ZtGraphEntity @exportParam -ErrorAction Stop
				}
			}
			$result.Output = & $command @dbParam -ErrorAction Stop
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Error executing export '{0}'" -StringValues $Export.Name -Target $Export -ErrorRecord $_
			$result.Success = $false
			$result.Error = $_
		}
		finally {
			$result.End = Get-Date
			$result.Duration = $result.End - $result.Start
		}
		Write-PSFMessage -Message "Processing test '{0}' - Concluded" -StringValues $Export.Name -Target $Export -Tag end
	}
	end {
		$result.Messages = Get-PSFMessage -Runspace ([runspace]::DefaultRunspace.InstanceId) | Where-Object { $_ -notin $previousMessages }
		$result
	}
}
