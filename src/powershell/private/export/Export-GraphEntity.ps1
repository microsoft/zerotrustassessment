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

	#region Utility Functions
	function Export-Page {
		[CmdletBinding()]
		param (
			$PageIndex,

			$Path,

			$Results,

			$RelatedPropertyNames,

			$EntityName,

			$EntityUri,

			$CurrentCount,

			$TotalCount,

			$ProgressActivity,

			[switch]
			$ShowCount
		)
		Write-PSFMessage "Exporting $EntityName page $PageIndex"

		if ($RelatedPropertyNames) {
			foreach ($result in $Results.value) {
				$CurrentCount++
				$status = Get-Status -CurrentCount $CurrentCount -TotalCount $totalCount -ShowCount:$ShowCount -Result $result
				Write-ZtProgress "Exporting $progressActivity" -Status $status
				foreach ($propertyName in $RelatedPropertyNames) {
					Add-GraphProperty -Result $result -PropertyName $propertyName -EntityName $EntityName -EntityUri $EntityUri
				}
			}
		}
		else {
			$CurrentCount += $results.value.Count
			$status = Get-Status -CurrentCount $CurrentCount
			Write-ZtProgress "Exporting $progressActivity" -Status $status
		}

		$filePath = Join-Path -Path $Path -ChildPath "$EntityName-$PageIndex.json"
		$results | Export-PSFJson -Path $filePath -Depth 100 -Encoding UTF8NoBom
		$CurrentCount
	}

	function Get-Status {
		[CmdletBinding()]
		param (
			$CurrentCount,

			$TotalCount,

			[switch]
			$ShowCount,

			$Result
		)
		if ($ShowCount -and $null -ne $result) {
			"$CurrentCount of $TotalCount : $($result.displayName)"
		}
		else {
			"Retrieved $CurrentCount items..."
		}
	}

	function Add-GraphProperty {
		[CmdletBinding()]
		param (
			$Result,

			[string]
			$PropertyName,

			[string]
			$EntityName,

			[string]
			$EntityUri
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
	#endregion Utility FUnctions

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

	do {
		$results = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType HashTable
		$currentCount = Export-Page -PageIndex $pageIndex -Path $folderPath -Results $results -RelatedPropertyNames $RelatedPropertyNames -EntityName $EntityName -EntityUri $EntityUri -CurrentCount $currentCount -TotalCount $totalCount -ProgressActivity $ProgressActivity -ShowCount:$ShowCount

		if (-not $results) {
			$uri = $null
		}
		else {
			$uri = $results.'@odata.nextLink'
		}
		$pageIndex++

		if (-not $uri) {
			break
		}
		elseif ($hasTimeLimit -and (Get-Date) -gt $stopTime) {
			Write-PSFMessage "Maximum time limit reached for $EntityName"
			break
		}
	}
	while ($true)

	Set-ZtConfig -ExportPath $ExportPath -Property $EntityName -Value $true
}
