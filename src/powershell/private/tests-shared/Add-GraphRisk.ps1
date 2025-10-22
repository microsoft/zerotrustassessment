function Add-GraphRisk {
    [CmdletBinding()]
    param (
        $item
    )
    $item.Risk = Get-GraphRisk -delegatePermissions $item.DelegatePermissions -applicationPermissions $item.AppPermissions
    $item.IsRisky = $item.Risk -eq "High" -or $item.Risk -eq "Medium" -or $item.Risk -eq "Low"
    return $item
}
