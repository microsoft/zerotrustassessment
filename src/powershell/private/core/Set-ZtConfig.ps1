function Set-ZtConfig {
    [CmdletBinding()]
    param (
        # The folder to output the report to.
        [string]
        [Parameter(Mandatory = $true)]
        $ExportPath,

        # Optional. The specific step to set
        [Parameter(Mandatory = $false)]
        $Property,

        $Value,

        # Optional. Provide the complete config to set
        $Config
    )

    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    Write-PSFMessage "Setting config at $configPath"
    if ($Config) {
        $Config | ConvertTo-Json | Set-Content $configPath
    }
    else {
        $config = Get-ZtConfig -ExportPath $ExportPath
        $config[$Property] = $Value
        $config | ConvertTo-Json | Set-Content $configPath -Force
    }
}
