
<#
.SYNOPSIS
    Calculates the CA summary data from sign in logs for managed devices inthe overiew report and adds it to the tenant info.
#>

function Add-ZtOverviewCaDevicesAllUsers {
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

    $caSummary = Get-ZtOverviewCaDevicesAllUsers $results

    Add-ZtTenantInfo -Name "OverviewCaDevicesAllUsers" -Value $caSummary
}

function Get-ZtOverviewCaDevicesAllUsers($results) {

    $caMfa = GetCount $results "success" "multiFactorAuthentication"
    $caNoMfa = GetCount $results "success" "singleFactorAuthentication"
    $noCaMfa = GetCount $results "notApplied" "multiFactorAuthentication"
    $noCaNoMfa = GetCount $results "notApplied" "singleFactorAuthentication"

    $nodes = @(
        @{
            "source" = "User sign in"
            "target" = "Unmanaged"
            "value"  = 70
        },
        @{
            "source" = "User sign in"
            "target" = "Managed"
            "value"  = 30
        },
        @{
            "source" = "Managed"
            "target" = "Non-compliant"
            "value"  = 10
        },
        @{
            "source" = "Managed"
            "target" = "Compliant"
            "value"  = 20
        }
    )

    $caSummaryArray = @{
        "description" = "Over the past 7 days, 20% of sign-ins were from non-compliant devices."
        "nodes" = $nodes
    }

    return $caSummaryArray
}

function GetCount($results, $caStatus, $authReq) {
    return ($results
    | Where-Object { $_.conditionalAccessStatus -eq $caStatus -and $_.authenticationRequirement -eq $authReq}
    | Select-Object -ExpandProperty cnt) -as [int]
}
