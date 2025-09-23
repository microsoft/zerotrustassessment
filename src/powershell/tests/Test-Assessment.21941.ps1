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

    $tokenProtectionPolicies = @()
    $policyDetails = @()

    # Required application IDs for token protection
    $requiredAppIds = @(
        "00000002-0000-0ff1-ce00-000000000000",  # Office 365 Exchange Online
        "00000003-0000-0ff1-ce00-000000000000"   # Microsoft Graph / SharePoint Online
    )

    # Loop through each policy to validate token protection requirements
    $allPolicyDetails = @()
    foreach ($policy in $allCAPolicies) {
       $policyDetails  += $policy

        # Check if policy meets token protection criteria
        $meetsTokenProtectionCriteria = $true
        $failureReasons = @()

        # Validate 1: users.includeUsers has value
        $hasIncludeUsers = $policy.conditions.users.includeUsers -and $policy.conditions.users.includeUsers.Count -gt 0
        if (-not $hasIncludeUsers) {
            $meetsTokenProtectionCriteria = $false
            $failureReasons += "No users specified in includeUsers"
        }

        # Validate 2: Applications include required app IDs or "All"
        $hasRequiredApps = $false
        $includeAppsDisplay = "None"
        if ($policy.conditions.applications.includeApplications) {
            if ($policy.conditions.applications.includeApplications -contains "All") {
                $hasRequiredApps = $true
                $includeAppsDisplay = "All"
            }
            else {
                $hasOfficeApp = $policy.conditions.applications.includeApplications -contains $requiredAppIds[0]
                $hasGraphApp = $policy.conditions.applications.includeApplications -contains $requiredAppIds[1]
                if ($hasOfficeApp -or $hasGraphApp) {
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

        # Validate 3: sessionControls.secureSignInSession.isEnabled is true
        $hasSecureSignInSession = $policy.sessionControls?.secureSignInSession?.isEnabled -eq $true

        if (-not $hasSecureSignInSession) {
            $meetsTokenProtectionCriteria = $false
            if (-not $policy.sessionControls) {
                $failureReasons += "Session controls are not configured"
            }
            elseif (-not $policy.sessionControls.secureSignInSession) {
                $failureReasons += "Secure sign-in session control is not configured"
            }
            else {
                $failureReasons += "Secure sign-in session is not enabled"
            }
        }

        # Create policy detail object
        $includeUsersDisplay = if ($policy.conditions.users.includeUsers -contains "All") { "All" } elseif ($hasIncludeUsers) { "Selected" } else { "None" }

        $policyDetail = [PSCustomObject]@{
            PolicyId = $policy.id
            DisplayName = $policy.displayName
            State = $policy.state
            IncludeUsers = $includeUsersDisplay
            IncludeApplications = $includeAppsDisplay
            TokenProtectionEnabled = $meetsTokenProtectionCriteria
            FailureReasons = $failureReasons
            Policy = $policy
        }

        $allPolicyDetails += $policyDetail

        if ($meetsTokenProtectionCriteria) {
            $tokenProtectionPolicies += $policy
        }
    }

    # Determine test result
    $passed = $tokenProtectionPolicies.Count -gt 0

    $portalTemplate = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}"

    if ($passed) {
        $testResultMarkdown = "✅ **PASS**: Token protection policies are configured.`n`n"
    }
    else {
        $testResultMarkdown = "❌ **FAIL**: Token protection policy is not configured.`n`n"
    }

    # Build detailed markdown information
    $mdInfo = ""

    if ($allCAPolicies.Count -eq 0) {
        $mdInfo += "No Conditional Access policies found targeting Windows platforms.`n`n"
    }
    else {
        $mdInfo += "**Analysis Summary:**`n"
        $mdInfo += "- Total Conditional Access policies analyzed: $($allCAPolicies.Count)`n"
        $mdInfo += "- Policies meeting token protection criteria: $($tokenProtectionPolicies.Count)`n"
        $mdInfo += "- Policies not meeting token protection criteria: $(($allPolicyDetails | Where-Object { -not $_.TokenProtectionEnabled }).Count)`n`n"

        $mdInfo += "### Token Protection Policy Summary`n`n"
        $mdInfo += "The table below lists all Conditional Access policies targeting Windows platforms and their token protection status.`n`n"

        $mdInfo += "| Name | Policy State | Users | Applications | Token Protection |`n"
        $mdInfo += "| :--- | :---: | :---: | :---: | :---: |`n"

        # Sort policies: passing first, then by display name
        $sortedPolicyDetails = $allPolicyDetails | Sort-Object -Property @{ Expression = { -not $_.TokenProtectionEnabled } }, DisplayName

        foreach ($policyDetail in $sortedPolicyDetails) {
            $portalLink = $portalTemplate -f $policyDetail.PolicyId
            $policyName = "[$(Get-SafeMarkdown $policyDetail.DisplayName)]($portalLink)"
            $policyState = Get-ZtCaPolicyState -State $policyDetail.State
            $tokenProtectionStatus = Get-ZtPassFail -Condition $policyDetail.TokenProtectionEnabled -IncludeText

            $mdInfo += "| $policyName | $policyState | $($policyDetail.IncludeUsers) | $($policyDetail.IncludeApplications) | $tokenProtectionStatus |`n"
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
