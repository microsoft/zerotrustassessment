# Dev Proxy - Graph API Error Simulation

This folder contains [Dev Proxy](https://learn.microsoft.com/en-us/microsoft-cloud/dev/dev-proxy/overview) configuration for testing `Invoke-ZtRetry` resilience against transient Microsoft Graph API failures.

Dev Proxy is a command-line tool that intercepts HTTP requests and injects simulated errors, allowing you to verify retry logic without waiting for real API failures.

## What's in this folder

| File | Description |
|------|-------------|
| `devproxyrc.json` | Main config - **50% failure rate**. Realistic simulation where roughly half of Graph requests fail with random errors. |
| `devproxyrc-always-fail.json` | Aggressive config - **100% failure rate**. Every Graph request fails. Use this to verify that `Invoke-ZtRetry` exhausts all retries and throws the final error correctly. |
| `Test-InvokeZtRetry-DevProxy.ps1` | Integration test script that makes Graph API calls through Dev Proxy and reports retry behavior. |

## Configuration details

Both configs use the `GraphRandomErrorPlugin`, which is specifically designed for Microsoft Graph and returns properly formatted Graph error responses.

### URLs intercepted

| Pattern | Description |
|---------|-------------|
| `https://graph.microsoft.com/v1.0/*` | All Graph v1.0 API calls |
| `https://graph.microsoft.com/beta/*` | All Graph beta API calls |

### Error codes injected

| Code | Name | Description |
|------|------|-------------|
| 429 | Too Many Requests | Throttling - the most common transient error from Graph. Includes a `Retry-After` header. |
| 500 | Internal Server Error | Generic server-side failure. |
| 502 | Bad Gateway | Upstream service returned an invalid response. |
| 503 | Service Unavailable | Service temporarily down for maintenance or overloaded. |
| 504 | Gateway Timeout | Upstream service didn't respond in time. |

### Config comparison

| Setting | `devproxyrc.json` | `devproxyrc-always-fail.json` |
|---------|-------------------|-------------------------------|
| Failure rate | 50% | 100% |
| `retryAfterInSeconds` | 3 | 3 |
| Allowed errors | 429, 500, 502, 503, 504 | 429, 500, 502, 503, 504 |
| Use case | Realistic testing | Verify retry exhaustion path |

## Prerequisites

1. **Install Dev Proxy**

   macOS (Homebrew):
   ```
   brew tap dotnet/dev-proxy
   brew install dev-proxy
   ```

   Windows (winget):
   ```
   winget install DevProxy.DevProxy --silent
   ```

   Linux:
   ```
   bash -c "$(curl -sL https://aka.ms/devproxy/setup.sh)"
   ```

2. **Microsoft Graph PowerShell SDK** (already a module dependency):
   ```powershell
   Install-PSResource Microsoft.Graph.Authentication -Scope CurrentUser
   ```

3. **First-time setup**: The first time you run Dev Proxy, it will ask you to trust its SSL certificate. This is required to intercept HTTPS traffic. Press `y` (macOS/Linux) or click `Yes` (Windows) when prompted.

## Running the integration test

### Step 1: Start Dev Proxy

Open a terminal at the repo root and start Dev Proxy with one of the configs:

```bash
# Realistic testing (50% of requests fail)
devproxy --config-file devproxy/devproxyrc.json

# Or: force all requests to fail (verify retry exhaustion)
devproxy --config-file devproxy/devproxyrc-always-fail.json
```

You should see output like:
```
 info    Dev Proxy API listening on http://localhost:8897...
 info    Dev Proxy Listening on 127.0.0.1:8000...

Hotkeys: issue (w)eb request, (r)ecord, (s)top recording, (c)lear screen
Press CTRL+C to stop Dev Proxy
```

### Step 2: Connect to Microsoft Graph

In a second terminal:

```powershell
Connect-ZtAssessment
```

### Step 3: Run the test script

```powershell
# Default: 5 iterations, 5 retries, 3s initial delay
pwsh devproxy/Test-InvokeZtRetry-DevProxy.ps1

# Custom parameters
pwsh devproxy/Test-InvokeZtRetry-DevProxy.ps1 -RetryCount 3 -RetryDelay 1 -TestIterations 10
```

### Step 4: Observe the results

The script outputs a summary like:

```
=== Results ===
Direct successes:       2
Recovered after retry:  2
Failed (exhausted):     1
Total:                  5

Dev Proxy intercept rate: ~60% of requests were error-injected

[PASS] Invoke-ZtRetry successfully recovered from transient errors!
```

In the Dev Proxy terminal, you'll see each intercepted request:

```
 req   ╭ GET https://graph.microsoft.com/v1.0/me
 oops  ╰ 500 InternalServerError
 req   ╭ GET https://graph.microsoft.com/v1.0/me
 api   ╰ Passed through
```

### Step 5: Stop Dev Proxy

Press `Ctrl+C` in the Dev Proxy terminal. Always stop Dev Proxy this way so it properly unregisters as the system proxy.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Graph SDK doesn't route through Dev Proxy | Set the proxy manually: `$env:HTTPS_PROXY = "http://localhost:8000"` |
| Certificate trust errors | Re-run `devproxy` and accept the certificate prompt, or see [Dev Proxy docs](https://learn.microsoft.com/en-us/microsoft-cloud/dev/dev-proxy/get-started/set-up) |
| Browser/other apps affected while Dev Proxy runs | Dev Proxy sets itself as the system proxy. Stop it with `Ctrl+C` when done. |
| All requests pass through without errors | Verify `urlsToWatch` patterns match the URLs your app calls. Check Dev Proxy terminal for `Passed through` messages. |

## Related files

| File | Description |
|------|-------------|
| `src/powershell/private/core/Invoke-ZtRetry.ps1` | The retry wrapper function being tested |
| `src/powershell/private/core/Test-ZtRetryableError.ps1` | Excludes permanent client errors and SDK-handled 429, 503, and 504; other statuses and status-less errors retain wrapper retries |
| `src/powershell/private/core/Get-ZtHttpStatusCode.ps1` | Extracts HTTP status code from exception objects |
| `code-tests/commands/Invoke-ZtRetry.Tests.ps1` | Pester unit tests (no Dev Proxy required) |

## Compare SDK-owned retries before and after

The Graph SDK retries 429, 503, and 504 before the wrapper receives the failure.
The wrapper now propagates these statuses without starting another SDK retry cycle.
HTTP 500, 502, and errors without an extracted status retain the previous wrapper behavior.

Use a dedicated PowerShell session and a test tenant. Do not run an assessment or
other Graph commands during measurement. Count only `req` entries for the exact
test URL in Dev Proxy, not both request and response lines. The integration
script's "intercept rate" measures failed/retried iterations, not HTTP requests.
Do not share raw captures containing tokens or tenant data.

### 1. Start a deterministic proxy in terminal A

From the repository root:

```powershell
devproxy --config-file devproxy/devproxyrc-always-fail.json --allowed-errors 429 --failure-rate 100
```

Accept any required certificate trust prompt yourself. Verify that the proxy
injects 429 for every test request. Repeat the procedure separately with 503 and
504, stopping the previous proxy with Ctrl+C before starting another.

### 2. Prepare terminal B

Use the same connected PowerShell process for all runs, not a new `pwsh` process:

```powershell
Import-Module Microsoft.Graph.Authentication
Import-Module PSFramework
Connect-MgGraph -Scopes User.Read -NoWelcome
$previousRequestContext = Get-MgRequestContext
Get-Module Microsoft.Graph.Authentication | Select-Object Name, Version
$previousRequestContext | Select-Object MaxRetry, RetryDelay, RetriesTimeLimit, ClientTimeout
Set-MgRequestContext -MaxRetry 3 -RetryDelay 3 -RetriesTimeLimit 0 -ClientTimeout 300
. ./src/powershell/private/core/Get-ZtHttpStatusCode.ps1
. ./src/powershell/private/core/Test-ZtRetryableError.ps1
. ./src/powershell/private/core/Invoke-ZtRetry.ps1
$afterPolicy = (Get-Command Test-ZtRetryableError -CommandType Function).ScriptBlock
$beforePolicy = [scriptblock]::Create(($afterPolicy.ToString() -replace '(?m)^[\t ]*(429|503|504)[\t ]*(?:#[^\r\n]*)?\r?\n', ''))
$testUri = 'https://graph.microsoft.com/v1.0/me'
$runProbe = {
   $script:wrapperCalls = 0
   try {
      Invoke-ZtRetry -RetryCount 5 -RetryDelay 1 -ScriptBlock {
         $script:wrapperCalls++
         Invoke-MgGraphRequest -Method GET -Uri $testUri -OutputType HashTable -ErrorAction Stop
      } | Out-Null
   }
   catch {
      [pscustomobject]@{
         WrapperCalls = $script:wrapperCalls
         StatusCode = Get-ZtHttpStatusCode -ErrorRecord $_
         ExceptionType = $_.Exception.GetType().FullName
      }
   }
}
```

The before policy removes only the three newly added status entries from an
in-memory copy. It does not revert files or remove the status-extraction fix.
The one-second wrapper delay shortens the comparison without changing request
counts; the SDK still uses its three-second delay or the injected Retry-After.

### 3. Establish the SDK-only baseline

Mark the start and end of this run in terminal A, then run in terminal B:

```powershell
try {
   Invoke-MgGraphRequest -Method GET -Uri $testUri -OutputType HashTable -ErrorAction Stop | Out-Null
}
catch {
   Get-ZtHttpStatusCode -ErrorRecord $_
}
```

Expect four HTTP request entries for persistent 429, 503, or 504. Do not proceed
with the comparison if requests bypass the proxy or this baseline differs; first
check the loaded SDK, request context, timeout, and injected status.

### 4. Measure the before policy

Mark a new measurement interval in terminal A. In terminal B:

```powershell
Set-Item -Path Function:Test-ZtRetryableError -Value $beforePolicy
try { & $runProbe }
finally { Set-Item -Path Function:Test-ZtRetryableError -Value $afterPolicy }
```

Expect `WrapperCalls = 6` and 24 HTTP request entries. The final status must be
the injected status, not null. A failed command is expected in a 100% failure run.

### 5. Measure the after policy

Mark another measurement interval in terminal A. In terminal B:

```powershell
& $runProbe
```

Expect `WrapperCalls = 1` and four HTTP request entries, with no wrapper
"Retrying in" warnings. If the status is null, inspect sanitized exception types
and status properties: missing status extraction still triggers wrapper retries.

### 6. Repeat and check controls

| Injected status | SDK only | Wrapper before | Wrapper after |
|---|---:|---:|---:|
| 429 | 4 | 24 | 4 |
| 503 | 4 | 24 | 4 |
| 504 | 4 | 24 | 4 |
| 500 | 1 | 6 | 6 |
| 502 | 1 | 6 | 6 |

These counts assume persistent identical failures and the explicit SDK settings
above. This probe bypasses Graph response caching and measures one wrapper,
not the nested license lookup. The license lookup's conditional bound changes
from 96 to four for the SDK-handled statuses when both layers extract the status.

### 7. Clean up

Stop Dev Proxy with Ctrl+C in terminal A. In terminal B, restore the request
settings and close this dedicated session to discard the local function copies:

```powershell
Set-MgRequestContext -MaxRetry $previousRequestContext.MaxRetry -RetryDelay $previousRequestContext.RetryDelay -RetriesTimeLimit ([int]$previousRequestContext.RetriesTimeLimit.TotalSeconds) -ClientTimeout ([int]$previousRequestContext.ClientTimeout.TotalSeconds)
Disconnect-MgGraph
```
