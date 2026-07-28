function Get-ZtTestResultDetail {
    <#
    .SYNOPSIS
        Gets a completed assessment result from the current assessment session.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $TestId
    )

    if ($script:__ZtSession -and $script:__ZtSession.TestResultDetail) {
        return $script:__ZtSession.TestResultDetail.Value[$TestId]
    }
}
