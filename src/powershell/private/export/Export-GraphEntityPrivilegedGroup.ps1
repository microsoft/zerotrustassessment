function Export-GraphEntityPrivilegedGroup {
    [CmdletBinding()]
    param ($ExportPath, $InputEntityName, $EntityName, $ProgressActivity)

    if ((Get-ZtConfig -ExportPath $ExportPath -Property $EntityName)) {
        Write-PSFMessage "Skipping $EntityName since it was downloaded previously"
        return
    }

    $activity = "Exporting $ProgressActivity"
    Write-ZtProgress $activity

    $folderPath = Join-Path $ExportPath $EntityName
    Clear-ZtFolder $folderPath

    # Get all the files in the folder
    $readFolderPath = Join-Path $ExportPath $InputEntityName
    $files = Get-ChildItem -Path $readFolderPath -File

    $folderPath = Join-Path $ExportPath $EntityName
    # Iterate each file and find all the groups
    $groups = @()
    $pageIndex = 0
    foreach ($file in $files) {
        # Read the file as json
        $roleAssignments = Get-Content -Path $file.FullName | ConvertFrom-Json
        # Get all the groups
        $groups = $roleAssignments.value | Where-Object { $_.principal.'@odata.type' -eq '#microsoft.graph.group' }
        # Create an object with a 'value' property that contains the array of items
        $results = @{ value = @() }

        $groups | ForEach-Object {`
                Write-ZtProgress $activity -Status $_.principal.displayName
            #5/10/2024 - Entra ID Role Enabled Security Groups do not currently support nesting so we don't need to get transitive members
            $groupId = $_.principal.id
            $member = Get-ZtGroupMember -groupId $groupId
            if ($member -and $member.Count -gt 0) {
                # Add the group id property to the member object
                $member | Add-Member -MemberType NoteProperty -Name privilegedGroupId -Value $groupId -Force # Need to force to overwrite if it was cached user.
                # Add the RoleDefinitionId property
                $member | Add-Member -MemberType NoteProperty -Name roleDefinitionId -Value $_.roleDefinitionId -Force
                $results.value += $member
            }
        }

        if ($results.value.Count -gt 0) {
            $filePath = Join-Path $folderPath "$EntityName-$pageIndex.json"
            $results | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath -Force
            $pageIndex++
        }
    }

    Set-ZtConfig -ExportPath $ExportPath -Property $EntityName -Value $true
}
