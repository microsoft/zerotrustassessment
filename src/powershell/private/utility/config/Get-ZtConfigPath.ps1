function Get-ZtConfigPath {
    [CmdletBinding()]
    param (
        # The export path
		[Parameter(Mandatory = $true)]
        [string]
        $ExportPath
    )

    Join-Path -Path $ExportPath -ChildPath "ztConfig.json"
}
