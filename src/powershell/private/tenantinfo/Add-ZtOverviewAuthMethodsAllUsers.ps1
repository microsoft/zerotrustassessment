
<#
.SYNOPSIS
    Calculates the CA summary data from sign in logs for managed devices in the overiew report and adds it to the tenant info.
#>

function Add-ZtOverviewAuthMethodsAllUsers {
    [CmdletBinding()]
    param(
        $Database
    )
    $activity = "Getting Conditional Access summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $sql = @"
select conditionalAccessStatus, authenticationRequirement, count(*) as cnt from SignIn
where isInteractive == true and status.errorCode == 0
group by conditionalAccessStatus, authenticationRequirement
"@

    # Example output:
    # conditionalAccessStatus   authenticationRequirement   cnt
    # success                   singleFactorAuthentication  5
    # success                   multiFactorAuthentication   2121
    # notApplied                singleFactorAuthentication  6
    # notApplied                multiFactorAuthentication   6


    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $caSummary = Get-ZtOverviewAuthMethodsAllUsers $results

    Add-ZtTenantInfo -Name "OverviewAuthMethodsAllUsers" -Value $caSummary
}

function Get-ZtOverviewAuthMethodsAllUsers($results) {

    $caMfa = GetCount $results "success" "multiFactorAuthentication"
    $caNoMfa = GetCount $results "success" "singleFactorAuthentication"
    $noCaMfa = GetCount $results "notApplied" "multiFactorAuthentication"
    $noCaNoMfa = GetCount $results "notApplied" "singleFactorAuthentication"

    $nodes = @(
        @{
            "source" = "Users"
            "target" = "Single factor"
            "value"  = 20
        },
        @{
            "source" = "Users"
            "target" = "Phishable"
            "value"  = 40
        },
        @{
            "source" = "Phishable"
            "target" = "Phone"
            "value"  = 20
        },
        @{
            "source" = "Phishable"
            "target" = "Authenticator"
            "value"  = 20
        },
        @{
            "source" = "Users"
            "target" = "Phish resistant"
            "value"  = 40
        },
        @{
            "source" = "Phish resistant"
            "target" = "Passkey"
            "value"  = 20
        },
        @{
            "source" = "Phish resistant"
            "target" = "WHfB"
            "value"  = 20
        }
    )

    $caSummaryArray = @{
        "description" = "Strongest authentication method registered by all users."
        "nodes"       = $nodes
    }

    return $caSummaryArray
}

function GetCount($results, $caStatus, $authReq) {
    return ($results
        | Where-Object { $_.conditionalAccessStatus -eq $caStatus -and $_.authenticationRequirement -eq $authReq }
        | Select-Object -ExpandProperty cnt) -as [int]
}
