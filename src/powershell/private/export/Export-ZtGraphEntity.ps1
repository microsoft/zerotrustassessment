function Export-ZtGraphEntity {
	<#
	.SYNOPSIS
		Export all graph items of a specified url.

	.DESCRIPTION
		Export all graph items of a specified url.
		Will generate them in a paged file format, with each response set written to a single file., a numbered suffix counting up with each page.

		It will also ensure, that previous data is first cleaned up (e.g. if the last export was interrupted).

	.PARAMETER Name
		The name of the entity to export.
		This will also become the name of the folder under which the content is stored.

	.PARAMETER Uri
		The relative Uri from where to collect the data.
		E.g.: beta/applications
		To export all applications.

	.PARAMETER QueryString
		Additional query information to include with the request.
		Use this to speciy page-size information, properties to collect or other relevant parameters needed for this to work.

	.PARAMETER RelatedPropertyNames
		Additional sub-datasets to retrieve for each entity.
		For example in cases, where multiple requests are needed - such as "oauth2PermissionGrants" for Service Principals.

	.PARAMETER MaximumQueryTime
		Maximum time we will spend on this query, iterating through the pages.

	.PARAMETER ExportPath
		Where all the results are stored.

	.EXAMPLE
		PS C:\> Export-ZtGraphEntity -Name Application -Uri 'beta/applications' -QueryString '$top=999' -ExportPath C:\assessment\export

		Retrieves all applications (=App Registrations) from the tenant using the beta api and page-size of 999.
	#>
	[CmdletBinding()]
	param (
		# The folder for the entity. e.g. ServicePrincipals
		[Parameter(Mandatory = $true)]
		[string]
		$Name,

		# The entity to export. e.g. /beta/servicePrincipals
		[Parameter(Mandatory = $true)]
		[string]
		$Uri,

		# Parameters to include. e.g. $expand=appRoleAssignments&$top=999
		[Parameter(Mandatory = $false)]
		[string]
		$QueryString,

		# The additional properties/relations to be queried for each object. e.g. oauth2PermissionGrants
		[string[]]
		$RelatedPropertyNames,

		# The maximum time (in minutes) the assessment should spend on querying this entity.
		[int]
		$MaximumQueryTime,

		# The folder to output the report to.
		[Parameter(Mandatory = $true)]
		[string]
		$ExportPath
	)

	# Get maximum size limit for SignIn logs (1GB by default)
	$maxSizeBytes = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Export.SignInLog.MaxSizeBytes' -Fallback 1073741824
	if (Get-ZtConfig -ExportPath $ExportPath -Property $Name) {
		Write-PSFMessage "Skipping '{0}' since it was downloaded previously" -StringValues $Name -Target $Name -Tag Export, redundant, skip
		return
	}

	#region Utility Functions
	function Export-Page {
		[CmdletBinding()]
		param (
			[int]
			$PageIndex,

			[string]
			$Path,

			$Results,

			[string[]]
			$RelatedPropertyNames,

			[string]
			$Name,

			[string]
			$Uri
		)
		Write-PSFMessage "Exporting $Name page $PageIndex"
		$newResults = $Results

		if ($RelatedPropertyNames) {
			$items = $Results.Value
			foreach ($propertyName in $RelatedPropertyNames) {
				Add-GraphProperty -Results $items -PropertyName $propertyName -Name $Name -Uri $Uri
			}
			$newResults = @{ value = $items }
		}

		$filePath = Join-Path -Path $Path -ChildPath "$Name-$PageIndex.json"
		$newResults | Export-PSFJson -Path $filePath -Depth 100 -Encoding UTF8NoBom
	}

	function Add-GraphProperty {
		[CmdletBinding()]
		param (
			$Results,

			[string]
			$PropertyName,

			[string]
			$Name,

			[string]
			$Uri
		)

		Write-PSFMessage -Message "Adding {0} to {1}" -StringValues $PropertyName, $Name -Tag Graph

		$data = Invoke-ZtGraphBatchRequest -Path "$Uri/{0}/$PropertyName" -ArgumentList $Results -Properties id -Matched -ErrorAction SilentlyContinue -ErrorVariable failed
		# Since the argument property is the original hashtable provided, we can update the hashtable as it is and thereby update the original object
		foreach ($pair in $data) {
			if (-not $Pair.Success) {
				Write-PSFMessage -Level Warning "Failed to retrieve {0} for {1}" -StringValues $PropertyName, $pair.Argument.id -Target $pair
				continue
			}

			$pair.Argument[$PropertyName] = $($pair.Result)
		}

		foreach ($fail in $failed) {
			$itemID = $fail.TargetObject.url.replace($PropertyName,"").Trim("/").Split("/")[-1]

			if ($Name -eq "SignIn" -and $fail.Exception.Message -like "*The request was canceled due to the configured HttpClient.Timeout*") {
				Write-PSFMessage -Level Verbose "Timeout occurred while adding $PropertyName to $Name $itemID - silently continuing" -Tag Graph
			}
			else {
				Write-PSFMessage -Level Warning "Failed to add $PropertyName to $Name $itemID." -Tag Graph -ErrorRecord $fail
			}
		}
	}
	#endregion Utility Functions

	$pageIndex = 0
	$totalSize = 0
	$isSignInLog = $Name -eq 'SignIn'

	$folderPath = Join-Path -Path $ExportPath -ChildPath $Name
	Clear-ZtFolder -Path $folderPath

	$actualUri = $Uri + '?' + $QueryString
	$startTime = Get-Date
	$stopTime = $startTime.AddMinutes($MaximumQueryTime)
	$hasTimeLimit = $MaximumQueryTime -gt 0

	do {
		$results = Invoke-MgGraphRequest -Method GET -Uri $actualUri -OutputType HashTable
		Export-Page -PageIndex $pageIndex -Path $folderPath -Results $results -RelatedPropertyNames $RelatedPropertyNames -Name $Name -Uri $Uri

		# Track file size for SignIn logs
		if ($isSignInLog) {
			$lastFile = Join-Path -Path $folderPath -ChildPath "$Name-$pageIndex.json"
			if (Test-Path $lastFile) {
				$fileSize = (Get-Item $lastFile).Length
				$totalSize += $fileSize

				if ($totalSize -gt $maxSizeBytes) {
					$sizeMB = [math]::Round($totalSize / 1MB, 2)
					$limitMB = [math]::Round($maxSizeBytes / 1MB, 2)
					Write-PSFMessage -Level Warning "Sign-in log export reached size limit of $limitMB MB (current: $sizeMB MB). Stopping export and continuing with next task." -Tag Export, SignIn, SizeLimit
					Write-Host "⚠️ " -NoNewline -ForegroundColor Yellow
					Write-Host "Sign-in log export reached the 1GB size limit ($sizeMB MB collected). Continuing with remaining exports..." -ForegroundColor Yellow
					break
				}
			}
		}

		if (-not $results) {
			$actualUri = $null
		}
		else {
			$actualUri = $results.'@odata.nextLink'
		}
		$pageIndex++

		if (-not $actualUri) {
			break
		}
		elseif ($hasTimeLimit -and (Get-Date) -gt $stopTime) {
			Write-PSFMessage "Maximum time limit reached for $Name"
			break
		}
	}
	while ($true)

	Set-ZtConfig -ExportPath $ExportPath -Property $Name -Value $true
}
