function Show-ZtTelemetryNotice {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[bool]
		$DisableTelemetry
	)

	Write-Host "⚠️ " -NoNewline -ForegroundColor Yellow
	if ($DisableTelemetry) {
		Write-Host "Telemetry is disabled for this run. No assessment telemetry event will be sent." -ForegroundColor Yellow
	}
	else {
		Write-Host @"
Telemetry is enabled for this run. The telemetry event includes your tenant ID
as its only tenant-specific custom property. The payload also includes the
event name, timestamp, instrumentation key, and fixed anonymised IP and OS tags.
Assessment results are not included. Standard network metadata, such as the
connection source IP, may be processed by Azure Monitor or intervening network
services. You can disable telemetry by using the -DisableTelemetry switch.
"@ -ForegroundColor Yellow
	}

	Write-Host @"
Review the telemetry implementation (Send-ZtAppInsightsTelemetry):
https://github.com/microsoft/zerotrustassessment/blob/dev/src/powershell/private/Send-ZtAppInsightsTelemetry.ps1
"@ -ForegroundColor Cyan
	Write-Host
}
