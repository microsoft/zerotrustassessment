function Get-ZtConfigPath {
    [CmdletBinding()]
    param (
        # The export path
        [string]
        $ExportPath
    )

    return Join-Path $ExportPath "ztConfig.json"
}
