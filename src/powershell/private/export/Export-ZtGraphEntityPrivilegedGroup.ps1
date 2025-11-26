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
        return
    }

    $folderPath = Join-Path -Path $ExportPath -ChildPath $Name
    Clear-ZtFolder -Path $folderPath

    $readFolderPath = Join-Path -Path $ExportPath -ChildPath $InputName
    $files = Get-ChildItem -Path $readFolderPath -File

    $pageIndex = 0
    foreach ($file in $files) {
        $roleAssignments = Import-PSFJson -Path $file.FullName -Encoding UTF8NoBom
        $groups = $roleAssignments.value | Where-Object { $_.principal.'@odata.type' -eq '#microsoft.graph.group' }

		# Create an object with a 'value' property that contains the array of items
		# Resultant json files are expected to have this format when loading the database content for the Tests processing
        $results = @{ value = @() }

        $results.value = $groups | ForEach-Object {
            # 5/10/2024 - Entra ID Role Enabled Security Groups do not currently support nesting so we don't need to get transitive members
            $groupId = $_.principal.id
            $members = Get-ZtGroupMember -GroupId $groupId -OutputType Hashtable
			foreach ($member in $members) {
				# Clone the hashtable, so we don't modify the hashed results from the membership resolution
				$cloneMember = $member.Clone()
				$cloneMember['privilegedGroupId'] = $groupId
				$cloneMember['roleDefinitionId'] = $_.roleDefinitionId
				$cloneMember
			}
        }

        if ($results.value.Count -gt 0) {
            $filePath = Join-Path $folderPath "$Name-$pageIndex.json"
			$results | Export-PSFJson -Path $filePath -Depth 100 -Encoding UTF8NoBom
            $pageIndex++
        }
    }

    Set-ZtConfig -ExportPath $ExportPath -Property $Name -Value $true
}
