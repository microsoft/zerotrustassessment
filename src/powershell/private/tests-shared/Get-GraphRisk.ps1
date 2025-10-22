function Get-GraphRisk {
    [CmdletBinding()]
    param (
        $delegatePermissions,
        $applicationPermissions
    )
    $finalRisk = "Unranked"
    $hasPermissions = $false

    foreach($permission in $applicationPermissions){
        $hasPermissions = $true
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
        $hasPermissions = $true
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

    # If we have permissions but none are classified, mark as Low
    # If no permissions at all, remain Unranked
    if ($hasPermissions -and $finalRisk -eq "Unranked") {
        $finalRisk = "Low"
    }

    return $finalRisk
}
