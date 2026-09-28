function Resolve-ZtRoleAssignmentPrincipal {
	[CmdletBinding()]
	param (
		[object[]]
		$Assignments,

		[Parameter(Mandatory = $true)]
		[hashtable]
		$Cache
	)

	if (-not $Assignments) {
		return
	}

	$unresolved = @{}
	$completedLookups = @{}
	foreach ($assignment in $Assignments) {
		$principal = $assignment.principal
		$principalId = if ($principal.id) { $principal.id } else { $assignment.principalId }
		if (-not $principalId) {
			continue
		}

		$hasNewPrincipalData = $false
		if (-not $Cache.ContainsKey($principalId)) {
			$Cache[$principalId] = @{
				'@odata.type' = $principal.'@odata.type'
				id = $principalId
				displayName = $principal.displayName
				userPrincipalName = $principal.userPrincipalName
				uniqueName = $principal.uniqueName
				'__ztLookupAttempted' = $false
			}
			$hasNewPrincipalData = $true
		}
		else {
			$cachedType = $Cache[$principalId]['@odata.type']
			$incomingType = $principal.'@odata.type'
			$isDerivedType =
				($cachedType -eq '#microsoft.graph.user' -and $incomingType -eq '#microsoft.graph.agentUser') -or
				($cachedType -eq '#microsoft.graph.servicePrincipal' -and $incomingType -in @('#microsoft.graph.agentIdentity', '#microsoft.graph.agentIdentityBlueprintPrincipal'))
			if ($incomingType -and (-not $cachedType -or $isDerivedType)) {
				$Cache[$principalId]['@odata.type'] = $incomingType
				$hasNewPrincipalData = $true
			}

			foreach ($propertyName in 'displayName', 'userPrincipalName', 'uniqueName') {
				if (-not $Cache[$principalId][$propertyName] -and $principal.$propertyName) {
					$Cache[$principalId][$propertyName] = $principal.$propertyName
					$hasNewPrincipalData = $true
				}
			}
		}

		$lookupAttempted = $Cache[$principalId]['__ztLookupAttempted']
		$isIncomplete = -not $Cache[$principalId]['@odata.type'] -or -not $Cache[$principalId].displayName
		if ($isIncomplete -and (-not $lookupAttempted -or $hasNewPrincipalData)) {
			$unresolved[$principalId] = $Cache[$principalId]['@odata.type']
		}
		elseif (-not $isIncomplete) {
			[void]$unresolved.Remove($principalId)
		}
	}

	$missingTypeIds = @($unresolved.Keys | Where-Object { -not $unresolved[$_] })
	for ($index = 0; $index -lt $missingTypeIds.Count; $index += 1000) {
		$lastIndex = [Math]::Min($index + 999, $missingTypeIds.Count - 1)
		$ids = @($missingTypeIds[$index..$lastIndex])
		$body = @{
			ids = $ids
			types = @('user', 'group', 'servicePrincipal')
		} | ConvertTo-Json -Depth 3 -Compress

		try {
			$typeResults = @(Invoke-ZtGraphRequest -RelativeUri 'directoryObjects/getByIds' -Method POST -Body $body -ApiVersion beta -OutputType Hashtable -DisableCache)
			foreach ($result in $typeResults) {
				if ($result.id -and $unresolved.ContainsKey($result.id)) {
					$unresolved[$result.id] = $result.'@odata.type'
					$Cache[$result.id]['@odata.type'] = $result.'@odata.type'
				}
			}
			foreach ($id in $ids) {
				if (-not $unresolved[$id]) {
					$completedLookups[$id] = $true
				}
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message 'Failed to resolve role principal types.' -ErrorRecord $_ -Tag Graph, Export
		}
	}

	$typeDefinitions = @(
		@{
			ODataType = '#microsoft.graph.user'
			ODataTypes = @('#microsoft.graph.user', '#microsoft.graph.agentUser')
			RelativeUri = 'users'
			Select = @('id', 'displayName', 'userPrincipalName')
		},
		@{
			ODataType = '#microsoft.graph.group'
			ODataTypes = @('#microsoft.graph.group')
			RelativeUri = 'groups'
			Select = @('id', 'displayName', 'uniqueName')
		},
		@{
			ODataType = '#microsoft.graph.servicePrincipal'
			ODataTypes = @(
				'#microsoft.graph.servicePrincipal'
				'#microsoft.graph.agentIdentity'
				'#microsoft.graph.agentIdentityBlueprintPrincipal'
			)
			RelativeUri = 'servicePrincipals'
			Select = @('id', 'displayName')
		}
	)

	foreach ($typeDefinition in $typeDefinitions) {
		$principalIds = @($unresolved.Keys | Where-Object { $unresolved[$_] -in $typeDefinition.ODataTypes })
		if (-not $principalIds) {
			continue
		}

		try {
			$principals = @(Invoke-ZtGraphRequest -RelativeUri $typeDefinition.RelativeUri -UniqueId $principalIds -Select $typeDefinition.Select -ApiVersion beta -OutputType Hashtable -DisableCache)
			foreach ($principalId in $principalIds) {
				$completedLookups[$principalId] = $true
			}
			foreach ($principal in $principals) {
				if (-not $principal.id -or $principal.id -notin $principalIds -or -not $Cache.ContainsKey($principal.id)) {
					continue
				}

				$cachedType = $Cache[$principal.id]['@odata.type']
				$resolvedType = $principal.'@odata.type'
				if (-not $resolvedType -or ($resolvedType -eq $typeDefinition.ODataType -and $cachedType -ne $typeDefinition.ODataType)) {
					$resolvedType = $cachedType
				}
				if (-not $resolvedType) {
					$resolvedType = $typeDefinition.ODataType
				}

				$Cache[$principal.id] = @{
					'@odata.type' = $resolvedType
					id = $principal.id
					displayName = if ($principal.displayName) { $principal.displayName } else { $Cache[$principal.id].displayName }
					userPrincipalName = if ($principal.userPrincipalName) { $principal.userPrincipalName } else { $Cache[$principal.id].userPrincipalName }
					uniqueName = if ($principal.uniqueName) { $principal.uniqueName } else { $Cache[$principal.id].uniqueName }
					'__ztLookupAttempted' = $Cache[$principal.id]['__ztLookupAttempted']
				}
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message 'Failed to enrich {0} role principals.' -StringValues $typeDefinition.ODataType -ErrorRecord $_ -Tag Graph, Export
		}
	}

	$supportedTypes = @($typeDefinitions | ForEach-Object { $_.ODataTypes })
	foreach ($principalId in $unresolved.Keys) {
		if ($unresolved[$principalId] -and $unresolved[$principalId] -notin $supportedTypes) {
			$completedLookups[$principalId] = $true
		}
	}
	foreach ($principalId in $completedLookups.Keys) {
		$Cache[$principalId]['__ztLookupAttempted'] = $true
	}

	$unenrichedPrincipalIds = @($unresolved.Keys | Where-Object { -not $Cache[$_]['@odata.type'] -or -not $Cache[$_].displayName } | Sort-Object)
	if ($unenrichedPrincipalIds) {
		Write-PSFMessage -Level Warning -Message '{0} role principals could not be enriched. Their identifiers and known types were preserved in the export.' -StringValues $unenrichedPrincipalIds.Count -Tag Graph, Export
	}

	foreach ($assignment in $Assignments) {
		$principalId = if ($assignment.principal.id) { $assignment.principal.id } else { $assignment.principalId }
		if (-not $principalId -or -not $Cache.ContainsKey($principalId)) {
			continue
		}

		$resolvedPrincipal = @{
			'@odata.type' = $Cache[$principalId]['@odata.type']
			id = $Cache[$principalId].id
			displayName = $Cache[$principalId].displayName
			userPrincipalName = $Cache[$principalId].userPrincipalName
			uniqueName = $Cache[$principalId].uniqueName
		}
		if ($assignment -is [System.Collections.IDictionary]) {
			$assignment['principal'] = $resolvedPrincipal
		}
		else {
			$assignment.principal = [pscustomobject]$resolvedPrincipal
		}
	}
}
