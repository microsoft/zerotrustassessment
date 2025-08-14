
<#
.SYNOPSIS
    Calculates auth methods registered by all users.
#>

function Add-ZtOverviewAuthMethodsAllUsers {
    [CmdletBinding()]
    param(
        $Database
    )
    $activity = "Getting authentication methods summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $tenantInfoName = 'OverviewAuthMethodsAllUsers'

    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
    if ($EntraIDPlan -eq "Free") {
        Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $caSummary = Get-ZtOverviewAuthMethodsAllUsers

    Add-ZtTenantInfo -Name "OverviewAuthMethodsAllUsers" -Value $caSummary
}

function Get-ZtOverviewAuthMethodsAllUsers() {

    $singleFactor = GetAllUsersAuthMethodCountSingleFactor
    $phone = GetAllUsersAuthMethodCount "'mobilePhone'"
    $authenticator = GetAllUsersAuthMethodCount "'microsoftAuthenticatorPush', 'softwareOneTimePasscode', 'microsoftAuthenticatorPasswordless'"
    $passkey = GetAllUsersAuthMethodCount "'passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator'"
    $whfb = GetAllUsersAuthMethodCount "'windowsHelloForBusiness'"

    $nodes = @(
        @{
            "source" = "Users"
            "target" = "Single factor"
            "value"  = $singleFactor
        },
        @{
            "source" = "Users"
            "target" = "Phishable"
            "value"  = $phone + $authenticator
        },
        @{
            "source" = "Phishable"
            "target" = "Phone"
            "value"  = $phone
        },
        @{
            "source" = "Phishable"
            "target" = "Authenticator"
            "value"  = $authenticator
        },
        @{
            "source" = "Users"
            "target" = "Phish resistant"
            "value"  = $passkey + $whfb
        },
        @{
            "source" = "Phish resistant"
            "target" = "Passkey"
            "value"  = $passkey
        },
        @{
            "source" = "Phish resistant"
            "target" = "WHfB"
            "value"  = $whfb
        }
    )

    $caSummaryArray = @{
        "description" = "Strongest authentication method registered by all users."
        "nodes"       = $nodes
    }

    return $caSummaryArray
}

function GetAllUsersAuthMethodCountSingleFactor() {
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where len(methodsRegistered) = 0
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}

function GetAllUsersAuthMethodCount($methodTypes) {
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where list_has_any([$methodTypes], methodsRegistered)
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}
