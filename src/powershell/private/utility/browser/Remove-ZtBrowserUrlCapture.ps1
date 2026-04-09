function Remove-ZtBrowserUrlCapture {
    <#
    .SYNOPSIS
        Cleans up the browser URL capture wrapper, temp file, and background watcher.
    .DESCRIPTION
        Reverses the PATH modification, removes the wrapper directory and temp file,
        and disposes the background PowerShell watcher. Call this in a finally block
        after Connect-MgGraph completes.
    .PARAMETER CaptureState
        The hashtable returned by Install-ZtBrowserUrlCapture. May be $null (no-op).
    .PARAMETER Watcher
        The PowerShell instance returned by Start-ZtBrowserUrlWatcher. May be $null (no-op).
    #>
    [CmdletBinding()]
    param (
        [AllowNull()]
        [hashtable] $CaptureState,

        [AllowNull()]
        [powershell] $Watcher
    )

    if ($CaptureState) {
        if ($CaptureState.WrapperDir) {
            $env:PATH = ($env:PATH -split ':' | Where-Object { $_ -ne $CaptureState.WrapperDir }) -join ':'
            Remove-Item -Path $CaptureState.WrapperDir -Recurse -Force -ErrorAction Ignore
        }
        if ($CaptureState.AuthUrlFile) {
            Remove-Item -Path $CaptureState.AuthUrlFile -Force -ErrorAction Ignore
        }
        Write-PSFMessage -Message "Removed browser URL capture wrapper." -Level Debug
    }

    if ($Watcher) {
        $Watcher.Dispose()
    }
}
