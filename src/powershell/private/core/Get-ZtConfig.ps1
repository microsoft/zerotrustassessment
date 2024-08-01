function Get-ZtConfig {
    [CmdletBinding()]
    param (
        # The export path
        [string]
        $ExportPath,

        # Optional. The specific property to get
        $Property
    )

    # Read config from folder
    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    $Config = @{}
    if (Test-Path $configPath) {
        $Config = Get-Content $configPath | ConvertFrom-Json -AsHashtable
    }

    if ($Property) {
        if($null -eq $Config) {
            return $null
        }
        return Get-ObjectProperty $Config $Property
    }
    else {
        return $Config
    }
}
