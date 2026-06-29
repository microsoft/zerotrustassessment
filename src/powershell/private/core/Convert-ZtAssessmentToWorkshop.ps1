function Convert-ZtAssessmentToWorkshop {
	<#
	.SYNOPSIS
		Converts Zero Trust Assessment results into a JSON file importable by the Zero Trust Workshop.

	.DESCRIPTION
		Projects Zero Trust Assessment test results onto Zero Trust Workshop tasks
		that can be directly imported in Zero Trust Workshop.

		For every assessed test it:
		  * skips tests whose TestStatus is "Skipped" (no assessed result),
		  * resolves the test's pillar and looks up the TestId in the task mapping to find
		    the Workshop task id(s) it contributes evidence to,
		  * extracts the headline finding from TestResult,
		  * records a per-task override (status = 'not-reviewed') carrying the assessment
		    finding as notes.

		The result is the Workshop import document (metadata / configuration / statistics)
		that the Zero Trust Workshop application consumes.

	.PARAMETER AssessmentResults
		The assessment results object from Get-ZtAssessmentResults. Must expose a Tests
		collection plus TenantId / TenantName.

	.PARAMETER MappingFilePath
		Path to the pillar -> { TestId -> WorkshopTaskId } mapping file
		(build/ztw-task-mapping.json). A single TestId can map to several Workshop
		tasks by using an array of task ids.

	.PARAMETER Pillar
		Optional pillar filter. When supplied only that pillar's tests are exported and the
		document scope / current pillar reflect the selection.

	.PARAMETER KnownPillars
		The full set of Workshop pillars to initialise in the output document.

	.OUTPUTS
		[ordered] Workshop import document, ready for ConvertTo-Json.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSObject] $AssessmentResults,

		[Parameter(Mandatory = $true)]
		[string] $MappingFilePath,

		[Parameter(Mandatory = $false)]
		[string] $Pillar,

		[Parameter(Mandatory = $false)]
		[string[]] $KnownPillars = @('identity', 'devices', 'data', 'network', 'infrastructure', 'security-ops', 'ai')
	)

	function Get-ObjectValue {
		param (
			[Parameter(Mandatory = $false)]
			[object] $InputObject,

			[Parameter(Mandatory = $true)]
			[string] $Name
		)

		if ($null -eq $InputObject) { return $null }
		if ($InputObject -is [System.Collections.IDictionary]) {
			if ($InputObject.Contains($Name)) { return $InputObject[$Name] }
			return $null
		}

		$property = $InputObject.PSObject.Properties[$Name]
		if ($property) { return $property.Value }
		return $null
	}

	# The assessment pipeline passes the literal 'All' as its "no filter" sentinel.
	# Treat 'All' (and empty) as no filter; anything else is a specific pillar.
	$pillarFilterKey = $null
	if (-not [string]::IsNullOrWhiteSpace($Pillar) -and $Pillar -ine 'all') {
		$pillarFilterKey = $Pillar.ToLower()
	}

	$rawTests = Get-ObjectValue -InputObject $AssessmentResults -Name 'Tests'
	$tests = if ($null -eq $rawTests) { @() } else { @($rawTests) }

	# --- Load the mapping (a TestId may map to several Workshop tasks) ---
	$pillarMappings = @{}   # pillar -> hashtable of TestId -> List[string] of Workshop task ids
	$hasMappingFile = $false
	if (Test-Path -LiteralPath $MappingFilePath) {
		$rawMapping  = Get-Content -LiteralPath $MappingFilePath -Raw -Encoding UTF8
		$mapping = $rawMapping | ConvertFrom-Json -ErrorAction Stop
		foreach ($pillarProperty in $mapping.PSObject.Properties) {
			$pillarKey = $pillarProperty.Name.ToLower()
			$pillarMappings[$pillarKey] = @{}
			if ($null -eq $pillarProperty.Value) { continue }

			foreach ($entryProperty in $pillarProperty.Value.PSObject.Properties) {
				$testId = [string]$entryProperty.Name
				$taskIds = [System.Collections.Generic.List[string]]::new()
				foreach ($taskId in @($entryProperty.Value)) {
					if ($null -eq $taskId) { continue }
					$taskIdText = [string]$taskId
					if ([string]::IsNullOrWhiteSpace($taskIdText)) { continue }
					if (-not $taskIds.Contains($taskIdText)) { $taskIds.Add($taskIdText) }
				}

				if ($taskIds.Count -gt 0) {
					$pillarMappings[$pillarKey][$testId] = $taskIds
				}
			}
		}
		$hasMappingFile = $true
	}
	else {
		Write-PSFMessage -Level Warning -Message "Workshop task mapping not found: $MappingFilePath. Tests will be keyed by TestId directly."
	}

	# --- Initialise pillars ---
	$pillars = [ordered]@{}
	if ($pillarFilterKey) {
		$pillars[$pillarFilterKey] = [ordered]@{ taskOverrides = [ordered]@{} }
	}
	else {
		foreach ($p in $KnownPillars) {
			$pillars[$p] = [ordered]@{ taskOverrides = [ordered]@{} }
		}
	}

	# --- Process each test ---
	$modifiedCount  = 0
	$collectedNotes = @{}   # "pillar|taskId" -> List[string] of findings

	foreach ($test in $tests) {
		$testId = [string](Get-ObjectValue -InputObject $test -Name 'TestId')

		$testStatus = [string](Get-ObjectValue -InputObject $test -Name 'TestStatus')
		if ($testStatus -ieq 'Skipped') { continue }

		# TestPillar may be a scalar string OR an array (cross-referenced / multi-pillar
		# tests). In-memory it is frequently a single-element array that only collapses to a
		# scalar once serialized to JSON, so normalise to a list of scalar pillar strings.
		$pillarRaw = Get-ObjectValue -InputObject $test -Name 'TestPillar'
		$pillarNames = @($pillarRaw) | ForEach-Object { "$_" } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
		if ($pillarNames.Count -eq 0) { continue }

		# Extract the headline finding: first non-empty line of TestResult (computed once).
		$testResult = Get-ObjectValue -InputObject $test -Name 'TestResult'
		$notesText  = ''
		if (-not [string]::IsNullOrEmpty($testResult)) {
			$nl = if ($testResult.Contains("`n")) { "`n" } elseif ($testResult.Contains('\n')) { '\n' } else { $null }
			if ($null -ne $nl) {
				# Use the String[] overload so a multi-character separator (literal '\n')
				# is matched as a sequence rather than as a char set ('\' or 'n').
				foreach ($part in $testResult.Split([string[]]@($nl), [System.StringSplitOptions]::None)) {
					$trimmed = $part.Trim()
					if ($trimmed.Length -gt 0) { $notesText = $trimmed; break }
				}
			}
			else {
				$notesText = $testResult.Trim()
			}
		}

		foreach ($pillarName in $pillarNames) {
			$pillarKey = $pillarName.ToLower()

			if ($pillarFilterKey -and $pillarKey -ne $pillarFilterKey) { continue }

			# Resolve the Workshop task id(s) this test contributes to within this pillar.
			if ($hasMappingFile) {
				$pillarMap = if ($pillarMappings.ContainsKey($pillarKey)) { $pillarMappings[$pillarKey] } else { @{} }
				if ($pillarMap.ContainsKey($testId)) {
					$overrideIds = $pillarMap[$testId]
				}
				else {
					continue   # test not mapped to any Workshop task in this pillar
				}
			}
			else {
				$overrideIds = @($testId)
			}

			if (-not $pillars.Contains($pillarKey)) {
				$pillars[$pillarKey] = [ordered]@{ taskOverrides = [ordered]@{} }
			}

			foreach ($overrideId in $overrideIds) {
				if ($notesText.Length -gt 0) {
					$noteKey = "$pillarKey|$overrideId"
					if (-not $collectedNotes.ContainsKey($noteKey)) {
						$collectedNotes[$noteKey] = [System.Collections.Generic.List[string]]::new()
					}
					$collectedNotes[$noteKey].Add($notesText)
				}

				if (-not $pillars[$pillarKey].taskOverrides.Contains($overrideId)) {
					$pillars[$pillarKey].taskOverrides[$overrideId] = [ordered]@{
						status = 'not-reviewed'
						notes  = ''
					}
					$modifiedCount++
				}
			}
		}
	}

	# --- Combine collected notes (dedup identical lines; importer rejects repeats) ---
	# The Workshop importer rejects any task whose notes field exceeds this many
	# characters (spaces included). The combined notes for each task - including the
	# "ZT Assessment result:" wrapper - are hard-capped to this length so the export
	# always imports successfully regardless of how many tests map to one task.
	$maxNotesLength = 1000
	# Horizontal ellipsis for the "more findings" marker, built from a code point so
	# the marker text is never affected by how this script file itself is decoded.
	$ellipsis = [char]::ConvertFromUtf32(0x2026)

	foreach ($noteKey in $collectedNotes.Keys) {
		$parts = $noteKey -split '\|', 2
		$pKey  = $parts[0]
		$oKey  = $parts[1]
		$uniqueLines = [System.Collections.Generic.List[string]]::new()
		$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
		foreach ($line in $collectedNotes[$noteKey]) {
			if ($seen.Add($line)) { $uniqueLines.Add($line) }
		}

		# Hard-cap the final notes to $maxNotesLength characters (wrapper included).
		# Keep whole lines and, when truncation is needed, append a marker noting how
		# many findings were dropped so nothing looks silently lost. Truncating on
		# line boundaries keeps each retained finding readable.
		$prefix     = "ZT Assessment result:`n"
		$suffix     = "`n"
		$bodyBudget = $maxNotesLength - $prefix.Length - $suffix.Length

		$combined = ($uniqueLines) -join "`n"
		if ($combined.Length -le $bodyBudget) {
			$finalBody = $combined
		}
		else {
			$total      = $uniqueLines.Count
			$kept       = [System.Collections.Generic.List[string]]::new()
			$runningLen = 0
			for ($idx = 0; $idx -lt $total; $idx++) {
				$line = $uniqueLines[$idx]
				$sep  = if ($kept.Count -gt 0) { 1 } else { 0 }
				$prospective = $runningLen + $sep + $line.Length
				# Reserve room for the drop marker if any lines would remain after this one.
				$dropAfter = $total - ($kept.Count + 1)
				$markerLen = if ($dropAfter -gt 0) { 1 + "$ellipsis(+$dropAfter more findings)".Length } else { 0 }
				if (($prospective + $markerLen) -le $bodyBudget) {
					$kept.Add($line)
					$runningLen = $prospective
				}
				else {
					break
				}
			}
			$dropped   = $total - $kept.Count
			$finalBody = ($kept) -join "`n"
			if ($dropped -gt 0) {
				$marker = "$ellipsis(+$dropped more findings)"
				$finalBody = if ($finalBody.Length -gt 0) { "$finalBody`n$marker" } else { $marker }
			}
			Write-PSFMessage -Level Warning -Message "Notes for $pKey/$oKey exceeded $maxNotesLength chars; kept $($kept.Count) of $total finding(s)."
		}

		$pillars[$pKey].taskOverrides[$oKey].notes = "$prefix$finalBody$suffix"
	}

	# --- Statistics ---
	$pillarsWithChanges = @()
	foreach ($pKey in $pillars.Keys) {
		if ($pillars[$pKey].taskOverrides.Count -gt 0) { $pillarsWithChanges += $pKey }
	}

	$timestamp           = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
	$exportScope         = if ($pillarFilterKey) { $pillarFilterKey } else { 'all' }
	$currentPillarOutput = if ($pillarFilterKey) { $pillarFilterKey } else { 'identity' }

	$output = [ordered]@{
		metadata      = [ordered]@{
			version            = '1.0.0'
			formatVersion      = '1.0'
			exportedAt         = $timestamp
			applicationVersion = '1.0.0'
			exportType         = 'full-configuration'
			scope              = $exportScope
			description        = 'Zero Trust Assessment Result Export'
		}
		configuration = [ordered]@{
			applicationState = [ordered]@{
				currentPillar = $currentPillarOutput
				lastModified  = $timestamp
			}
			pillars          = $pillars
			globalSettings   = [ordered]@{
				preferences = [ordered]@{
					autoSave            = $true
					confirmationDialogs = $true
				}
			}
		}
		statistics    = [ordered]@{
			totalTasks         = $tests.Count
			modifiedTasks      = $modifiedCount
			completedTasks     = 0
			inProgressTasks    = 0
			plannedTasks       = 0
			pillarsWithChanges = $pillarsWithChanges
		}
	}

	return $output
}
