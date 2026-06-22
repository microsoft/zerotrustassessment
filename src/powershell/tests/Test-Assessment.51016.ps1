<#
.SYNOPSIS
    Privileged Identity Management is enforced for Intune Administrator role assignments.

.DESCRIPTION
    Checks that no enabled Member user holds a permanent standing Intune Administrator role
    assignment, and that the PIM activation policy for the role enforces MFA, justification,
    and a bounded activation duration (≤ PT8H).

    Four queries are executed:
    Q1 – Fetch the Intune Administrator role definition by templateId (3a2c62db-5318-420d-8d74-23affee5d9d5).
    Q2 – List roleAssignmentScheduleInstances for the role; count permanent standing enabled-Member
         assignments (assignmentType = 'Assigned', endDateTime = null).
    Q3 – List roleEligibilitySchedules for the role (informational, does not drive Pass/Fail).
    Q4 – Fetch the roleManagementPolicyAssignment and inspect Enablement_EndUser_Assignment and
         Expiration_EndUser_Assignment activation rules.

.NOTES
    Test ID: 51016
    Category: Devices
    Pillar: Devices
    Required API permissions: Directory.Read.All, RoleManagement.Read.All
#>

function Test-Assessment-51016 {
    [ZtTest(
        Category = 'Devices',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Low',
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51016,
        Title = 'Privileged Identity Management is enforced for Intune Administrator role assignments',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $intuneAdminTemplateId = '3a2c62db-5318-420d-8d74-23affee5d9d5'
    $activity = 'Checking PIM enforcement for Intune Administrator role assignments'
    $investigateParams = @{
        TestId       = '51016'
        Title        = 'Privileged Identity Management is enforced for Intune Administrator role assignments'
        Status       = $false
        Result       = '⚠️ The Microsoft Entra Privileged Identity Management API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
        CustomStatus = 'Investigate'
    }

    # Q1: Fetch the Intune Administrator role definition by its well-known templateId.
    # For built-in directory roles, id == templateId, so a direct GET avoids $filter requirements.
    Write-ZtProgress -Activity $activity -Status 'Getting Intune Administrator role definition'

    $roleDefinition = $null
    try {
        $roleDefinition = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/roleDefinitions/$intuneAdminTemplateId" -ApiVersion beta -ErrorAction Stop
    }
    catch {
        Add-ZtTestResultDetail @investigateParams
        return
    }

    if (-not $roleDefinition) {
        $params = @{
            TestId = '51016'
            Title  = 'Privileged Identity Management is enforced for Intune Administrator role assignments'
            Status = $false
            Result = '❌ The Intune Administrator role definition was not found in this tenant. Verify the tenant has Microsoft Entra RBAC access and the required permissions.'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $intuneAdminRoleId = $roleDefinition.id

    # Q2: Enumerate roleAssignmentScheduleInstances for the Intune Administrator role.
    # assignmentType = 'Assigned' = permanent standing access; 'Activated' = time-bound PIM activation.
    Write-ZtProgress -Activity $activity -Status 'Getting role assignment schedule instances'

    $assignmentInstances = @()
    try {
        $assignmentInstances = @(Invoke-ZtGraphRequest `
            -RelativeUri 'roleManagement/directory/roleAssignmentScheduleInstances' `
            -Filter "roleDefinitionId eq '$intuneAdminRoleId'" `
            -QueryParameters @{ '$expand' = 'principal' } `
            -ApiVersion beta `
            -ErrorAction Stop)
    }
    catch {
        Add-ZtTestResultDetail @investigateParams
        return
    }

    # Q3: Enumerate roleEligibilitySchedules (informational only — does not drive Pass/Fail).
    # Note: roleEligibilitySchedules is used instead of roleEligibilityScheduleInstances because
    # the latter does not accept roleDefinitionId as a $filter parameter.
    Write-ZtProgress -Activity $activity -Status 'Getting PIM eligible assignments'

    $eligibilitySchedules = @()
    try {
        $eligibilitySchedules = @(Invoke-ZtGraphRequest `
            -RelativeUri 'roleManagement/directory/roleEligibilitySchedules' `
            -Filter "roleDefinitionId eq '$intuneAdminRoleId'" `
            -QueryParameters @{ '$expand' = 'principal' } `
            -ApiVersion beta `
            -ErrorAction Stop)
    }
    catch {
        Add-ZtTestResultDetail @investigateParams
        return
    }

    # Q4: Retrieve the role-management policy assignment and expand activation rules.
    Write-ZtProgress -Activity $activity -Status 'Getting role management activation policy'

    $policyAssignment = $null
    try {
        $policyFilter = "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$intuneAdminRoleId'"
        $policyResults = @(Invoke-ZtGraphRequest `
            -RelativeUri 'policies/roleManagementPolicyAssignments' `
            -Filter $policyFilter `
            -QueryParameters @{ '$expand' = 'policy($expand=rules)' } `
            -ApiVersion beta `
            -ErrorAction Stop)
        if ($policyResults.Count -gt 0) {
            $policyAssignment = $policyResults[0]
        }
    }
    catch {
        Add-ZtTestResultDetail @investigateParams
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Fail fast: no Q4 policy assignment found
    if (-not $policyAssignment) {
        $params = @{
            TestId = '51016'
            Title  = 'Privileged Identity Management is enforced for Intune Administrator role assignments'
            Status = $false
            Result = '❌ No PIM role-management policy assignment was found for the Intune Administrator role. The role has no activation policy bound — PIM is not enforced.'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Extract activation policy rules from Q4
    $rules          = $policyAssignment.policy.rules
    $enablementRule = $rules | Where-Object { $_.id -eq 'Enablement_EndUser_Assignment' }
    $expirationRule = $rules | Where-Object { $_.id -eq 'Expiration_EndUser_Assignment' }

    # Evaluate Q4 enablement controls
    $hasMfa               = $enablementRule -and ($enablementRule.enabledRules -contains 'MultiFactorAuthentication')
    $hasJustification     = $enablementRule -and ($enablementRule.enabledRules -contains 'Justification')
    $isExpirationRequired = $expirationRule -and ($expirationRule.isExpirationRequired -eq $true)

    # Parse maximumDuration and compare against PT8H (28800 seconds)
    $maxDurationRaw     = $expirationRule.maximumDuration
    $maxDurationSeconds = 0
    $maxDurationOk      = $false
    if ($isExpirationRequired -and $maxDurationRaw) {
        if ($maxDurationRaw -match '^P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$') {
            $days    = if ($Matches[1]) { [int]$Matches[1] } else { 0 }
            $hours   = if ($Matches[2]) { [int]$Matches[2] } else { 0 }
            $minutes = if ($Matches[3]) { [int]$Matches[3] } else { 0 }
            $secs    = if ($Matches[4]) { [int]$Matches[4] } else { 0 }
            $maxDurationSeconds = $days * 86400 + $hours * 3600 + $minutes * 60 + $secs
        }
        $maxDurationOk = ($maxDurationSeconds -gt 0) -and ($maxDurationSeconds -le 28800)
    }

    # Q2: Count permanent standing enabled-Member assignments.
    # Criteria: assignmentType='Assigned', endDateTime=null, principal is enabled Member user.
    $permanentStandingAssignments = @(
        $assignmentInstances | Where-Object {
            $_.assignmentType -eq 'Assigned' -and
            $null -eq $_.endDateTime -and
            $_.principal.'@odata.type' -eq '#microsoft.graph.user' -and
            $_.principal.userType -eq 'Member' -and
            $_.principal.accountEnabled -eq $true
        }
    )
    $permanentStandingCount = $permanentStandingAssignments.Count

    $passed = $hasMfa -and $hasJustification -and $isExpirationRequired -and $maxDurationOk -and ($permanentStandingCount -eq 0)

    if ($passed) {
        $testResultMarkdown = '✅ The Intune Administrator role is managed with safe privileged-access controls — no enabled Member user has standing permanent Intune Administrator access, and PIM activations require MFA, justification, and a bounded duration.'
    }
    else {
        $testResultMarkdown = '❌ The Intune Administrator role is not adequately protected — either the tenant has no Microsoft Entra ID P2 license (so PIM cannot be configured at all), one or more enabled Member users has standing permanent Intune Administrator access, or the activation policy is missing MFA / justification / duration limits.'
    }
    $testResultMarkdown += "`n`n%TestResult%"
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ResourceMenuBlade/~/aadmigratedroles'

    # --- Table 1: PIM Eligibility (Q3) — informational ---
    $eligibilityRows = ''
    if ($eligibilitySchedules.Count -gt 0) {
        $displaySchedules = if ($eligibilitySchedules.Count -gt 20) { $eligibilitySchedules[0..19] } else { $eligibilitySchedules }
        foreach ($schedule in $displaySchedules) {
            $principalName = Get-SafeMarkdown -Text ($schedule.principal.displayName ?? $schedule.principalId)
            $odataType     = $schedule.principal.'@odata.type'
            $principalType = if ($odataType) { $odataType -replace '#microsoft.graph\.', '' } else { 'Unknown' }
            $memberType    = if ($schedule.memberType) { $schedule.memberType } else { '-' }
            $startDt       = if ($schedule.startDateTime) { Get-FormattedDate $schedule.startDateTime } else { 'N/A' }
            $endDt         = if ($schedule.endDateTime)   { Get-FormattedDate $schedule.endDateTime }   else { 'Permanent' }
            $eligibilityRows += "| $principalName | $principalType | $memberType | $startDt → $endDt | ℹ️ Informational |`n"
        }
        if ($eligibilitySchedules.Count -gt 20) {
            $eligibilityRows += "| ... ($($eligibilitySchedules.Count) total) | | | | |`n"
        }
    }
    else {
        $activatedCount = @($assignmentInstances | Where-Object { $_.assignmentType -eq 'Activated' }).Count
        if ($activatedCount -gt 0) {
            $eligibilityRows = "| *(No persisted eligibility schedules, but $activatedCount current PIM activation(s) confirm PIM is in use)* | | | | |`n"
        }
        else {
            $eligibilityRows = "| *No eligible assignments found* | | | | |`n"
        }
    }

    # --- Table 2: Activation policy rules (Q4) ---
    $mfaValue    = if ($hasMfa) { 'Yes' } else { 'No' }
    $mfaStatus   = if ($hasMfa) { '✅ Pass' } else { '❌ Fail' }
    $justValue   = if ($hasJustification) { 'Yes' } else { 'No' }
    $justStatus  = if ($hasJustification) { '✅ Pass' } else { '❌ Fail' }
    $expireValue = if ($isExpirationRequired) { 'true' } else { 'false' }
    $expireStatus = if ($isExpirationRequired) { '✅ Pass' } else { '❌ Fail' }

    $durationDisplayValue = if ($maxDurationRaw) { $maxDurationRaw } else { 'Not set' }
    $durationStatus = if ($maxDurationOk) {
        '✅ Pass'
    }
    elseif (-not $isExpirationRequired) {
        '❌ Fail (expiration not required)'
    }
    elseif ($maxDurationSeconds -eq 0) {
        '❌ Fail (duration not parseable)'
    }
    else {
        "❌ Fail ($durationDisplayValue exceeds PT8H)"
    }

    $policyRows  = "| Enablement | MFA on activation | $mfaValue | Yes | $mfaStatus |`n"
    $policyRows += "| Enablement | Justification required | $justValue | Yes | $justStatus |`n"
    $policyRows += "| Expiration | Activation must expire | $expireValue | true | $expireStatus |`n"
    $policyRows += "| Expiration | Maximum activation duration | $durationDisplayValue | ≤PT8H | $durationStatus |`n"

    # --- Table 3: Standing permanent assignments (Q2) ---
    $standingRows = ''
    if ($assignmentInstances.Count -gt 0) {
        $displayInstances = if ($assignmentInstances.Count -gt 20) { $assignmentInstances[0..19] } else { $assignmentInstances }
        foreach ($instance in $displayInstances) {
            $principalName = Get-SafeMarkdown -Text ($instance.principal.displayName ?? $instance.principalId)
            $upn           = if ($instance.principal.userPrincipalName) { $instance.principal.userPrincipalName } else { '-' }
            $assignType    = if ($instance.assignmentType) { $instance.assignmentType } else { '-' }
            $memberType    = if ($instance.memberType) { $instance.memberType } else { '-' }
            $endTime       = if ($null -eq $instance.endDateTime) { 'Permanent' } else { Get-FormattedDate $instance.endDateTime }
            $accountEnabled = if ($instance.principal.accountEnabled -eq $true) { 'Yes' } else { 'No' }

            $isPermanentStanding = (
                $instance.assignmentType -eq 'Assigned' -and
                $null -eq $instance.endDateTime -and
                $instance.principal.'@odata.type' -eq '#microsoft.graph.user' -and
                $instance.principal.userType -eq 'Member' -and
                $instance.principal.accountEnabled -eq $true
            )
            $rowStatus = if ($isPermanentStanding) { '❌ Fail' } else { '✅ Pass' }
            $standingRows += "| $principalName | $upn | $assignType | $memberType | $endTime | $accountEnabled | $rowStatus |`n"
        }
        if ($assignmentInstances.Count -gt 20) {
            $standingRows += "| ... ($($assignmentInstances.Count) total) | | | | | | |`n"
        }
    }
    else {
        $standingRows = "| *No role assignments found* | | | | | | |`n"
    }

    $mdInfo  = "`n## [Intune Administrator — PIM Eligibility (Q3)]($portalUrl)`n`n"
    $mdInfo += "| Principal | Type | Member Type | Eligibility Window | Status |`n"
    $mdInfo += "| :-------- | :--- | :---------- | :----------------- | :----- |`n"
    $mdInfo += $eligibilityRows
    $mdInfo += "`n## [Activation Policy Rules (Q4)]($portalUrl)`n`n"
    $mdInfo += "| Rule | Setting | Value | Required Value | Status |`n"
    $mdInfo += "| :--- | :------ | :---- | :------------- | :----- |`n"
    $mdInfo += $policyRows
    $mdInfo += "`n## [Standing Permanent Assignments (Q2)]($portalUrl)`n`n"
    $mdInfo += "| Principal | UPN | Assignment Type | Member Type | End Time | Enabled | Status |`n"
    $mdInfo += "| :-------- | :-- | :-------------- | :---------- | :------- | :------ | :----- |`n"
    $mdInfo += $standingRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51016'
        Title  = 'Privileged Identity Management is enforced for Intune Administrator role assignments'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
