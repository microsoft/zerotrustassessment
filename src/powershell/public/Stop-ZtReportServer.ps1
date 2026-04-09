function Stop-ZtReportServer {
    <#
    .SYNOPSIS
        Stops the background report HTTP server if one is running.
    #>
    [CmdletBinding()]
    param ()

    $state = $script:ZtReportServer
    if ($state -and $state.Job) {
        $state.Job.Stop()
        $state.Job.Dispose()
        $script:ZtReportServer = $null
        Write-PSFMessage -Message "Report server stopped." -Level Debug
    }
}
