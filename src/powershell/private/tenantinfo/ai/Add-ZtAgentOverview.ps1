<#
.SYNOPSIS
    Adds agent overview information to tenant info.
#>

function Add-ZtAgentOverview {
    [CmdletBinding()]
    param()

    $activity = 'Getting agent overview'
    Write-ZtProgress -Activity $activity -Status 'Processing'

    $totalAgents = $null
    $activeUsers = $null

    try {
        $agentResponse = Invoke-ZtGraphRequest `
            -RelativeUri 'servicePrincipals' `
            -ApiVersion 'v1.0' `
            -Select 'id' `
            -Filter "(isof('microsoft.graph.agentIdentity') OR (tags/any(p:startswith(p, 'power-virtual-agents-')) OR tags/any(p:p eq 'AgenticInstance')))" `
            -Top 1 `
            -QueryParameters @{ '$count' = 'true' } `
            -ConsistencyLevel 'eventual' `
            -DisablePaging `
            -DisableCache `
            -ErrorAction Stop

        if ($null -eq $agentResponse.'@odata.count') {
            throw 'The Microsoft Graph response did not include an agent count.'
        }

        $totalAgents = [int]$agentResponse.'@odata.count'
    }
    catch {
        Write-PSFMessage 'Unable to retrieve the total agent count from Microsoft Graph.' -Level Warning
    }

    try {
        $now = [datetimeoffset]::UtcNow
        $lookbackDate = $now.AddDays(-30)
        $nowText = $now.ToString('yyyy-MM-ddTHH:mm:ssZ')
        $lookbackDateText = $lookbackDate.ToString('yyyy-MM-ddTHH:mm:ssZ')

        $signIns = @(
            Invoke-ZtGraphRequest `
                -RelativeUri "auditLogs/getSummarizedNonInteractiveSignIns(aggregationWindow='d1')" `
                -ApiVersion 'beta' `
                -Select 'userPrincipalName' `
                -Filter "agent/agentType eq 'agenticAppInstance' and agent/agentSubjectType ne 'agentIDuser' and (firstSignInDateTime ge $lookbackDateText and firstSignInDateTime lt $nowText)" `
                -Top 1000 `
                -QueryParameters @{ '$orderby' = 'firstSignInDateTime desc' } `
                -Headers @{ Prefer = 'include-unknown-enum-members' } `
                -DisableCache `
                -ErrorAction Stop
        )

        $activeUsers = @(
            $signIns |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.userPrincipalName) } |
                Select-Object -ExpandProperty userPrincipalName |
                Sort-Object -Unique
        ).Count
    }
    catch {
        Write-PSFMessage 'Unable to retrieve active agent users from Microsoft Graph.' -Level Warning
    }

    Add-ZtTenantInfo -Name 'AgentOverview' -Value ([PSCustomObject]@{
        TotalAgents = $totalAgents
        ActiveUsers = $activeUsers
    })

    Write-ZtProgress -Activity $activity -Status 'Completed'
}
