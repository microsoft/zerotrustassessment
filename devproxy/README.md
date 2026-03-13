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
| `src/powershell/private/core/Test-ZtRetryableError.ps1` | Determines if an error is retryable (5xx, 429, network) vs non-retryable (4xx) |
| `src/powershell/private/core/Get-ZtHttpStatusCode.ps1` | Extracts HTTP status code from exception objects |
| `code-tests/commands/Invoke-ZtRetry.Tests.ps1` | Pester unit tests (21 tests, no Dev Proxy required) |
