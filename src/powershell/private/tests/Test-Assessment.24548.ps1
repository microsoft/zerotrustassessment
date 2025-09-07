<#
.SYNOPSIS
    An app protection policy for iOS devices exists
#>

function Test-Assessment-24548 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking that an app protection policy for iOS devices exists"
    Write-ZtProgress -Activity $activity

    $iosAppProtectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections?$expand=assignments' -ApiVersion v1.0
    $iosAppProtectionPolicies.Foreach{
        $_ | Add-Member -MemberType NoteProperty -Name PortalUrl -Value ("https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection" -f $null) -Force
    }

    $iosAppProtectionPolicies.assignments.Foreach{
        # Resolve group display names for each assignment of each policy
        $groupId = $_.target.groupId
        $groupDisplayName = (Invoke-ZtGraphRequest -RelativeUri ('groups/{0}?$select=displayName' -f $groupId) -ApiVersion v1.0).displayName
        # Add the display name as extra property to the assignment object
        $_ | Add-Member -MemberType NoteProperty -Name displayName -Value $groupDisplayName -Force
    }

    $passed = $iosAppProtectionPolicies.Count -ne 0 -and $iosAppProtectionPolicies.Where{$_.IsAssigned -eq $true}.count -ne 0

    if ($passed) {
        $testResultMarkdown = "At least one App protection policy for iOS exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No App protection policy for iOS exists or none are assigned.`n`n%TestResult%"
    }

    if ($iosAppProtectionPolicies.Count -gt 0) {
        $mdInfo = "`n## iOS App Protection policies configured for iOS`n`n"
        $mdInfo += "| Display Name | Status | Assignments |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($item in $iosAppProtectionPolicies) {
            $excluded = $item.assignments.where{$_.target.'@odata.type' -eq '#microsoft.graph.exclusionGroupAssignmentTarget'}
            $included = $item.assignments.where{$_.target.'@odata.type' -eq '#microsoft.graph.groupAssignmentTarget'}
            $status = if ($item.IsAssigned) { '✅ Assigned' } else { '❌ Not Assigned' }
            $policyName = Get-SafeMarkdown -Text $item.displayName
            $includedNames = $included.displayName.Foreach{ Get-SafeMarkdown -Text $_ } -join ', '
            $excludedNames = $excluded.displayName.Foreach{ Get-SafeMarkdown -Text $_ } -join ', '
            $mdInfo += '| [**{0}**]({1}) | {2} | **Included**: {3}, **Excluded:**  {4}. |`n' -f $policyName, $item.PortalUrl, $status, $includedNames, $excludedNames
        }
    }
    else {
        $mdInfo = "`nNo iOS App Protection policies were found.`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '24548'
        Title              = "An app protection policy for iOS devices exists"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
