
<#
.SYNOPSIS
    Calculates auth methods registered by privileged users.
#>

function Add-ZtOverviewAuthMethodsPrivilegedUsers {
    [CmdletBinding()]
    param(
        $Database
    )
    $activity = "Getting privileged user authentication methods summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $tenantInfoName = 'OverviewAuthMethodsPrivilegedUsers'

    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
    if ($EntraIDPlan -eq "Free") {
        Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $caSummary = Get-ZtOverviewAuthMethodsPrivilegedUsers

    Add-ZtTenantInfo -Name $tenantInfoName -Value $caSummary
}

function Get-ZtOverviewAuthMethodsPrivilegedUsers
{
	[CmdletBinding()]
	param (

	)

    $singleFactor = GetPrivUserAuthMethodCountSingleFactor
    $phone = GetPrivUserAuthMethodCount "'mobilePhone'"
    $authenticator = GetPrivUserAuthMethodCount "'microsoftAuthenticatorPush', 'softwareOneTimePasscode', 'microsoftAuthenticatorPasswordless'"
    $passkey = GetPrivUserAuthMethodCount "'passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator'"
    $whfb = GetPrivUserAuthMethodCount "'windowsHelloForBusiness'"

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
        "description" = "Strongest authentication method registered by privileged users."
        "nodes"       = $nodes
    }

    return $caSummaryArray
}

function GetPrivUserAuthMethodCountSingleFactor
{
	[CmdletBinding()]
	param (

	)
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where len(methodsRegistered) = 0
    and cast(id as varchar) in
    (select principalId from vwRole)
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}

function GetPrivUserAuthMethodCount
{
	[CmdletBinding()]
	param (
		$methodTypes
	)
    $sql = @"
select count(*) as 'count'
from UserRegistrationDetails
where list_has_any([$methodTypes], methodsRegistered)
    and cast(id as varchar) in
    (select principalId from vwRole)
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    return $results.count
}
