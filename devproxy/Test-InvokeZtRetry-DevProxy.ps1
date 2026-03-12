<#
.SYNOPSIS
	Integration test for Invoke-ZtRetry using Dev Proxy to simulate Graph API failures.

.DESCRIPTION
	This script exercises Invoke-ZtRetry against real Microsoft Graph endpoints while Dev Proxy
	intercepts requests and injects random errors (429, 500, 502, 503, 504).

	Prerequisites:
	  1. Dev Proxy installed: https://learn.microsoft.com/en-us/microsoft-cloud/dev/dev-proxy/get-started/set-up
	  2. Microsoft Graph PowerShell SDK: Install-PSResource Microsoft.Graph.Authentication
	  3. Connected to a tenant: Connect-MgGraph -Scopes "User.Read"

	Usage:
	  # Terminal 1 - Start Dev Proxy (50% failure rate for realistic testing):
	  devproxy --config-file devproxy/devproxyrc.json

	  # Terminal 1 - Or use 100% failure rate to verify retry exhaustion:
	  devproxy --config-file devproxy/devproxyrc-always-fail.json

	  # Terminal 2 - Run this test script:
	  pwsh devproxy/Test-InvokeZtRetry-DevProxy.ps1

.NOTES
	Dev Proxy acts as an HTTP proxy. PowerShell needs to route traffic through it.
	Dev Proxy configures the system proxy automatically when started. If Graph SDK
	doesn't pick it up, set the environment variable before running:
	  $env:HTTPS_PROXY = "http://localhost:8000"
#>

[CmdletBinding()]
param (
	[Parameter()]
	[ValidateRange(1, 10)]
	[int]$RetryCount = 5,

	[Parameter()]
	[ValidateRange(1, 60)]
	[int]$RetryDelay = 3,

	[Parameter()]
	[int]$TestIterations = 5
)

$ErrorActionPreference = 'Stop'

#region Load module functions
$srcRoot = Join-Path $PSScriptRoot "../src/powershell"

# Load dependencies in order
. (Join-Path $srcRoot "private/core/Get-ZtHttpStatusCode.ps1")
. (Join-Path $srcRoot "private/core/Test-ZtRetryableError.ps1")
. (Join-Path $srcRoot "private/core/Invoke-ZtRetry.ps1")

# Check for PSFramework (needed for Write-PSFMessage)
if (-not (Get-Module PSFramework -ListAvailable)) {
	Write-Warning "PSFramework module not found. Installing for logging support..."
	Install-PSResource PSFramework -Scope CurrentUser -Force
}
Import-Module PSFramework -ErrorAction Stop
#endregion

#region Verify prerequisites
Write-Host "`n=== Dev Proxy Integration Test for Invoke-ZtRetry ===" -ForegroundColor Cyan
Write-Host "RetryCount: $RetryCount | RetryDelay: ${RetryDelay}s | Iterations: $TestIterations`n"

# Check Graph connection
try {
	$context = Get-MgContext
	if (-not $context) {
		throw "Not connected"
	}
	Write-Host "[OK] Connected to Microsoft Graph as $($context.Account)" -ForegroundColor Green
}
catch {
	Write-Host "[ERROR] Not connected to Microsoft Graph. Run: Connect-MgGraph -Scopes 'User.Read'" -ForegroundColor Red
	exit 1
}

# Check if Dev Proxy is likely running (test the proxy)
Write-Host "[INFO] Ensure Dev Proxy is running in another terminal:" -ForegroundColor Yellow
Write-Host "       devproxy --config-file devproxy/devproxyrc.json`n" -ForegroundColor Yellow
#endregion

#region Test Execution
$results = @{
	Success          = 0
	RetryThenSuccess = 0
	Failed           = 0
	Errors           = @()
}

# Simple Graph requests that should normally succeed
$testUris = @(
	"https://graph.microsoft.com/v1.0/me",
	"https://graph.microsoft.com/v1.0/organization",
	"https://graph.microsoft.com/beta/me"
)

for ($i = 1; $i -le $TestIterations; $i++) {
	$uri = $testUris[($i - 1) % $testUris.Count]
	$shortUri = $uri -replace 'https://graph.microsoft.com/', ''

	Write-Host "--- Test $i/$TestIterations [$shortUri] ---" -ForegroundColor White

	$retryOccurred = $false
	$retryHandler = {
		param($err)
		$script:retryOccurred = $true
		Write-Host "  [RETRY] $($err.Exception.Message)" -ForegroundColor Yellow
	}

	$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
	try {
		$response = Invoke-ZtRetry -RetryCount $RetryCount -RetryDelay $RetryDelay -RetryHandler $retryHandler -ScriptBlock {
			Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType HashTable
		}
		$stopwatch.Stop()

		if ($retryOccurred) {
			$results.RetryThenSuccess++
			Write-Host "  [RECOVERED] Got response after retries (${$stopwatch.Elapsed.TotalSeconds:F1}s)" -ForegroundColor Green
		}
		else {
			$results.Success++
			Write-Host "  [OK] Direct success ($($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s)" -ForegroundColor Green
		}

		# Show a snippet of the response
		if ($response.displayName) {
			Write-Host "  Response: displayName=$($response.displayName)" -ForegroundColor DarkGray
		}
		elseif ($response.value) {
			Write-Host "  Response: $($response.value.Count) items" -ForegroundColor DarkGray
		}
	}
	catch {
		$stopwatch.Stop()
		$results.Failed++
		$results.Errors += $_.Exception.Message
		Write-Host "  [FAILED] All retries exhausted ($($stopwatch.Elapsed.TotalSeconds.ToString('F1'))s): $($_.Exception.Message)" -ForegroundColor Red
	}

	# Brief pause between iterations
	if ($i -lt $TestIterations) {
		Start-Sleep -Seconds 1
	}
}
#endregion

#region Summary
Write-Host "`n=== Results ===" -ForegroundColor Cyan
Write-Host "Direct successes:       $($results.Success)" -ForegroundColor Green
Write-Host "Recovered after retry:  $($results.RetryThenSuccess)" -ForegroundColor Yellow
Write-Host "Failed (exhausted):     $($results.Failed)" -ForegroundColor Red
Write-Host "Total:                  $TestIterations"

if ($results.Errors.Count -gt 0) {
	Write-Host "`nFailed request errors:" -ForegroundColor Red
	$results.Errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkRed }
}

$retryRate = if ($TestIterations -gt 0) { [math]::Round(($results.RetryThenSuccess + $results.Failed) / $TestIterations * 100) } else { 0 }
Write-Host "`nDev Proxy intercept rate: ~${retryRate}% of requests were error-injected" -ForegroundColor DarkGray

if ($results.RetryThenSuccess -gt 0) {
	Write-Host "`n[PASS] Invoke-ZtRetry successfully recovered from transient errors!" -ForegroundColor Green
}
if ($results.Failed -gt 0 -and $results.Success -eq 0 -and $results.RetryThenSuccess -eq 0) {
	Write-Host "`n[INFO] All requests failed - this is expected with devproxyrc-always-fail.json (100% failure rate)" -ForegroundColor Yellow
}
#endregion
