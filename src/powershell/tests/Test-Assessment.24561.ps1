<#
.SYNOPSIS
    A macOS Cloud LAPS Policy is Created and Assigned
#>

function Test-Assessment-24561 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Intune'),
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24561,
    	Title = 'A macOS Cloud LAPS Policy is Created and Assigned',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = "Checking that a macOS Cloud LAPS Policy is Created and Assigned"
    Write-ZtProgress -Activity $activity -Status "Getting DEP tokens"

    # Retrieve all macOS Enrollment Program Tokens
    $depTokensUri = "deviceManagement/depOnboardingSettings?`$expand=enrollmentProfiles&`$select=id,appleIdentifier,tokenName"
    $depTokens = Invoke-ZtGraphRequest -RelativeUri $depTokensUri -ApiVersion beta

    $allEnrollmentProfiles = @()
    $profilesWithLAPS = @()
    $profilesWithAssignments = @()

    if ($depTokens -and $depTokens.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status "Processing DEP tokens and enrollment profiles"

        # For each DEP token, get enrollment profiles and check for LAPS configuration
        foreach ($token in $depTokens) {
            $tokenId = $token.id

            # Get enrollment profiles for this token
            $enrollmentProfilesUri = "deviceManagement/depOnboardingSettings/$tokenId/enrollmentProfiles"
            $enrollmentProfiles = Invoke-ZtGraphRequest -RelativeUri $enrollmentProfilesUri -ApiVersion beta

            if ($enrollmentProfiles -and $enrollmentProfiles.Count -gt 0) {
                foreach ($enrollmentProfile in $enrollmentProfiles) {
                    $profileData = [PSCustomObject]@{
                        TokenId              = $tokenId
                        TokenName            = $token.tokenName
                        AppleIdentifier      = $token.appleIdentifier
                        ProfileId            = $enrollmentProfile.id
                        ProfileName          = $enrollmentProfile.displayName
                        AdminAccountUserName = $enrollmentProfile.adminAccountUserName
                        HasLAPS              = -not [string]::IsNullOrWhiteSpace($enrollmentProfile.adminAccountUserName)
                        IsAssigned           = $false
                        AssignmentCount      = 0
                    }

                    $allEnrollmentProfiles += $profileData

                    # Track profiles with LAPS configured
                    if ($profileData.HasLAPS) {
                        $profilesWithLAPS += $profileData

                        # Check profile assignment
                        Write-ZtProgress -Activity $activity -Status "Checking assignments for profile: $($enrollmentProfile.displayName)"

                        # Extract profile ID from the enrollment profile ID
                        # Enrollment profile IDs are in the format "<tokenId>_<profileId>"
                        $profileId = ($enrollmentProfile.id -split '_')[1]

                        $assignmentsUri = "deviceManagement/depOnboardingSettings/$tokenId/importedAppleDeviceIdentities?`$top=5&`$filter=discoverySource eq 'deviceEnrollmentProgram' and requestedEnrollmentProfileId eq '$profileId'"
                        $assignments = Invoke-ZtGraphRequest -RelativeUri $assignmentsUri -ApiVersion beta

                        if ($assignments -and $assignments.Count -gt 0) {
                            $profileData.IsAssigned = $true
                            $profileData.AssignmentCount = $assignments.Count
                            $profilesWithAssignments += $profileData
                        }
                    }
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    if ($null -eq $depTokens -or $depTokens.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "No macOS DEP tokens found in the tenant.`n`n%TestResult%"
    }
    elseif ($allEnrollmentProfiles.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "DEP tokens exist but no enrollment profiles are configured.`n`n%TestResult%"
    }
    elseif ($profilesWithLAPS.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "Enrollment profiles exist but none have Cloud LAPS (adminAccountUserName) configured.`n`n%TestResult%"
    }
    elseif ($profilesWithAssignments.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "Cloud LAPS policies exist but none are assigned to devices.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "At least one macOS cloud LAPS policy exists and is assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    $mdInfo = ""

    # Define variables to insert into the format string
    $reportTitle = "macOS DEP Tokens and Enrollment Profiles"

    if ($depTokens -and $depTokens.Count -gt 0) {
        $mdInfo += "`n`n## DEP Tokens`n`n"
        $mdInfo += "Found $($depTokens.Count) macOS Device Enrollment Program token(s).`n`n"

        if ($allEnrollmentProfiles.Count -gt 0) {
            $formatTemplate = @'

## {0}

| Token Name | Profile Name | LAPS Admin Account | Assigned |
| :--------- | :----------- | :----------------- | :------- |
{1}

'@

            $tableRows = ""
            foreach ($profileData in $allEnrollmentProfiles) {
                $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Enrollment/DepTokensPaging.ReactView'

                $tokenName = Get-SafeMarkdown -Text $profileData.TokenName
                $profileName = Get-SafeMarkdown -Text $profileData.ProfileName
                $adminAccount = if ($profileData.HasLAPS) {
                    Get-SafeMarkdown -Text $profileData.AdminAccountUserName
                }
                else {
                    "❌ Not configured"
                }
                $assignedStatus = if ($profileData.IsAssigned) {
                    "✅ Assigned"
                }
                elseif ($profileData.HasLAPS) {
                    "❌ Not assigned"
                }
                else {
                    "N/A"
                }

                $tableRows += "| [$tokenName]($portalLink) | $profileName | $adminAccount | $assignedStatus |`n"
            }

            # Format the template by replacing placeholders with values
            $mdInfo += $formatTemplate -f $reportTitle, $tableRows
        }
        else {
            $mdInfo += "No enrollment profiles found for the DEP tokens.`n`n"
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24561'
        Title  = 'A macOS Cloud LAPS Policy is Created and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
