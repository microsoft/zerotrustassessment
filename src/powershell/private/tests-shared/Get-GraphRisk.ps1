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
            "Low" {
                if ($finalRisk -eq "Unranked") {
                    $finalRisk = $risk
                }
            }
        }
    }
    foreach($permission in $delegatePermissions){
        $risk = Get-GraphPermissionRisk -Permission $permission -PermissionType "Delegated"
        switch($risk){
            "High" { return $risk }
            "Medium" { $finalRisk = $risk }
            "Low" {
                if ($finalRisk -eq "Unranked") {
                    $finalRisk = $risk
                }
            }
        }
    }
    return $finalRisk
}
