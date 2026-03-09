function Get-ZtAssignmentText {
    [CmdletBinding()]
    param (
        $assignments
    )

    function Get-GroupName {
        [CmdletBinding()]
        param (
            $groupId
        )
        $result = $groupId
        $group = Invoke-ZtGraphRequest -RelativeUri "groups/$groupId" -ErrorAction SilentlyContinue
        if ($group) {
            $result = $group.displayName
        }

        return $result
    }

    $text = @()

    foreach ($assignment in $assignments) {
        switch ($assignment.target.'@odata.type') {
            '#microsoft.graph.allLicensedUsersAssignmentTarget' {
                $text += "All users"
            }

            '#microsoft.graph.allDevicesAssignmentTarget' {
                $text += "All devices"
            }

            '#microsoft.graph.groupAssignmentTarget' {
                $text += Get-GroupName $assignment.target.groupId
            }

            default {
                $text += "Unknown target"
            }
        }
    }
    return $text -join ", "
}
