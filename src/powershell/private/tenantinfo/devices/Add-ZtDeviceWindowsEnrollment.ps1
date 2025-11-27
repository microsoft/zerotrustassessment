
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

    # Initialize table data structure
    $tableData = @()

    try {
        # The Policies/MobileDeviceManagementPolicies endpoint requires delegated permissions
        # and is not supported with application-only authentication (service principal)
        $policies = Invoke-ZtGraphRequest -RelativeUri 'Policies/MobileDeviceManagementPolicies' -QueryParameters @{ '$expand' = 'includedGroups' } -ApiVersion 'beta'

        # Sort policies by AppliesTo (descending) then by DisplayName (ascending)
        $sortedPolicies = $policies | Sort-Object @{Expression='appliesTo';Descending=$true}, @{Expression='displayName';Ascending=$true}

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
    }
    catch {
        # Check if this is an authorization error
        $authType = (Get-MgContext).AuthType
        if ($_.Exception.Message -match "(Unauthorized|403|401)" -or $_.Exception.Message -match "Insufficient privileges") {
            if ($authType -eq 'AppOnly') {
                Write-PSFMessage -Level Warning -Message "Windows enrollment policies could not be retrieved. The 'Policies/MobileDeviceManagementPolicies' endpoint requires delegated permissions and is not supported with service principal authentication. This section will be skipped."
            } else {
                Write-PSFMessage -Level Warning -Message "Windows enrollment policies could not be retrieved due to insufficient permissions. Ensure the current user has the required permissions to access Mobile Device Management policies. This section will be skipped."
            }
        } else {
            # For other types of errors, log the full error but continue execution
            Write-PSFMessage -Level Warning -Message "Failed to retrieve Windows enrollment policies: $($_.Exception.Message). This section will be skipped."
        }

        # Continue with empty data to prevent the entire assessment from failing
        Write-PSFMessage -Level Debug -Message "Continuing assessment without Windows enrollment policy data"
    }

    Add-ZtTenantInfo -Name "ConfigWindowsEnrollment" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
