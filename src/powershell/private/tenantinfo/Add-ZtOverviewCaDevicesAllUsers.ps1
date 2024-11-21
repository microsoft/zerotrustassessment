
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
select deviceDetail.isManaged as isManaged, deviceDetail.isCompliant as isCompliant, count(*) as cnt from SignIn
where isInteractive == true and status.errorCode == 0
group by isManaged, isCompliant
"@

    # Example output:
    # isManaged   isCompliant   cnt
    # true       false          19
    # true       true           83
    # false      false          455


    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $results = @($results) # Convert to array in case of single result

    $caSummary = Get-ZtOverviewCaDevicesAllUsers $results

    Add-ZtTenantInfo -Name "OverviewCaDevicesAllUsers" -Value $caSummary
}

function Get-ZtOverviewCaDevicesAllUsers($results) {

    $managed = GetManagedCount $results -isManaged $true
    $unmanaged = GetManagedCount $results -isManaged $false
    $compliant = GetCompliant $results -isManaged $true -isCompliant $true
    $nonCompliant = GetCompliant $results -isManaged $true -isCompliant $false

    $nodes = @(
        @{
            "source" = "User sign in"
            "target" = "Unmanaged"
            "value"  = $unmanaged
        },
        @{
            "source" = "User sign in"
            "target" = "Managed"
            "value"  = $managed
        },
        @{
            "source" = "Managed"
            "target" = "Non-compliant"
            "value"  = $nonCompliant
        },
        @{
            "source" = "Managed"
            "target" = "Compliant"
            "value"  = $compliant
        }
    )

    $duration = Get-ZtSignInDuration -Database $Database
    $total = $managed + $unmanaged
    $percent = Get-ZtPercentLabel -value $compliant -total $total
    $caSummaryArray = @{
        "description" = "Over the past $duration, $percent of sign-ins were from compliant devices."
        "nodes" = $nodes
    }

    return $caSummaryArray
}

function GetManagedCount($results, $isManaged) {
    return ($results
    | Where-Object { $_.isManaged -eq $isManaged}
    | Select-Object -ExpandProperty cnt) -as [int]
}

function GetCompliant($results, $isManaged, $isCompliant) {
    return ($results
    | Where-Object { $_.isManaged -eq $isManaged -and $_.isCompliant -eq $isCompliant }
    | Select-Object -ExpandProperty cnt) -as [int]
}
