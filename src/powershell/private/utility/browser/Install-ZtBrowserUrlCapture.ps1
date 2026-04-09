function Install-ZtBrowserUrlCapture {
    <#
    .SYNOPSIS
        Installs a temporary xdg-open/open wrapper that captures the auth URL MSAL passes to the browser.
    .DESCRIPTION
        In container environments, MSAL opens the browser via xdg-open (Linux) or open (macOS) with a
        URL containing PKCE code_challenge, state, and a dynamic localhost port. This function creates
        a thin wrapper script that logs the URL to a temp file before forwarding to the real browser
        opener, enabling a clickable fallback link to be displayed in the terminal.
    .OUTPUTS
        [hashtable] State needed by Start-ZtBrowserUrlWatcher and Remove-ZtBrowserUrlCapture,
        or $null if the wrapper could not be installed.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    if (-not ($IsLinux -or $IsMacOS)) { return $null }

    $browserCmd = if ($IsLinux) { 'xdg-open' } else { 'open' }
    $resolvedCmd = Get-Command -Name $browserCmd -ErrorAction Ignore
    if (-not $resolvedCmd) {
        Write-PSFMessage -Message "Cannot install URL capture: '$browserCmd' not found on PATH." -Level Debug
        return $null
    }
    $realBrowserPath = $resolvedCmd.Source

    $authUrlFile = [System.IO.Path]::GetTempFileName()
    $wrapperDirName = "zt-browser-wrapper-$([System.Guid]::NewGuid().ToString('N'))"
    $wrapperDir  = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $wrapperDirName
    $null = New-Item -Path $wrapperDir -ItemType Directory -Force
    $wrapperPath = Join-Path -Path $wrapperDir -ChildPath $browserCmd

    # Wrapper: save the URL to the temp file, then call the real browser opener
    $wrapperContent = @"
#!/bin/bash
echo "`$1" > "$authUrlFile"
exec "$realBrowserPath" "`$@"
"@
    Set-Content -Path $wrapperPath -Value $wrapperContent -Force
    chmod +x $wrapperPath

    # Prepend wrapper dir to PATH so MSAL finds our wrapper first
    $env:PATH = "${wrapperDir}:$($env:PATH)"

    Write-PSFMessage -Message "Installed browser URL capture wrapper at $wrapperPath (real: $realBrowserPath)." -Level Debug

    return @{
        AuthUrlFile     = $authUrlFile
        WrapperPath     = $wrapperPath
        WrapperDir      = $wrapperDir
        RealBrowserPath = $realBrowserPath
    }
}
