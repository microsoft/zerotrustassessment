function Add-ZtConnectedService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')]
        [string[]]
        $Service
    )

    foreach ($svc in $Service) {
        if ($script:ConnectedService -notcontains $svc) {
            $script:ConnectedService += $svc
        }
    }
}
