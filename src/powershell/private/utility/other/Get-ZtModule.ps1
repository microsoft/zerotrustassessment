function Get-ZtModule {
    [CmdletBinding()]
    param ()

    $myInvocation.MyCommand.Module
}
