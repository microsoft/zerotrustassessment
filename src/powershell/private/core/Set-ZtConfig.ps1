function Set-ZtConfig {
    [CmdletBinding()]
    param (
        # The folder to output the report to.
        [string]
        [Parameter(Mandatory = $true)]
        $ExportPath,

        # Optional. The specific step to set
        [ValidateSet('ServicePrincipal', 'ServicePrincipalSignIn')]
        [Parameter(Mandatory = $false)]
        $Step,

        # Optional. Provide the complete config to set
        $Config
    )

    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    Write-Verbose "Setting config at $configPath"
    if ($Config) {
        $Config | ConvertTo-Json | Set-Content $configPath
    }
    else {
        $config = Get-ZtConfig -ExportPath $ExportPath
        $config[$Step] = $true
        $config | ConvertTo-Json | Set-Content $configPath -Force
    }
}
