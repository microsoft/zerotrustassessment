function Export-GraphEntity {
    [CmdletBinding()]
    param (
        # The entity to export. e.g. /beta/servicePrincipals
        [string]
        [Parameter(Mandatory = $true)]
        $EntityUri,

        # Parameters to include. e.g. $expand=appRoleAssignments&$top=999
        [string]
        [Parameter(Mandatory = $false)]
        $QueryString,

        # The folder for the entity. e.g. ServicePrincipals
        [string]
        [Parameter(Mandatory = $true)]
        $EntityName,

        # The name to show in the progress bar. E.g. Service Principals
        [string]
        [Parameter(Mandatory = $true)]
        $ProgressActivity,

        # The additional properties/relations to be queried for each object. e.g. oauth2PermissionGrants
        [string[]]
        $RelatedPropertyNames,

        # The folder to output the report to.
        [string]
        [Parameter(Mandatory = $true)]
        $ExportPath,

        # Get's count of items to show progress, skip if entity does not support $count
        [switch]
        $ShowCount,

        # The maximum time (in minutes) the assessment should spend on querying this entity.
        [int]
        $MaximumQueryTime
    )
    if ((Get-ZtConfig -ExportPath $ExportPath -Property $EntityName)) {
        Write-PSFMessage "Skipping $EntityName since it was downloaded previously" -Tag Import
        return
    }

    $activity = "Exporting $ProgressActivity"
    Write-ZtProgress $activity

    $totalCount = if ($ShowCount.IsPresent) {
        Get-ZtGraphObjectCount $EntityUri
    }
    else {
        0
    }
    $pageIndex = 0
    $currentCount = 0

    $folderPath = Join-Path $ExportPath $EntityName
    Clear-ZtFolder $folderPath

    $uri = $EntityUri + '?' + $QueryString
    $startTime = Get-Date
    $stopTime = $startTime.AddMinutes($MaximumQueryTime)
    $hasTimeLimit = $MaximumQueryTime -gt 0

    $hasCompleted = $false
    do {
        $results = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType HashTable
        $currentCount = ExportPage $pageIndex $folderPath $results $RelatedPropertyNames $EntityName $EntityUri $currentCount $totalCount $ProgressActivity $ShowCount

        if (!$results) {
            $uri = $null
        }
        else {
            $uri = Get-ObjectProperty $results '@odata.nextLink'
        }
        $pageIndex++

        if (!$uri) {
            $hasCompleted = $true
        }
        elseif (!$hasCompleted -and $hasTimeLimit -and (Get-Date) -gt $stopTime) {
            Write-PSFMessage "Maximum time limit reached for $EntityName"
            $hasCompleted = $true
        }
    }while (!$hasCompleted)

    Set-ZtConfig -ExportPath $ExportPath -Property $EntityName -Value $true
}

function ExportPage
{
	[CmdletBinding()]
	param (
		$pageIndex,

		$path,

		$results,

		$relatedPropertyNames,

		$entityName,

		$entityUri,

		$currentCount,

		$totalCount,

		$progressActivity,

		$showCount
	)
    Write-PSFMessage "Exporting $entityName page $pageIndex"

    if ($relatedPropertyNames) {
        foreach ($result in $results.value) {
            $currentCount++
            $status = Get-Status $currentCount $totalCount $showCount $entityName $result
            Write-ZtProgress "Exporting $progressActivity" -Status $status
            foreach ($propertyName in $relatedPropertyNames) {
                Add-GraphProperty $result $propertyName $entityName $entityUri
            }
        }
    }
    else {
        $currentCount += $results.value.Count
        $status = Get-Status $currentCount $totalCount $showCount $entityName $null
        Write-ZtProgress "Exporting $progressActivity" -Status $status
    }

    $filePath = Join-Path $path "$entityName-$pageIndex.json"
    $results | ConvertTo-Json -Depth 100 | Out-File -FilePath $filePath -Force
    return $currentCount
}

function Get-Status
{
	[CmdletBinding()]
	param (
		$currentCount,

		$totalCount,

		$showCount,

		$name,

		$result
	)
    if ($showCount -and $null -ne $result) {
        $name = Get-ObjectProperty $result 'displayName'
        $status = "$currentCount of $totalCount : $name"
    }
    else {
        $status = "Retrieved $currentCount items..."
    }
    return $status
}

function Add-GraphProperty
{
	[CmdletBinding()]
	param (
		$result,

		$propertyName,

		$entityName,

		$entityUri
	)
    $id = Get-ObjectProperty $result 'id'
    Write-PSFMessage "Adding $propertyName to $entityName $id" -Tag Graph

    try {
        $propertyResults = Invoke-MgGraphRequest -Uri "$entityUri/$id/$propertyName" -OutputType HashTable
        $result[$propertyName] = Get-ObjectProperty $propertyResults 'value'
    }
    catch {
        $errorMessage = $_.Exception.Message

        # Check for known timeout errors that should be silently logged
        if ($entityName -eq "SignIn" -and $errorMessage -like "*The request was canceled due to the configured HttpClient.Timeout*") {
            Write-PSFMessage "Timeout occurred while adding $propertyName to $entityName $id - silently continuing" -Tag Graph -Level Verbose
        }
        else {
            # Log unknown errors and show warning
            Write-PSFMessage "Failed to add $propertyName to $entityName $id. Error: $errorMessage" -Tag Graph -Level Warning
            Write-Warning "Failed to retrieve property '$propertyName' for $entityName '$id': $errorMessage"
        }
    }
}
