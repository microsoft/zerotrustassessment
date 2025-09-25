<#
.SYNOPSIS
    Checks if token protection policies are configured in Conditional Access.
#>

function Test-Assessment-21941{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21941,
    	Title = 'Token protection policies are configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Token protection policies are configured"
    Write-ZtProgress -Activity $activity -Status "Getting Conditional Access policies"

    # Get all Conditional Access policies with Windows platform filtering
    $filter = "conditions/platforms/includePlatforms/any(p:p eq 'windows')"
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion 'beta' -Filter $filter

    $policiesWithTokenProtection = $allCAPolicies | Where-Object {
        $_.sessionControls -and
        $_.sessionControls.secureSignInSession -and
        ($_.sessionControls.secureSignInSession.PSObject.Properties.Name -contains 'isEnabled')
    }

    # Required application IDs for token protection
    $requiredAppIds = @(
        "00000002-0000-0ff1-ce00-000000000000",  # Office 365 Exchange Online
        "00000003-0000-0ff1-ce00-000000000000"   # Microsoft Graph / SharePoint Online
    )

    # Loop through each policy to validate token protection requirements
    $allPolicyDetails = @()
    $tokenProtectionPolicies = @()
    $enabledTokenProtectionPolicies = @()
    foreach ($policy in $policiesWithTokenProtection) {
        # Check if policy meets token protection criteria
        $meetsTokenProtectionCriteria = $true
        $failureReasons = @()

        # Validate 1: sessionControls.secureSignInSession.isEnabled is true
        $hasSecureSignInSession = $policy.sessionControls.secureSignInSession.isEnabled -eq $true

        if (-not $hasSecureSignInSession) {
            $meetsTokenProtectionCriteria = $false
            $failureReasons += "Secure sign-in session is not enabled"
        }

        # Validate 2: users.includeUsers has value
        $hasIncludeUsers = $policy.conditions.users.includeUsers -and ($policy.conditions.users.includeUsers -notcontains "None") -and ($policy.conditions.users.includeUsers.Count -gt 0)
        if (-not $hasIncludeUsers) {
            $meetsTokenProtectionCriteria = $false
            $failureReasons += "No users specified in includeUsers"
        }

        $includeUsersDisplay = if ($policy.conditions.users.includeUsers -contains "All") { "All" } elseif ($hasIncludeUsers) { "Selected" } else { "None" }

        # Validate 3: Applications include required app IDs or "All"
        $hasRequiredApps = $false
        $includeAppsDisplay = "None"
        if ($policy.conditions.applications.includeApplications -and
            $policy.conditions.applications.includeApplications.Count -gt 0 -and
            $policy.conditions.applications.includeApplications -notcontains "None") {
            if ($policy.conditions.applications.includeApplications -contains "All") {
                $hasRequiredApps = $true
                $includeAppsDisplay = "All"
            }
            else {
                $hasOfficeApp = $policy.conditions.applications.includeApplications -contains $requiredAppIds[0]
                $hasGraphApp = $policy.conditions.applications.includeApplications -contains $requiredAppIds[1]
                if ($hasOfficeApp -and $hasGraphApp) {
                    $hasRequiredApps = $true
                    $includeAppsDisplay = "Selected"
                } else {
                    $includeAppsDisplay = "Other apps"
                }
            }
        }

        if (-not $hasRequiredApps) {
            $meetsTokenProtectionCriteria = $false
            $failureReasons += "Missing required applications (Office 365 Exchange Online and Microsoft Graph/SharePoint Online)"
        }

        $policyStatus = ($meetsTokenProtectionCriteria -eq $true) -and ($policy.state -eq 'enabled')

        # Create policy detail object
        $policyDetail = [PSCustomObject]@{
            PolicyId = $policy.id
            DisplayName = $policy.displayName
            State = $policy.state
            IncludeUsers = $includeUsersDisplay
            IncludeApplications = $includeAppsDisplay
            TokenProtectionEnabled = $meetsTokenProtectionCriteria
            SecureSignInEnabled = $hasSecureSignInSession
            FailureReasons = $failureReasons
            Policy = $policy
            PolicyStatus = $policyStatus
        }

        $allPolicyDetails += $policyDetail

        if ($meetsTokenProtectionCriteria) {
            $tokenProtectionPolicies += $policy
            if ($policy.state -eq 'enabled') {
                $enabledTokenProtectionPolicies += $policy
            }
        }
    }

    # Determine test result - Pass if at least one policy has token protection enabled AND is in enabled state
    $passed = $enabledTokenProtectionPolicies.Count -gt 0

    $portalTemplate = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}"

    if ($passed) {
        $testResultMarkdown = "Token protection policies are configured.`n`n"
    }
    else {
        $testResultMarkdown = "Token protection policies are not configured.`n`n"
    }

    # Build detailed markdown information
    $mdInfo = ""

    if ($allCAPolicies.Count -eq 0) {
        $mdInfo += "No Conditional Access policies found targeting Windows platforms.`n`n"
    }
    elseif ($policiesWithTokenProtection.Count -eq 0) {
        $mdInfo += "No Conditional Access policies found with secure sign-in session controls.`n`n"
    }
    else {
        $mdInfo += "### Token protection policy summary`n`n"
        $mdInfo += "The table below lists all the token protection Conditional Access policies found in the tenant.`n`n"

        $mdInfo += "| Name | Policy state | Users | Applications | Token protection | Status |`n"
        $mdInfo += "| :--- | :---: | :---: | :---: | :---: | :---: |`n"

        # Sort policies: passing first, then by display name
        $sortedPolicyDetails = $allPolicyDetails | Sort-Object -Property @{ Expression = { -not $_.TokenProtectionEnabled } }, DisplayName

        foreach ($policyDetail in $sortedPolicyDetails) {
            $portalLink = $portalTemplate -f $policyDetail.PolicyId
            $policyName = "[$(Get-SafeMarkdown $policyDetail.DisplayName)]($portalLink)"
            $policyState = Get-ZtCaPolicyState -State $policyDetail.State
            $tokenProtectionStatus = Get-ZtPassFail -Condition $policyDetail.TokenProtectionEnabled -EmojiType 'Bubble'
            $status = Get-ZtPassFail -Condition $policyDetail.PolicyStatus -IncludeText

            $mdInfo += "| $policyName | $policyState | $($policyDetail.IncludeUsers) | $($policyDetail.IncludeApplications) | $tokenProtectionStatus | $status |`n"
        }
    }

    $testResultMarkdown += $mdInfo

    $params = @{
        Status             = $passed
        Result             = $testResultMarkdown
        GraphObjectType    = 'ConditionalAccess'
        GraphObjects       = $tokenProtectionPolicies
    }

    Add-ZtTestResultDetail @params
}
