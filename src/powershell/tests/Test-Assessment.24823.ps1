
<#
.SYNOPSIS

#>



function Test-Assessment-24823 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24823,
    	Title = 'Company Portal branding and support settings enhance user experience and trust',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Test-PolicyAssignment {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false)]
            [array]$Policies
        )

        # Return false if $Policies is null or empty
        if (-not $Policies) {
            return $false
        }

        # Check if at least one policy has assignments
        $assignedPolicies = $Policies | Where-Object {
            $_.PSObject.Properties.Match("assignments") -and $_.assignments -and $_.assignments.Count -gt 0
        }

        return $assignedPolicies.Count -gt 0
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Company Portal branding and end-user support settings are customized"
    Write-ZtProgress -Activity $activity -Status "Getting branding profiles"

    # Retrieve the setting for all company branding profiles
    $brandingProfiles_Uri = "deviceManagement/intuneBrandingProfiles?`$select=id,isDefaultProfile,profileName,displayName,contactITPhoneNumber,contactITEmailAddress"
    $brandingProfiles = Invoke-ZtGraphRequest -RelativeUri $brandingProfiles_Uri -ApiVersion beta

    # Initialize variables for default and non-default profiles
    $defaultProfile = $null
    $nonDefaultProfiles = @()

    # Separate default and non-default profiles using switch statement
    foreach ($brandingProfile in $brandingProfiles) {
        switch ($brandingProfile.isDefaultProfile) {
            $true {
                $defaultProfile = $brandingProfile
            }
            $false {
                $nonDefaultProfiles += $brandingProfile
            }
        }
    }

    # Fetch assignments for non-default profiles
    $nonDefaultProfilesWithAssignments = @()
    foreach ($brandingProfile in $nonDefaultProfiles) {
        Write-ZtProgress -Activity $activity -Status "Getting assignments for profile: $($brandingProfile.profileName)"

        $assignmentsUri = "deviceManagement/intuneBrandingProfiles/{0}/assignments" -f $brandingProfile.id
        $assignments = Invoke-ZtGraphRequest -RelativeUri $assignmentsUri -ApiVersion beta

        $isAssigned = $false
        if ($assignments -and $assignments.Count -gt 0) {
            $isAssigned = $true
        }

        # Add assignment info to profile object
        $profileWithAssignments = $brandingProfile |
            Add-Member -NotePropertyName 'assignments' -NotePropertyValue $assignments -Force -PassThru |
                Add-Member -NotePropertyName 'isAssigned' -NotePropertyValue $isAssigned -Force -PassThru

        $nonDefaultProfilesWithAssignments += $profileWithAssignments
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if default profile has all required branding properties
    $defaultProfileHasAllProperties = $false
    if ($defaultProfile) {
        $defaultProfileHasAllProperties = ($defaultProfile.displayName -and
            $defaultProfile.contactITPhoneNumber -and
            $defaultProfile.contactITEmailAddress)
    }

    # Check if any non-default profiles have all branding properties and are properly assigned
    $nonDefaultProfilesWithAllProperties = $false
    if ($nonDefaultProfilesWithAssignments.Count -gt 0) {
        # Filter profiles that have all branding properties
        $profilesWithAllProperties = $nonDefaultProfilesWithAssignments | Where-Object {
            $_.displayName -and $_.contactITPhoneNumber -and $_.contactITEmailAddress
        }

        # Use Test-PolicyAssignment function to check if any of these profiles are assigned
        $nonDefaultProfilesWithAllProperties = Test-PolicyAssignment -Policies $profilesWithAllProperties
    }

    # Pass if default profile has all properties OR any non-default profile has all properties and is assigned
    $passed = $defaultProfileHasAllProperties -or $nonDefaultProfilesWithAllProperties

    if ($passed) {
        $testResultMarkdown = "At least one Company Portal branding profile with support settings exists and is assigned. Or the default custom branding profile has the required properties.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Company Portal branding profile with support settings exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Helper function to build branding properties summary
    function Get-BrandingPropertiesSummary {
        param($BrandingProfile)

        $brandingProperties = @()
        if ($BrandingProfile.displayName) {
            $brandingProperties += "**Display Name**: $($BrandingProfile.displayName)"
        }
        else {
            $brandingProperties += "**Display Name**: Not configured"
        }
        if ($BrandingProfile.contactITPhoneNumber) {
            $brandingProperties += "**Contact Phone**: $($BrandingProfile.contactITPhoneNumber)"
        }
        else {
            $brandingProperties += "**Contact Phone**: Not configured"
        }
        if ($BrandingProfile.contactITEmailAddress) {
            $brandingProperties += "**Contact Email**: $($BrandingProfile.contactITEmailAddress)"
        }
        else {
            $brandingProperties += "**Contact Email**: Not configured"
        }

        if ($brandingProperties.Count -gt 0) {
            $brandingProperties -join ", "
        }
    }

    # Define variables to insert into the format string
    $reportTitle = "Company Portal Branding Profiles"
    $tableRows = ""

    # Create a single table with all profiles
    $formatTemplate = @'

## {0}

| Profile Name | Branding Properties | Status | Assignment Target |
| :----------- | :------------------ | :----- | :---------------- |
{1}

'@

    # Combine all profiles for processing
    $allProfiles = @()
    if ($defaultProfile) {
        $allProfiles += $defaultProfile
    }
    $allProfiles += $nonDefaultProfilesWithAssignments

    # Process all profiles in a single loop
    foreach ($brandingProfile in $allProfiles) {

        $profileName = $brandingProfile.profileName

        $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminMenu/~/companyPortalBranding'

        $brandingPropertiesText = Get-BrandingPropertiesSummary -BrandingProfile $brandingProfile

        if ($brandingProfile.isDefaultProfile) {
            $status = "N/A"
            $assignmentTarget = "N/A"
        }
        else {
            $status = if ($brandingProfile.isAssigned) {
                "✅ Assigned"
            }
            else {
                "❌ Not assigned"
            }
            $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $brandingProfile.assignments
        }

        $tableRows += @"
| [$(Get-SafeMarkdown($profileName))]($portalLink) | $(Get-SafeMarkdown($brandingPropertiesText)) | $status | $assignmentTarget |`n
"@
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24823'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
