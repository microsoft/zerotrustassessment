function Get-ZtContainerAuthFailureHint {
    <#
    .SYNOPSIS
        Returns a user-friendly hint when Graph auth succeeds but no context is established.
    .DESCRIPTION
        When Connect-MgGraph completes without error but Get-MgContext returns null,
        this typically means the MSAL callback (browser redirect to localhost) did not
        reach the container. This function returns an appropriate message based on
        whether the session is running in a container.
    .OUTPUTS
        [string] A hint message suggesting next steps.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $msg = "Connect-MgGraph completed but no auth context was established."

    $authReadiness = $script:ZtContainerAuthReadiness
    if ($authReadiness -and $authReadiness.IsContainer) {
        $msg += " The browser authentication callback may not have reached this container. Try using device code flow: Connect-ZtAssessment -UseDeviceCode"
    }

    return $msg
}
