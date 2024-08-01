function Export-ServicePrincipals {
    [CmdletBinding()]
    param (
        # The folder to output the report to.
        [string]
        [Parameter(Mandatory = $true)]
        $ExportPath
    )
    $activity = "Exporting Service Principals"
    Write-ZtProgress $activity
    $totalCount = Get-ZtGraphObjectCount '/beta/servicePrincipals'
    $pageIndex = 0
    $currentCount = 0
    $results = Invoke-MgGraphRequest -Uri 'beta/servicePrincipals?$expand=appRoleAssignments&$top=999' -OutputType HashTable
    $folderPath = Join-Path $ExportPath 'ServicePrincipals'
    Clear-ZtFolder $folderPath

    ExportServicePrincipalPage $pageIndex $folderPath $results

    while (Get-ObjectProperty $results '@odata.nextLink') {
        $currentCount += $results.value.Count
        Write-ZtProgress $activity -Status "Processed $currentCount of $totalCount"
        $results = Invoke-MgGraphRequest -Method GET -Uri $results.'@odata.nextLink' -OutputType HashTable
        ExportServicePrincipalPage $pageIndex $folderPath $results
        $pageIndex++
    }
}

function ExportServicePrincipalPage($pageIndex, $path, $results) {
    Write-Verbose "Exporting Service Principals page $pageIndex"
    foreach ($result in $results.value) {
        Add-GraphProperty $result 'oauth2PermissionGrants'
    }

    $filePath = Join-Path $path "ServicePrincipals-$pageIndex.json"
    $results | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath -Force
}

function Add-GraphProperty($result, $propertyName) {
    $id = Get-ObjectProperty $result 'id'
    Write-Verbose "Adding $propertyName to Service Principal $id"
    $propertyResults = Invoke-MgGraphRequest -Uri "beta/servicePrincipals/$id/$propertyName" -OutputType HashTable
    $result[$propertyName] = Get-ObjectProperty $propertyResults 'value'
}
