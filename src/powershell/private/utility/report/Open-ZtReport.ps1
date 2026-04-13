function Open-ZtReport {
    <#
    .SYNOPSIS
        Opens the assessment report, using an HTTP server in containers for VS Code port forwarding.
    .DESCRIPTION
        In container environments, local file:// paths don't work in the browser.
        This function starts a lightweight HTTP server and opens the forwarded URL instead.
        On non-container environments, opens the file directly.
        Always displays a clickable link in the terminal.
    .PARAMETER FilePath
        The path to the HTML report file.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $FilePath
    )

    $authReadiness = $script:ZtContainerAuthReadiness
    $isContainer = if ($authReadiness) { $authReadiness.IsContainer } else { Test-ZtContainerEnvironment }

    if ($isContainer) {
        $reportServer = Start-ZtReportServer -FilePath $FilePath
        if ($reportServer) {
            $null = Open-ZtFile -Path $reportServer.Url
            Write-Host "   🌐 Report: $($reportServer.Url)" -ForegroundColor Green
            Write-Host "      Server will auto-stop after 30 minutes. Run Stop-ZtReportServer to stop earlier." -ForegroundColor DarkGray
            return
        }
    }

    # Non-container or server failed to start — open file directly
    $null = Open-ZtFile -Path $FilePath
    Write-Host "   🌐 Report: $FilePath" -ForegroundColor Green
}
