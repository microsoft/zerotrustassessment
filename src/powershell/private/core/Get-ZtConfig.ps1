function Get-ZtConfig {
    [CmdletBinding()]
    param (
        # The export path
        [string]
        $ExportPath,

        [ValidateSet('ServicePrincipal', 'ServicePrincipalSignIn')]
        $Step
    )

    # Read config from folder
    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    if (Test-Path $configPath) {
        $Config = Get-Content $configPath | ConvertFrom-Json
    }
    else {
        $Config = @{
            ServicePrincipal           = $false
            ServicePrincipalSignIn     = $false
        }
    }

    if ($Step) {
        return $Config[$Step]
    }
    else {
        return $Config
    }
}
