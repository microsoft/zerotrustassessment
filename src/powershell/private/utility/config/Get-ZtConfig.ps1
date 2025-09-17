function Get-ZtConfig {
    [CmdletBinding()]
    param (
        # The export path
		[Parameter(Mandatory = $true)]
        [string]
        $ExportPath,

        # Optional. The specific property to get
        $Property
    )

    # Read config from folder
    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    $Config = @{}
    if (Test-Path $configPath) {
        $Config = Import-PSFJson -Path $configPath -AsHashtable
    }

    if ($Property) {
        $Config.$Property
    }
    else {
        return $Config
    }
}
