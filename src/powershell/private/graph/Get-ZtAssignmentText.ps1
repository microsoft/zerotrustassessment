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
        try {
            $group = Invoke-ZtGraphRequest -RelativeUri "groups/$groupId" -ErrorAction Stop
            if ($group) {
                $result = $group.displayName
            }
        }
        catch {
            # Group lookup failed (e.g. group was deleted but assignment still references it).
            # Fall back to displaying the raw groupId so report generation can continue.
            Write-PSFMessage "Get-ZtAssignmentText: Unable to resolve group 'groups/$groupId'. $_" -Level Verbose -Tag Graph
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
