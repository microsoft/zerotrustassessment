
<#
.SYNOPSIS
    Calculates the CA summary data from sign in logs for managed devices in the overiew report and adds it to the tenant info.
#>

function Add-ZtOverviewAuthMethodsAllUsers {
    [CmdletBinding()]
    param(
        $Database
    )
    $activity = "Getting authentication methods summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $caSummary = Get-ZtOverviewAuthMethodsAllUsers

    Add-ZtTenantInfo -Name "OverviewAuthMethodsAllUsers" -Value $caSummary
}

function Get-ZtOverviewAuthMethodsAllUsers() {

    $singleFactor = GetAuthMethodCountSingleFactor
    $phone = GetAuthMethodCount "'mobilePhone'"
    $authenticator = GetAuthMethodCount "'microsoftAuthenticatorPush', 'softwareOneTimePasscode', 'microsoftAuthenticatorPasswordless'"
    $passkey = GetAuthMethodCount "'passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator'"
    $whfb = GetAuthMethodCount "'windowsHelloForBusiness'"

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

function GetAuthMethodCountSingleFactor() {
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where len(methodsRegistered) = 0
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}

function GetAuthMethodCount($methodTypes) {
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where list_has_any([$methodTypes], methodsRegistered)
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}
