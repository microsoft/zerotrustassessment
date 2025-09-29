function Add-GraphRisk {
    [CmdletBinding()]
    param (
        $item
    )
    $item.Risk = Get-GraphRisk -delegatePermissions $item.DelegatePermissions -applicationPermissions $item.AppPermissions
    $item.IsRisky = $item.Risk -eq "High"
    return $item
}

function Get-GraphRisk {
    [CmdletBinding()]
    param (
        $delegatePermissions,
        $applicationPermissions
    )
    $finalRisk = "Unranked"
    foreach($permission in $applicationPermissions){
        $risk = Get-GraphPermissionRisk -Permission $permission -PermissionType "Application"
        switch($risk){
            "High" { return $risk }
            "Medium" { $finalRisk = $risk }
        }
    }
    foreach($permission in $delegatePermissions){
        $risk = Get-GraphPermissionRisk -Permission $permission -PermissionType "Delegated"
        switch($risk){
            "High" { return $risk }
            "Medium" { $finalRisk = $risk }
        }
    }
    return $finalRisk
}
