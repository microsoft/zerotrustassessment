function Add-ZtOverviewCloudSecureScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]] $SubscriptionId
    )

    $query = @'
securityresources
| where type =~ "microsoft.security/securescores"
| project percentage=todecimal(properties.score.percentage)*100, weight=tolong(properties.weight), scoreType=name, environment=tostring(properties.environment)
| where scoreType == "ascScore"
| where environment in~ ("Azure", "AWS", "GCP", "AzureDevOps", "Github", "GitLab", "DockerHub", "JFrog")
| extend subTotal = weight*percentage
| summarize weightedSum=sum(subTotal), totalWeight=sum(weight), invalidCount=countif(isnull(percentage) or percentage < 0 or percentage > 100 or isnull(weight)) by environment
| where invalidCount == 0 and totalWeight > 0
| project percentage=round(weightedSum/totalWeight), environment
| join kind=inner (
    securityresources
    | where type == "microsoft.security/securescores/securescorecontrols"
    | extend environment = tostring(properties.environment)
    | where environment in~ ("Azure", "AWS", "GCP", "AzureDevOps", "Github", "GitLab", "DockerHub", "JFrog")
    | summarize maxControlPoints=max(tolong(properties.score.max)) by name, environment
    | summarize max=sum(maxControlPoints) by environment
) on environment
| project-away environment1
| extend current = round(max*percentage/100)
| union (
    securityresources
    | where type =~ "microsoft.security/securescores"
    | project percentage=todecimal(properties.score.percentage)*100, weight=tolong(properties.weight), scoreType=name, environment=tostring(properties.environment)
    | where scoreType == "ascScore"
    | where environment in~ ("Azure", "AWS", "GCP", "AzureDevOps", "Github", "GitLab", "DockerHub", "JFrog")
    | extend subTotal = weight*percentage
    | summarize weightedSum=sum(subTotal), totalWeight=sum(weight), invalidCount=countif(isnull(percentage) or percentage < 0 or percentage > 100 or isnull(weight))
    | where invalidCount == 0 and totalWeight > 0
    | project percentage=round(weightedSum/totalWeight)
    | extend joinColumn = 0
    | join kind=inner (
        securityresources
        | where type == "microsoft.security/securescores/securescorecontrols"
        | extend environment = tostring(properties.environment)
        | where environment in~ ("Azure", "AWS", "GCP", "AzureDevOps", "Github", "GitLab", "DockerHub", "JFrog")
        | summarize maxControlPoints=max(tolong(properties.score.max)) by name
        | summarize max=sum(maxControlPoints)
        | extend joinColumn = 0
    ) on joinColumn
    | project-away joinColumn, joinColumn1
    | extend current = round(max*percentage/100), environment = "All"
)
| project secureScore = pack_all()
| summarize secureScore = make_list(secureScore)
'@

    $score = $null
    try {
        $response = @(Invoke-ZtAzureResourceGraphRequest -Query $query -SubscriptionId $SubscriptionId -ErrorAction Stop)
        $scores = @($response | ForEach-Object { $_.secureScore } | Where-Object { $null -ne $_ })
        if ($scores.Count -gt 0) {
            $score = $scores
        }
    }
    catch {
        Write-PSFMessage 'Cloud secure score collection failed; the score will be unavailable.' -Tag Test -Level Warning
    }

    Add-ZtTenantInfo -Name 'OverviewCloudSecureScore' -Value $score
}
