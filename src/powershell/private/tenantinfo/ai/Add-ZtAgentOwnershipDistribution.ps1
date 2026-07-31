<#
.SYNOPSIS
    Adds the agent identity owner and effective sponsor distribution to tenant information.
#>

function Add-ZtAgentOwnershipDistribution {
    [CmdletBinding()]
    param(
        $Database
    )

    $tenantInfoName = 'AgentOwnershipDistribution'
    $activity = 'Getting agent ownership distribution'
    Write-ZtProgress -Activity $activity -Status 'Processing'

    try {
        $rows = @(Invoke-DatabaseQuery -Database $Database -Sql @"
select
    ai.id,
    ai.displayName,
    ai.accountEnabled,
    to_json(ai.sponsors) as sponsorsJson,
    case
        when sp.owners is null then 0
        when json_type(sp.owners) = 'ARRAY' then coalesce(json_array_length(sp.owners), 0)
        when json_type(sp.owners) = 'OBJECT' then 1
        else 0
    end as ownerCount
from main.AgentIdentity ai
left join main.ServicePrincipal sp on ai.id = sp.id
order by ai.displayName
"@)
    }
    catch {
        Write-PSFMessage "Failed to query agent ownership distribution: $_" -Tag Test -Level Warning -ErrorRecord $_
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $agentIdentities = @($rows | ForEach-Object {
        $sponsors = if ($_.sponsorsJson -and $_.sponsorsJson -ne 'null') {
            @($_.sponsorsJson | ConvertFrom-Json)
        }
        else {
            @()
        }

        [PSCustomObject]@{
            Id             = $_.id
            DisplayName    = $_.displayName
            AccountEnabled = $_.accountEnabled
            HasOwner       = [int]$_.ownerCount -ge 1
            Sponsors       = $sponsors
        }
    })

    $uniqueGroupIds = @($agentIdentities |
        ForEach-Object { $_.Sponsors } |
        Where-Object {
            $null -ne $_ -and (
                $_.'@odata.type' -eq '#microsoft.graph.group' -or
                ($null -eq $_.'@odata.type' -and $null -ne $_.PSObject.Properties['mailEnabled'])
            )
        } |
        Select-Object -ExpandProperty id -Unique)

    $groupHasMembers = @{}
    if ($uniqueGroupIds.Count -gt 0) {
        try {
            $groupCountResults = Invoke-ZtGraphBatchRequest `
                -Path 'groups/{0}/transitiveMembers/$count' `
                -ArgumentList $uniqueGroupIds `
                -Header @{ 'ConsistencyLevel' = 'eventual' } `
                -NoPaging `
                -Matched `
                -ErrorAction Stop

            foreach ($countResult in $groupCountResults) {
                if (-not $countResult.Success) {
                    throw "Microsoft Graph returned status $($countResult.Status) for sponsor group $($countResult.Argument)."
                }

                $groupHasMembers[$countResult.Argument] = [int]($countResult.Result | Select-Object -First 1) -gt 0
            }
        }
        catch {
            Write-PSFMessage "Failed to resolve agent sponsor group membership: $_" -Tag Test -Level Warning -ErrorRecord $_
            Add-ZtTenantInfo -Name $tenantInfoName -Value $null
            return
        }
    }

    $agentsByBucket = @{
        ownerAndSponsor = [System.Collections.Generic.List[object]]::new()
        ownerOnly       = [System.Collections.Generic.List[object]]::new()
        sponsorOnly     = [System.Collections.Generic.List[object]]::new()
        neither         = [System.Collections.Generic.List[object]]::new()
    }

    foreach ($agentIdentity in $agentIdentities) {
        $hasSponsor = $false
        foreach ($sponsor in @($agentIdentity.Sponsors | Where-Object { $null -ne $_ })) {
            $odataType = $sponsor.'@odata.type'
            if (-not $odataType) {
                $odataType = if ($null -ne $sponsor.PSObject.Properties['mailEnabled']) {
                    '#microsoft.graph.group'
                }
                else {
                    '#microsoft.graph.user'
                }
            }

            if ($odataType -eq '#microsoft.graph.user' -or
                ($odataType -eq '#microsoft.graph.group' -and $groupHasMembers[$sponsor.id])) {
                $hasSponsor = $true
                break
            }
        }

        $bucket = if ($agentIdentity.HasOwner -and $hasSponsor) {
            'ownerAndSponsor'
        }
        elseif ($agentIdentity.HasOwner) {
            'ownerOnly'
        }
        elseif ($hasSponsor) {
            'sponsorOnly'
        }
        else {
            'neither'
        }

        $agentsByBucket[$bucket].Add([PSCustomObject]@{
            displayName    = $agentIdentity.DisplayName
            accountEnabled = $agentIdentity.AccountEnabled
        })
    }

    $distribution = [PSCustomObject]@{
        ownerAndSponsor = $agentsByBucket.ownerAndSponsor.Count
        ownerOnly       = $agentsByBucket.ownerOnly.Count
        sponsorOnly     = $agentsByBucket.sponsorOnly.Count
        neither         = $agentsByBucket.neither.Count
        skippedCount    = 0
        agents           = [PSCustomObject]@{
            ownerAndSponsor = @($agentsByBucket.ownerAndSponsor | Sort-Object displayName)
            ownerOnly       = @($agentsByBucket.ownerOnly | Sort-Object displayName)
            sponsorOnly     = @($agentsByBucket.sponsorOnly | Sort-Object displayName)
            neither         = @($agentsByBucket.neither | Sort-Object displayName)
        }
    }

    Add-ZtTenantInfo -Name $tenantInfoName -Value $distribution
    Write-ZtProgress -Activity $activity -Status 'Completed'
}
