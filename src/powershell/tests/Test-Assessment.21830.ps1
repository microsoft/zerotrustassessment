function Test-Assessment-21830 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 21830,
    	Title = 'Conditional Access policies for Privileged Access Workstations are configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Highly privileged roles are only activated in a PAW/SAW device"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Get all Conditional Access policies
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion 'v1.0'

    # Filter for enabled policies on client side
    $enabledCAPolicies = $allCAPolicies | Where-Object { $_.state -eq 'enabled' }

    # Get all role definitions
    $allRoleDefinitions = Get-ZtRole

    # Filter for privileged roles on client side
    $privilegedRoles = $allRoleDefinitions | Where-Object { $_.isPrivileged -eq $true }

    $policyDetails = @()
    # Loop through each enabled policy to get detailed information
    foreach ($policy in $enabledCAPolicies) {
        $policyId = $policy.id
        $policyDetails += Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies/$policyId" -ApiVersion 'v1.0'
    }

    $compliantDevicePolicies = $policyDetails | Where-Object {
        # Check if policy targets privileged roles
        $targetsPrivilegedRoles = $false
        if ($_.conditions.users.includeRoles) {
            foreach ($roleId in $_.conditions.users.includeRoles) {
                if ($privilegedRoles.id -contains $roleId) {
                    $targetsPrivilegedRoles = $true
                    break
                }
            }
        }

        # Check if policy requires compliant device control
        $compliantDevice = $_.grantControls.builtInControls -contains 'compliantDevice'

        return $targetsPrivilegedRoles -and $compliantDevice
    }

    $deviceFilterPolicies = $policyDetails | Where-Object {
        # Check if policy targets privileged roles
        $targetsPrivilegedRoles = $false
        if ($_.conditions.users.includeRoles) {
            foreach ($roleId in $_.conditions.users.includeRoles) {
                if ($privilegedRoles.id -contains $roleId) {
                    $targetsPrivilegedRoles = $true
                    break
                }
            }
        }

        # Check if device filter exists and has exclude mode
        $hasDeviceFilterExclude = $_.conditions.devices.deviceFilter -and
        $_.conditions.devices.deviceFilter.mode -eq 'exclude'

        # Check if policy blocks access (no grant controls or has block control)
        $blocksAccess = (-not $_.grantControls.builtInControls) -or
                        ($_.grantControls.builtInControls -contains 'block')

        return $targetsPrivilegedRoles -and $hasDeviceFilterExclude -and $blocksAccess
    }

    if ($compliantDevicePolicies.Count -eq 0 -or $deviceFilterPolicies.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "No Conditional Access policies found that restrict privileged roles to PAW device."
    }
    else {
        $passed = $true
        $testResultMarkdown = "Conditional Access policies restrict privileged role access to PAW devices."
    }

    $compliantDeviceMarkdown = "❌"
    if ($compliantDevicePolicies.Count -gt 0) {
        $compliantDeviceMarkdown = "✅"
    }

    $deviceFilterMarkdown = "❌"
    if ($deviceFilterPolicies.Count -gt 0) {
        $deviceFilterMarkdown = "✅"
    }

    $portalTemplate = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}"


    $testResultMarkdown += "`n`n**$compliantDeviceMarkdown Found $($compliantDevicePolicies.Count) policy(s) with compliant device control targeting all privileged roles**`n"
    foreach ($policy in $compliantDevicePolicies) {
        $portalLink = $portalTemplate -f $policy.id
        $testResultMarkdown += "- **Policy:** [$(Get-SafeMarkdown($policy.displayName))]($portalLink)`n"
    }

    $testResultMarkdown += "`n`n**$deviceFilterMarkdown Found $($deviceFilterPolicies.Count) policy(s) with PAW/SAW device filter targeting all privileged roles**`n"
    foreach ($policy in $deviceFilterPolicies) {
        $portalLink = $portalTemplate -f $policy.id
        $testResultMarkdown += "- **Policy:** [$(Get-SafeMarkdown($policy.displayName))]($portalLink)`n"
    }

    $params = @{
        TestId             = '21830'
        Title              = 'Highly privileged roles are only activated in a PAW/SAW device'
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'High'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
