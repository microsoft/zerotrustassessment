<#
.SYNOPSIS
    Checks that admins are enforced for phishing resistant authentication.
#>

function Test-Assessment-21783 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21783,
    	Title = 'Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking phishing resistant authentication for privileged roles"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # TODO: Check for report-only and exclude from pass state. Include CA state in the CA outpu
    # -Include a pass / partial / fail next to each CA policy to show which ones have phish resistant for roles.

    $roles = Get-ZtRole
    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta
    $asp = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationStrengthPolicies' -ApiVersion beta

    # Get all privileged roles
    $privilegedRoles = $roles | Where-Object { $_.isPrivileged }

    $phishResAuthMs = @('windowsHelloForBusiness', 'fido2', 'x509CertificateMultiFactor') # Phishing resistant authentication methods (passkey included in fido2)

    # Get all the authentication strength policies that only allow phishing resistant authentication methods
    $phishResAsp = $asp | Where-Object { (($_.allowedCombinations + $phishResAuthMs | Select-Object -Unique) | Measure-Object).Count -eq ($phishResAuthMs | Measure-Object).Count }

    # Get the IDs of CA policies using phishing resistant auth strength policies
    $capsIdsUsingPhishResAuth = $phishResAsp | ForEach-Object { Invoke-ZtGraphRequest -RelativeUri "policies/authenticationStrengthPolicies/$($_.id)/usage" }

    # Get the full CA policies that use phishing resistant authentication
    $capsUsingPhishResAuth = $caps | Where-Object { $_.id -in $capsIdsUsingPhishResAuth.none.id }

    # Are there any privileged roles that are not enforced to use phishing resistant authentication?

    $capCoveredRoles = $capsUsingPhishResAuth.conditions.users.includeroles | Select-Object -Unique

    $protectedRoles = @()
    $unprotectedRoles = @()
    foreach ($role in $privilegedRoles) {
        if ($role.id -in $capCoveredRoles) {
            $protectedRoles += $role
        }
        else {
            $unprotectedRoles += $role
        }
    }
    $passed = ($unprotectedRoles | Measure-Object).Count -eq 0
    if ($passed) {
        $testResultMarkdown += "Validated that following roles have.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Found Roles don’t have policies to enforce phishing resistant Credentials`n`n%TestResult%"
    }

    $mdInfo += "`n`n## Conditional Access Policies with phishing resistant authentication policies `n`n"

    if (($capsUsingPhishResAuth | Measure-Object).Count -eq 0) {
        $mdInfo += "No conditional access policies found with phishing resistant authentication strength policies.`n`n"
    }
    else {
        $mdInfo += "Found $($capsUsingPhishResAuth.Length) phishing resistant conditional access policies.`n`n"
        $mdInfo += Get-GraphObjectMarkdown -GraphObjects $capsUsingPhishResAuth -GraphObjectType ConditionalAccess
    }

    $mdInfo += "`n`n## Privileged Roles`n`n"
    if (($protectedRoles | Measure-Object).Coiunt -eq 0) {
        $mdInfo += "Privileged roles are not being protected by phishing resistant authentication.`n`n"
    }
    elseif ($protectedRoles.Length -eq $privilegedRoles.Length) {
        $mdInfo += "All $($protectedRoles.Length) privileged roles are protected by phishing resistant authentication.`n`n"
    }
    else {
        $mdInfo += "Found $($protectedRoles.Length) of $($privilegedRoles.Length) privileged roles protected by phishing resistant authentication.`n`n"
    }
    $mdInfo += "| Role Name | Phishing resistance enforced |`n"
    $mdInfo += "| :--- | :---: |`n"
    foreach ($role in $protectedRoles | Sort-Object displayName) {
        $mdInfo += "| $($role.displayName) | ✅ |`n"
    }

    foreach ($role in $unprotectedRoles | Sort-Object displayName) {
        $mdInfo += "| $($role.displayName) | ❌ |`n"
    }


    if (($phishResAsp | Measure-Object).Count -ne 0) {
        $mdInfo += "## Authentication Strength Policies`n`n"
        $mdInfo += "Found $($phishResAsp.Length) custom phishing resistant authentication strength policies.`n`n"
        $mdInfo += Get-GraphObjectMarkdown -GraphObjects $phishResAsp -GraphObjectType AuthenticationStrength
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21783' -Title 'Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing resistant methods' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag AccessControl, Authentication `
        -Status $passed -Result $testResultMarkdown
}
