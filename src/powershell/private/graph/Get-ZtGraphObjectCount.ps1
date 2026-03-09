function Get-ZtGraphObjectCount {
    [CmdletBinding()]
    param (
        # The graph uri to get the count of objects from. E.g. /beta/servicePrincipals
        [string]
        [Parameter(Mandatory = $true)]
        $Uri
    )

    $graphUri = $Uri + "?`$count=true"

    $res = Invoke-MgGraphRequest -Uri $graphUri -Headers @{ConsistencyLevel = 'eventual'}

    return $res.'@odata.count'
}
