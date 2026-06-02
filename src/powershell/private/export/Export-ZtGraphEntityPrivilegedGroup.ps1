function Export-ZtGraphEntityPrivilegedGroup {
	<#
	.SYNOPSIS
		Exports Privileged Group Memberships for the export cache.

	.DESCRIPTION
		Exports Privileged Group Memberships for the export cache.

	.PARAMETER ExportPath
		The path where exported data (and the database) are stored.

	.PARAMETER InputName
		The name of the export to use as data input.

	.PARAMETER Name
		The name of the new export.

	.EXAMPLE
		PS C:\> Export-ZtGraphEntityPrivilegedGroup -Name RoleEligibilityScheduleRequestGroup -INputName RoleEligibilityScheduleRequest -ExportPath $path

		Exports Privileged Group Memberships for the export cache.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$ExportPath,

		[Parameter(Mandatory = $true)]
		[string]
		$InputName,

		[Parameter(Mandatory = $true)]
		[string]
		$Name
	)

	if (Get-ZtConfig -ExportPath $ExportPath -Property $Name) {
		Write-PSFMessage "Skipping {0} since it was downloaded previously" -StringValues $Name -Target $Name -Tag Export, redundant, skip
		Update-ZtProgressState -WorkerId $Name -WorkerName $Name -WorkerStatus 'Running' -WorkerDetail 'Skipped (cached)'
		return
	}

	$folderPath = Join-Path -Path $ExportPath -ChildPath $Name
	Clear-ZtFolder -Path $folderPath

	$readFolderPath = Join-Path -Path $ExportPath -ChildPath $InputName
	$files = Get-ChildItem -Path $readFolderPath -File
	$maxPageSize = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Export.PrivilegedGroup.MaxPageSize' -Fallback 50000

	function New-PrivilegedGroupExportResults {
		[CmdletBinding()]
		param ()

		@{
			value = [System.Collections.Generic.List[object]]::new()
		}
	}

	function Export-PrivilegedGroupResultsPage {
		[CmdletBinding()]
		param (
			[Parameter(Mandatory = $true)]
			$Results,

			[Parameter(Mandatory = $true)]
			[ref]
			$PageIndex,

			[Parameter(Mandatory = $true)]
			[string]
			$Path,

			[Parameter(Mandatory = $true)]
			[string]
			$Name
		)

		if ($Results.value.Count -eq 0) {
			return
		}

		$filePath = Join-Path $Path "$Name-$($PageIndex.Value).json"
		$Results | Export-PSFJson -Path $filePath -Depth 100 -Encoding UTF8NoBom
		$Results.value.Clear()
		$PageIndex.Value++
	}

	$pageIndex = 0
	foreach ($file in $files) {
		$roleAssignments = $null
		$results = $null
		try {
			$roleAssignments = Import-PSFJson -Path $file.FullName -Encoding UTF8NoBom
			$results = New-PrivilegedGroupExportResults

			foreach ($roleAssignment in $roleAssignments.value) {
				if ($roleAssignment.principal.'@odata.type' -ne '#microsoft.graph.group') {
					continue
				}

				# 5/10/2024 - Entra ID Role Enabled Security Groups do not currently support nesting so we don't need to get transitive members
				$groupId = $roleAssignment.principal.id
				$members = $null
				try {
					Update-ZtProgressState -WorkerId $Name -WorkerName $Name -WorkerStatus 'Running' -WorkerDetail "GET beta/groups/$groupId/members"
					$members = Get-ZtGroupMember -GroupId $groupId -OutputType Hashtable
					foreach ($member in $members) {
						# Clone the hashtable, so we don't modify the hashed results from the membership resolution
						$cloneMember = $member.Clone()
						$cloneMember['privilegedGroupId'] = $groupId
						$cloneMember['roleDefinitionId'] = $roleAssignment.roleDefinitionId
						$results.value.Add($cloneMember)

						if ($results.value.Count -ge $maxPageSize) {
							Export-PrivilegedGroupResultsPage -Results $results -PageIndex ([ref]$pageIndex) -Path $folderPath -Name $Name
						}
					}
				}
				finally {
					$members = $null
				}
			}

			if ($results.value.Count -gt 0) {
				Export-PrivilegedGroupResultsPage -Results $results -PageIndex ([ref]$pageIndex) -Path $folderPath -Name $Name
			}
		}
		finally {
			Clear-GraphPagePayload -Results $roleAssignments
			Clear-GraphPagePayload -Results $results
			$roleAssignments = $null
			$results = $null
		}
	}

	Set-ZtConfig -ExportPath $ExportPath -Property $Name -Value $true
}
