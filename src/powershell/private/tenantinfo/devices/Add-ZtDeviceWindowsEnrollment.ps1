
<#
.SYNOPSIS
    Add Windows enrollment summary used in Devices config view.
#>

function Add-ZtDeviceWindowsEnrollment
{
	[CmdletBinding()]
	param (

	)

    $activity = "Getting Windows enrollment summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $policies = Invoke-ZtGraphRequest -RelativeUri 'Policies/MobileDeviceManagementPolicies' -QueryParameters @{ '$expand' = 'includedGroups' } -ApiVersion 'beta'

    # Sort policies by AppliesTo (descending) then by DisplayName (ascending)
    $sortedPolicies = $policies | Sort-Object @{Expression='appliesTo';Descending=$true}, @{Expression='displayName';Ascending=$true}

    # Create the table data structure
    $tableData = @()
    foreach ($policy in $sortedPolicies) {
        # Determine group names display
        $groupNames = if ($policy.appliesTo -eq 'selected' -and $policy.includedGroups) {
            ($policy.includedGroups | ForEach-Object { $_.displayName }) -join ', '
        } else {
            'Not Applicable'
        }

        # Convert AppliesTo to friendly name
        $appliesToName = switch ($policy.appliesTo) {
            'all' { 'All' }
            'selected' { 'Selected' }
            'none' { 'None' }
            default { $policy.appliesTo }
        }

        $tableData += [PSCustomObject]@{
            Type = 'MDM'
            PolicyName = $policy.displayName
            AppliesTo = $appliesToName
            Groups = $groupNames
        }
    }

    Add-ZtTenantInfo -Name "ConfigWindowsEnrollment" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
