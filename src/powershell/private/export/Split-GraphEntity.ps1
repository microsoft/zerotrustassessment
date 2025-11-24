function Split-GraphEntity {
    <#
    .SYNOPSIS
        Extracts resources of a specific OData type from exported JSON files.
    .DESCRIPTION
        Reads JSON files for a given entity, filters resources by the specified @odata.type,
        and exports them to a new folder/files maintaining the original structure.
    .PARAMETER ExportPath
        The root export path.
    .PARAMETER SourceEntityName
        The name of the source entity (folder name), e.g., "DeviceConfiguration".
    .PARAMETER TargetEntityName
        The name of the target entity (folder name), e.g., "WindowsUpdateForBusinessConfiguration".
    .PARAMETER ResourceType
        The OData type to filter by (e.g., "#microsoft.graph.windowsUpdateForBusinessConfiguration").
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExportPath,

        [Parameter(Mandatory = $true)]
        [string]$SourceEntityName,

        [Parameter(Mandatory = $true)]
        [string]$TargetEntityName,

        [Parameter(Mandatory = $true)]
        [string]$ResourceType
    )

    $sourcePath = Join-Path $ExportPath $SourceEntityName
    $targetPath = Join-Path $ExportPath $TargetEntityName

    if (-not (Test-Path $sourcePath)) {
        Write-PSFMessage "Source path not found: $sourcePath" -Level Warning
        return
    }

    # Create target directory
    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    } else {
        # Clear existing files in target
        Get-ChildItem -Path $targetPath -Filter "*.json" | Remove-Item -Force
    }

    $files = Get-ChildItem -Path $sourcePath -Filter "$SourceEntityName-*.json"

    foreach ($file in $files) {
        Write-PSFMessage "Processing $($file.Name) for $TargetEntityName..." -Level Verbose

        try {
            $jsonContent = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
        }
        catch {
            Write-PSFMessage "Failed to parse JSON from $($file.FullName)" -Level Error
            continue
        }

        if (-not $jsonContent.PSObject.Properties['value']) {
            continue
        }

        $filteredResources = @($jsonContent.value | Where-Object { $_.'@odata.type' -eq $ResourceType })

        if ($filteredResources.Count -gt 0) {
            # Create a new ordered dictionary to preserve structure
            $newProperties = [ordered]@{}

            # Copy all properties from the original object (like @odata.context, @odata.nextLink)
            foreach ($prop in $jsonContent.PSObject.Properties) {
                if ($prop.Name -eq 'value') {
                    $newProperties['value'] = $filteredResources
                } else {
                    $newProperties[$prop.Name] = $prop.Value
                }
            }

            $outputData = [PSCustomObject]$newProperties

            # Generate filename: TargetEntityName-Index.json
            $suffix = $file.Name.Substring($SourceEntityName.Length) # e.g. "-0.json"
            $outputFilename = "$TargetEntityName$suffix"
            $outputPath = Join-Path -Path $targetPath -ChildPath $outputFilename

            Write-PSFMessage "Exporting $($filteredResources.Count) items to $outputFilename" -Level Verbose
            $outputData | ConvertTo-Json -Depth 100 | Set-Content -Path $outputPath
        }
    }
}
