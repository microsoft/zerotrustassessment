<#
.SYNOPSIS
    Checks that admins are enforced for phishing resistant authentication.
#>

function Test-St0009PhishingResistantAuthForAdmins {
    [CmdletBinding()]
    param()

    $roles = Invoke-ZtGraphRequest -RelativeUri 'roleManagement/directory/roleDefinitions' -ApiVersion beta
    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta
    $asp = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationStrengthPolicies' -ApiVersion beta

    # Get all privileged roles
    $privilegedRoles = $roles | Where-Object { $_.isPrivileged }

    $phishResAuthMs = @('windowsHelloForBusiness', 'fido2', 'x509CertificateMultiFactor') # Phishing resistant authentication methods (passkey included in fido2)

    # Get all the authentication strength policies that only allow phishing resistant authentication methods
    $phishResAsp = $asp | Where-Object { ($_.allowedCombinations + $phishResAuthMs | Select-Object -Unique).Length -eq $phishResAuthMs.Length }

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
    $passed = $unprotectedRoles.Length -eq 0
    if($passed) {
        $testResultMarkdown += "Tenant is configured to require phishing resistant authentication for all privileged roles.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Tenant is not configured to require phishing resistant authentication for all privileged roles.`n`n%TestResult%"
    }

    $mdInfo = "## Authentication Strength Policies`n`n"
    if($phishResAsp.Length -eq 0) {
        $mdInfo += "No phishing resistant authentication strength policies found.`n`n"
    }
    else {
        $mdInfo += "Phishing resistant authentication strength policies found:`n`n"
        foreach($asp in $phishResAsp) {
            $mdInfo += " - $($asp.displayName)`n"
        }
    }

    $mdInfo += "`n`n## Conditional Access Policies with phishing resistant authentication policies `n`n"

    if($capsUsingPhishResAuth.Length -eq 0) {
        $mdInfo += "No conditional access policies found with phishing resistant authentication strength policies.`n`n"
    }
    else {
        $mdInfo += "Conditional access policies with phishing resistant authentication strength policies:`n`n"
        foreach($cap in $capsUsingPhishResAuth) {
            $mdInfo += " - $($cap.displayName)`n"
        }
    }

    $mdInfo += "`n`n## Privileged Roles`n`n"
    $mdInfo += "| Role Name | Phishing resistance enforced |`n"
    $mdInfo += "| :--- | :---: |`n"
    foreach($role in $unprotectedRoles) {
        $mdInfo += "| $($role.displayName) | ❌ |`n"
    }
    foreach($role in $protectedRoles) {
        $mdInfo += "| $($role.displayName) | ✅ |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId 'ST0009' -Title 'Phishing resistant authentication required for privileged roles' -Impact High `
        -Likelihood Possible -AppliesTo Entra -Tag Credential, TenantPolicy `
        -Status $passed -Result $testResultMarkdown
}
