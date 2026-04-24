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
            $group = Invoke-ZtGraphRequest -RelativeUri "groups/$groupId" -Select "displayName" -ErrorAction Stop
            if ($group) {
                $result = $group.displayName
            }
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in @(404, 410)) {
                # Group no longer exists but the assignment still references it.
                # Fall back to displaying the raw groupId so report generation can continue.
                Write-PSFMessage -Message "Get-ZtAssignmentText: Unable to resolve group 'groups/$groupId'." -Level Verbose -Tag Graph -ErrorRecord $_
            }
            else {
                throw
            }
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
