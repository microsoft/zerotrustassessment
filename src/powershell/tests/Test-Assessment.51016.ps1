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
        CompatibleLicense = ('INTUNE_A&AAD_PREMIUM_P2'),
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

    #region Helper Functions
    # Calls Add-ZtTestResultDetail and returns $true when the exception is 401/403/5xx.
    # Returns $false for all other errors so the caller can rethrow.
    function Test-ZtPimHttpError {
        param($Err, $Params)
        $status = Get-ZtHttpStatusCode -ErrorRecord $Err

        if ($status -eq 401 -or $status -eq 403 -or $status -ge 500) {
            Add-ZtTestResultDetail @Params
            return $true
        }
        return $false
    }
    #endregion Helper Functions

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
        if (Test-ZtPimHttpError -Err $_ -Params $investigateParams) { return }
        throw
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
        if (Test-ZtPimHttpError -Err $_ -Params $investigateParams) { return }
        throw
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
        if (Test-ZtPimHttpError -Err $_ -Params $investigateParams) { return }
        throw
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
        if (Test-ZtPimHttpError -Err $_ -Params $investigateParams) { return }
        throw
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

    # Parse maximumDuration and compare against PT8H (8 hours).
    # [System.Xml.XmlConvert]::ToTimeSpan() handles ISO 8601 durations natively.
    $maxDurationRaw    = $expirationRule.maximumDuration
    $maxDurationOk     = $false
    $maxDurationParsed = $false
    if ($isExpirationRequired -and $maxDurationRaw) {
        try {
            $maxDuration       = [System.Xml.XmlConvert]::ToTimeSpan($maxDurationRaw)
            $maxDurationParsed = $true
            $maxDurationOk     = $maxDuration.TotalSeconds -gt 0 -and $maxDuration.TotalSeconds -le 28800
        }
        catch { }
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
        $testResultMarkdown = '❌ The Intune Administrator role is not adequately protected — one or more enabled Member users has standing permanent Intune Administrator access, or the activation policy is missing MFA / justification / duration limits.'
    }
    $testResultMarkdown += "`n`n%TestResult%"
    #endregion Assessment Logic

    #region Report Generation
    $tenantId          = (Get-MgContext).TenantId
    $portalUrl         = "https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/members/menuId/members/roleName/Intune%20Administrator/roleObjectId/$intuneAdminRoleId/isRoleCustom~/false/roleTemplateId/$intuneAdminRoleId/resourceId/$tenantId/isInternalCall~/true"
    $roleSettingsPortalUrl = "https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/UserRolesViewModelMenuBlade/~/settings/menuId/members/roleName/Intune%20Administrator/roleObjectId/$intuneAdminRoleId/isRoleCustom~/false/roleTemplateId/$intuneAdminRoleId/resourceId/$tenantId/isInternalCall~/true"
    $maxItemsToDisplay = 10

    # --- Table 1: PIM Eligibility (Q3 — Informational) ---
    $eligibilityRows = ''
    if ($eligibilitySchedules.Count -gt 0) {
        foreach ($schedule in ($eligibilitySchedules | Select-Object -First $maxItemsToDisplay)) {
            $principalName = Get-SafeMarkdown -Text ($schedule.principal.displayName ?? $schedule.principalId)
            $odataType     = $schedule.principal.'@odata.type'
            $principalType = if ($odataType) { $odataType -replace '#microsoft.graph\.', '' } else { 'Unknown' }
            $memberType    = if ($schedule.memberType) { $schedule.memberType } else { '-' }
            $startRaw      = $schedule.scheduleInfo.startDateTime
            $exp           = $schedule.scheduleInfo.expiration
            $startDt       = if ($startRaw) { Get-FormattedDate $startRaw } else { 'N/A' }
            $endDt         = if ($exp.endDateTime)                              { Get-FormattedDate $exp.endDateTime }
                             elseif ($exp.type -eq 'noExpiration' -or -not $exp) { 'Permanent' }
                             elseif ($exp.duration)                              { $exp.duration }
                             else                                                { 'Permanent' }
            $scheduleStatus = if ($schedule.status) { $schedule.status } else { '-' }
            $eligibilityRows += "| $principalName | $principalType | $memberType | $startDt → $endDt | $scheduleStatus |`n"
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
    elseif (-not $maxDurationParsed) {
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
        foreach ($instance in ($assignmentInstances | Select-Object -First $maxItemsToDisplay)) {
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
    }
    else {
        $standingRows = "| _no rows returned — no enabled Member user holds standing Intune Administrator_ | | | | | | ✅ Pass |`n"
    }

    $mdInfo  = "`n## [PIM eligibility (Informational)]($portalUrl)`n`n"
    $mdInfo += "| Principal | Type | Member type | Eligibility window | Status |`n"
    $mdInfo += "| :-------- | :--- | :---------- | :----------------- | :----- |`n"
    $mdInfo += $eligibilityRows
    if ($eligibilitySchedules.Count -gt $maxItemsToDisplay) {
        $mdInfo += "`n`n_**Note**: This table is truncated and showing the first $maxItemsToDisplay of $($eligibilitySchedules.Count) eligible assignments._`n"
    }
    $mdInfo += "`n## [Activation policy rules]($roleSettingsPortalUrl)`n`n"
    $mdInfo += "| Rule | Setting | Value | Required value | Status |`n"
    $mdInfo += "| :--- | :------ | :---- | :------------- | :----- |`n"
    $mdInfo += $policyRows
    $mdInfo += "`n## [Standing permanent assignments]($portalUrl)`n`n"
    $mdInfo += "| Principal | UPN | Assignment type | Member type | End time | Enabled | Status |`n"
    $mdInfo += "| :-------- | :-- | :-------------- | :---------- | :------- | :------ | :----- |`n"
    $mdInfo += $standingRows
    if ($assignmentInstances.Count -gt $maxItemsToDisplay) {
        $mdInfo += "`n`n_**Note**: This table is truncated and showing the first $maxItemsToDisplay of $($assignmentInstances.Count) role assignment instances._`n"
    }

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
