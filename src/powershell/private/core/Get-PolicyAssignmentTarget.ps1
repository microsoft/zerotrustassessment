function Get-PolicyAssignmentTarget {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		$Assignments
	)

	if (-not $Assignments -or $Assignments.Count -eq 0) {
		return "None"
	}

	$includedTargets = @()
	$excludedTargets = @()

	foreach ($assignment in $Assignments) {
		$isExcluded = $assignment.target.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget'

		if ($assignment.target.groupId -and $assignment.target.groupId -ne "") {
			$groupName = Invoke-ZtGraphRequest -RelativeUri "groups/$($assignment.target.groupId)?`$select=displayName" -ApiVersion v1.0
			if ($isExcluded) {
				$excludedTargets += $groupName.displayName
			}
			else {
				$includedTargets += $groupName.displayName
			}
		}
		elseif ($assignment.target.'@odata.type' -eq '#microsoft.graph.allDevicesAssignmentTarget') {
			$includedTargets += "All Devices"
		}
		elseif ($assignment.target.'@odata.type' -eq '#microsoft.graph.allLicensedUsersAssignmentTarget') {
			$includedTargets += "All Users"
		}
	}

	# Build grouped assignment target string
	$assignmentParts = @()
	if ($includedTargets.Count -gt 0) {
		Add-Member -InputObject $Assignments -MemberType NoteProperty -Name IncludedTargets -Value $includedTargets -Force
		$assignmentParts += "**Included:** " + ($includedTargets -join ", ")
	}

	if ($excludedTargets.Count -gt 0) {
		Add-Member -InputObject $Assignments -MemberType NoteProperty -Name ExcludedTargets -Value $excludedTargets -Force
		$assignmentParts += "**Excluded:** " + ($excludedTargets -join ", ")
	}

	if ($assignmentParts.Count -gt 0) {
		return $assignmentParts -join ", "
	}
	else {
		Add-Member -InputObject $Assignments -MemberType NoteProperty -Name AssignmentSummary -Value "None" -Force
		return "None"
	}
}
