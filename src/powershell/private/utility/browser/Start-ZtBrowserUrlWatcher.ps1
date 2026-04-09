function Start-ZtBrowserUrlWatcher {
    <#
    .SYNOPSIS
        Starts a background PowerShell instance that watches for the captured auth URL and prints it.
    .DESCRIPTION
        After Install-ZtBrowserUrlCapture sets up the wrapper, call this function before
        Connect-MgGraph to start a background watcher. When MSAL invokes xdg-open, the wrapper
        writes the URL to a temp file, and the watcher detects it and prints it to the console
        as a clickable fallback link.
    .PARAMETER CaptureState
        The hashtable returned by Install-ZtBrowserUrlCapture.
    .OUTPUTS
        [powershell] The background PowerShell instance (dispose it during cleanup).
    #>
    [CmdletBinding()]
    [OutputType([powershell])]
    param (
        [Parameter(Mandatory)]
        [hashtable] $CaptureState
    )

    $watcher = [powershell]::Create()
    $null = $watcher.AddScript({
        param($authUrlFile)
        for ($i = 0; $i -lt 100; $i++) {
            Start-Sleep -Milliseconds 100
            if ((Test-Path $authUrlFile) -and (Get-Item $authUrlFile).Length -gt 0) {
                $capturedUrl = (Get-Content -Path $authUrlFile -Raw).Trim()
                if ($capturedUrl -match '^https://') {
                    [Console]::WriteLine("   If the browser did not open, copy and paste this link:")
                    [Console]::WriteLine("   `u{1f517} $capturedUrl")
                }
                break
            }
        }
    }).AddArgument($CaptureState.AuthUrlFile)
    $null = $watcher.BeginInvoke()

    return $watcher
}
