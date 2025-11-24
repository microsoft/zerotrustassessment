function Set-ZtConfig {
    [CmdletBinding(DefaultParameterSetName = 'Property')]
    param (
        # The folder to output the report to.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ExportPath,

        # Optional. The specific step to set
		[Parameter(Mandatory = $true, ParameterSetName = 'Property')]
		[string]
        $Property,

		[Parameter(Mandatory = $true, ParameterSetName = 'Property')]
		[AllowNull()]
		[AllowEmptyCollection()]
		[AllowEmptyString()]
        $Value,

        # Optional. Provide the complete config to set
		[Parameter(Mandatory = $true, ParameterSetName = 'Object')]
		[hashtable]
        $Config
    )

	$lock = Get-PSFRunspaceLock -Name ZeroTrustAssessment.ExportConfig

    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    Write-PSFMessage "Setting config at $configPath"
	$lock.Open()
	try {
		if ($Config) {
			$Config | Export-PSFJson -Path $configPath
		}
		else {
			$config = Get-ZtConfig -ExportPath $ExportPath
			$config[$Property] = $Value
			$config | Export-PSFJson -Path $configPath
		}
	}
	finally {
		$lock.Close()
	}
}
