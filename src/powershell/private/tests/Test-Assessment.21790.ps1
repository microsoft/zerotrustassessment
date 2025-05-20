<#
.SYNOPSIS

#>

function Test-Assessment-21790 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Outbound cross-tenant access settings are configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query the default cross-tenant access policy
    $result = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion v1.0

    # Helper function to process targets
    function Get-TargetDescription {
        param (
            [Parameter(Mandatory)]
            [object]$TargetConfig
        )

        if ($TargetConfig.targets[0].target -eq "AllUsers") {
            return "All users"
        }
        elseif ($TargetConfig.targets[0].target -eq "AllApplications") {
            return "All external applications"
        }
        else {
            $users = 0
            $groups = 0
            $applications = 0

            foreach ($target in $TargetConfig.targets) {
                if ($target.targetType -eq "user") {
                    $users++
                }
                elseif ($target.targetType -eq "group") {
                    $groups++
                }
                else {
                    $applications++
                }
            }

            if ($applications -gt 0) {
                return "Selected external applications ($applications applications)"
            }
            else {
                return "Selected users and groups ($users users, $groups groups)"
            }
        }
    }

    # Evaluate B2B Collaboration outbound settings
    $b2bCollaborationOutbound = $result.b2bCollaborationOutbound.usersAndGroups.accessType -eq "blocked" -and
    $result.b2bCollaborationOutbound.usersAndGroups.targets[0].target -eq "AllUsers" -and
    $result.b2bCollaborationOutbound.applications.accessType -eq "blocked" -and
    $result.b2bCollaborationOutbound.applications.targets[0].target -eq "AllApplications"

    # Evaluate B2B Direct Connect outbound settings
    $b2bDirectConnectOutbound = $result.b2bDirectConnectOutbound.usersAndGroups.accessType -eq "blocked" -and
    $result.b2bDirectConnectOutbound.usersAndGroups.targets[0].target -eq "AllUsers" -and
    $result.b2bDirectConnectOutbound.applications.accessType -eq "blocked" -and
    $result.b2bDirectConnectOutbound.applications.targets[0].target -eq "AllAppplications"

    $testResultMarkdown = ""

    if ($b2bCollaborationOutbound -and $b2bDirectConnectOutbound) {
        $passed = $true
        $testResultMarkdown += "Tenant has a default cross-tenant access setting outbound policy that blocks access.%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "Tenant has a default cross-tenant access setting outbound policy with unrestricted access.%TestResult%"
    }

    # Portal link for the report
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/OutboundAccessSettings.ReactView/isDefault~/true/name//id/'

    # Get user/group target descriptions
    $b2bColUsersTargetDesc = Get-TargetDescription -TargetConfig $result.b2bCollaborationOutbound.usersAndGroups
    $b2bColAppsTargetDesc = Get-TargetDescription -TargetConfig $result.b2bCollaborationOutbound.applications
    $b2bDirUsersTargetDesc = Get-TargetDescription -TargetConfig $result.b2bDirectConnectOutbound.usersAndGroups
    $b2bDirAppsTargetDesc = Get-TargetDescription -TargetConfig $result.b2bDirectConnectOutbound.applications

    # Create a here-string with the report details
    $mdInfo = @"

## [Outbound access settings - Default settings]($portalLink)
### B2B Collaboration
Users and groups
- Access status: $($result.b2bCollaborationOutbound.usersAndGroups.accessType)
- Applies to: $b2bColUsersTargetDesc

External applications
- Access status: $($result.b2bCollaborationOutbound.applications.accessType)
- Applies to: $b2bColAppsTargetDesc

### B2B Direct Connect
Users and groups
- Access status: $($result.b2bDirectConnectOutbound.usersAndGroups.accessType)
- Applies to: $b2bDirUsersTargetDesc

External applications
- Access status: $($result.b2bDirectConnectOutbound.applications.accessType)
- Applies to: $b2bDirAppsTargetDesc

"@

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21790'
        Title              = 'Outbound cross-tenant access settings are configured'
        UserImpact         = 'Medium'
        Risk               = 'High'
        ImplementationCost = 'High'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
