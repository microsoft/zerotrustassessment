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
with agent_owners as (
    select
        id,
        owners
    from main.ServicePrincipal
    where "@odata.type" = '#microsoft.graph.agentIdentity'
)
select
    coalesce(ai.id, sp.id) as id,
    ai.displayName,
    ai.accountEnabled,
    to_json(ai.sponsors) as sponsorsJson,
    ai.id is not null as hasSponsorSnapshot,
    sp.id is not null as hasOwnerSnapshot,
    case
        when sp.owners is null then 0
        when json_type(sp.owners) = 'ARRAY' then coalesce(json_array_length(sp.owners), 0)
        when json_type(sp.owners) = 'OBJECT' then 1
        else 0
    end as ownerCount
from main.AgentIdentity ai
full outer join agent_owners sp on ai.id = sp.id
order by coalesce(ai.displayName, '')
"@)
    }
    catch {
        Write-PSFMessage "Failed to query agent ownership distribution: $_" -Tag Test -Level Warning -ErrorRecord $_
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $snapshotMismatches = @($rows | Where-Object {
        -not ($_.hasSponsorSnapshot -and $_.hasOwnerSnapshot)
    })
    $matchedRows = @($rows | Where-Object {
        $_.hasSponsorSnapshot -and $_.hasOwnerSnapshot
    })

    if ($snapshotMismatches.Count -gt 0) {
        Write-PSFMessage "$($snapshotMismatches.Count) agent identities were excluded because the owner and sponsor snapshots did not match." -Tag Test -Level Warning
    }

    $agentIdentities = @($matchedRows | ForEach-Object {
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
            $groupCountResults = @(Invoke-ZtGraphBatchRequest `
                -Path 'groups/{0}/transitiveMembers/$count' `
                -ArgumentList $uniqueGroupIds `
                -Header @{ 'ConsistencyLevel' = 'eventual' } `
                -NoPaging `
                -Matched `
                -ErrorAction Stop)

            $expectedGroupIds = @{}
            foreach ($groupId in $uniqueGroupIds) {
                $expectedGroupIds[[string]$groupId] = $true
            }
            $groupResolutionFailed = $false

            foreach ($countResult in @($groupCountResults)) {
                if (-not $countResult.Success) {
                    $groupResolutionFailed = $true
                    Write-PSFMessage "Failed to resolve a sponsor group member count (status $($countResult.Status))." -Tag Test -Level Warning
                    continue
                }

                $groupId = [string]$countResult.Argument
                if (-not $expectedGroupIds.ContainsKey($groupId) -or $groupHasMembers.ContainsKey($groupId)) {
                    $groupResolutionFailed = $true
                    continue
                }

                $groupHasMembers[$groupId] = ([int]($countResult.Result | Select-Object -First 1) -gt 0)
            }

            if ($groupResolutionFailed -or $groupHasMembers.Count -ne $uniqueGroupIds.Count) {
                Write-PSFMessage 'Agent ownership distribution was omitted because one or more sponsor groups could not be resolved.' -Tag Test -Level Warning
                Add-ZtTenantInfo -Name $tenantInfoName -Value $null
                return
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
        skippedCount    = $snapshotMismatches.Count
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
