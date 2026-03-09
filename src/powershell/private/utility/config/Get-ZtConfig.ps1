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

	$lock = Get-PSFRunspaceLock -Name ZeroTrustAssessment.ExportConfig

    # Read config from folder
    $configPath = Get-ZtConfigPath -ExportPath $ExportPath
    $Config = @{}
    if (Test-Path $configPath) {
		try {
			$lock.Open()
			$Config = Import-PSFJson -Path $configPath -AsHashtable
		}
		finally {
			$lock.Close()
		}
    }

    if ($Property) {
        $Config.$Property
    }
    else {
        return $Config
    }
}
