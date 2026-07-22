Describe "Convert-ZtAssessmentToWorkshop" {
	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $StringValues, $ErrorRecord, $Tag)
			}
		}

		. (Join-Path $srcRoot "private/core/Convert-ZtAssessmentToWorkshop.ps1")

		# A small mapping file mirroring the real ztw-task-mapping.json shape,
		# including a TestId that maps to two different Workshop tasks.
		$script:mappingPath = Join-Path $TestDrive "ztw-task-mapping.json"
		@'
{
  "identity": {
	"21776": ["RMI_065"],
	"21777": ["RMI_065"],
	"21800": ["RMI_001", "RMI_002"]
  },
  "devices": {
	"24540": ["DEV-088"]
  },
  "data": {},
  "network": {},
  "infrastructure": {},
	"secops": {},
  "ai": {}
}
'@ | Set-Content -LiteralPath $script:mappingPath -Encoding UTF8

		function script:New-Test {
			param($Id, $Pillar, $Status, $Result)
			[PSCustomObject]@{
				TestId     = $Id
				TestPillar = $Pillar
				TestStatus = $Status
				TestResult = $Result
			}
		}

		function script:New-Assessment {
			param([object[]]$Tests)
			[PSCustomObject]@{
				TenantId   = '00000000-0000-0000-0000-000000000001'
				TenantName = 'Contoso'
				Tests      = $Tests
			}
		}

		# Status icons the converter prepends to each finding, built from the same code
		# points as the function so these expectations are encoding-independent.
		$script:iconPassed  = [char]::ConvertFromUtf32(0x2705)
		$script:iconFailed  = [char]::ConvertFromUtf32(0x274C)
		$script:iconWarning = [char]::ConvertFromUtf32(0x26A0) + [char]0xFE0F
	}

	BeforeEach {
		Mock Write-PSFMessage {}
	}

	Context "Mapping resolution" {
		It "Maps a TestId to its Workshop task id and creates a taskOverride" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`nUser consent not restricted`nDetails" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].status | Should -Be 'not-reviewed'
		}

		It "Skips tests that have no mapping entry" {
			$a = New-Assessment @( New-Test '99999' 'Identity' 'Failed' "`nUnmapped finding" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Count | Should -Be 0
		}

		It "Honours array-valued TestId mappings to multiple tasks" {
			$a = New-Assessment @( New-Test '21800' 'Identity' 'Failed' "`nFinding" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_001') | Should -BeTrue
			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_002') | Should -BeTrue
		}

		It "Reads native hashtable test entries from assessment results" {
			$a = New-Assessment @(
				@{ TestId = '21776'; TestPillar = 'Identity'; TestStatus = 'Failed'; TestResult = "`nHashtable finding" }
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Hashtable finding`n"
		}
	}

	Context "Evidence (notes) carry-over" {
		It "Captures the first non-empty line of TestResult as the finding" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`nUser consent not restricted`nMore detail" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) User consent not restricted`n"
		}

		It "Combines and de-duplicates findings from multiple tests mapped to the same task" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed' "`nShared finding"
				New-Test '21777' 'Identity' 'Failed' "`nShared finding"
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			# Only one unique line should remain despite two contributing tests.
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Shared finding`n"
		}
	}

	Context "Status icons and emoji de-dup" {
		It "Prepends a check-mark icon for Passed findings" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Passed' "`nAll good" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconPassed) All good`n"
		}

		It "Prepends a warning icon for non-Passed/Failed statuses" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Warning' "`nNeeds review" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconWarning) Needs review`n"
		}

		It "Strips a pre-existing leading status emoji before adding its own (no doubling)" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`n$($script:iconFailed) Already flagged" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Already flagged`n"
		}
	}

	Context "Markdown cleanup" {
		It "Unwraps a markdown link and drops the URL" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`n[Portal](https://aka.ms/x) needs configuration" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Portal needs configuration`n"
		}

		It "Strips a leading markdown heading marker" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`n## Heading text" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Heading text`n"
		}

		It "Removes bold emphasis markers" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`n**bold** finding" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) bold finding`n"
		}

		It "Preserves a backtick code span, including one beginning with 'n'" {
			# Regression for the code-span corruption fix: the literal backtick must be
			# built with a single-quoted segment so it is not treated as an escape.
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' ("`n" + 'Configure `networkPolicy` before deployment') )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$expected = "ZT Assessment result:`n" + $script:iconFailed + ' Configure `networkPolicy` before deployment' + "`n"
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes | Should -Be $expected
		}

		It "Collapses a standalone literal PowerShell newline escape (`n)" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' ("`n" + 'First `n Second') )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) First Second`n"
		}

		It "Collapses a standalone literal C-style newline escape (\n)" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' ("`n" + 'First \n Second') )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) First Second`n"
		}

		It "Leaves a backslash path (e.g. C:\next) untouched" {
			# Do not prefix a real newline: headline extraction must not mistake the
			# path's literal "\n" for a C-style newline delimiter.
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' 'Path C:\next config' )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$expected = "ZT Assessment result:`n" + $script:iconFailed + ' Path C:\next config' + "`n"
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes | Should -Be $expected
		}
	}

	Context "Empty findings" {
		It "Does not emit an icon-only note when a finding is a status symbol only" {
			# TestResult is nothing but a status emoji; after stripping it, no text remains
			# so no bogus "<icon> " note should be produced for the mapped task.
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' ("`n" + $script:iconPassed) )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
			$notes = $result.configuration.pillars.identity.taskOverrides['RMI_065'].notes
			$notes | Should -Be ''
			$notes | Should -Not -Match ([regex]::Escape($script:iconFailed))
		}
	}

	Context "Long-line compaction" {
		It "Compacts a finding longer than 200 characters to the TestTitle" {
			$long = 'x' * 250
			$a = New-Assessment @(
				[PSCustomObject]@{ TestId = '21776'; TestPillar = 'Identity'; TestStatus = 'Failed'; TestTitle = 'Concise title'; TestResult = "`n$long" }
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Concise title`n"
		}

		It "Leaves a finding of 200 characters or fewer unchanged" {
			$exact = 'y' * 200
			$a = New-Assessment @(
				[PSCustomObject]@{ TestId = '21776'; TestPillar = 'Identity'; TestStatus = 'Failed'; TestTitle = 'T'; TestResult = "`n$exact" }
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) $exact`n"
		}
	}

	Context "Filtering" {
		It "Excludes tests with TestStatus = Skipped" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Skipped' "`nShould be ignored" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides.Count | Should -Be 0
		}

		It "Restricts output to a single pillar when -Pillar is supplied" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed' "`nIdentity finding"
				New-Test '24540' 'Devices'  'Failed' "`nDevice finding"
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath -Pillar 'identity'

			$result.configuration.pillars.Contains('identity') | Should -BeTrue
			$result.configuration.pillars.Contains('devices')  | Should -BeFalse
			$result.metadata.scope | Should -Be 'identity'
		}

		It "Treats -Pillar 'All' as no filter (pipeline default sentinel)" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed' "`nIdentity finding"
				New-Test '24540' 'Devices'  'Failed' "`nDevice finding"
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath -Pillar 'All'

			$result.metadata.scope | Should -Be 'all'
			$result.configuration.pillars.Contains('all') | Should -BeFalse
			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
			$result.configuration.pillars.devices.taskOverrides.Contains('DEV-088') | Should -BeTrue
			$result.statistics.pillarsWithChanges | Should -Contain 'identity'
			$result.statistics.pillarsWithChanges | Should -Contain 'devices'
		}
	}

	Context "TestPillar shape handling (in-memory arrays)" {
		It "Handles TestPillar delivered as a single-element array (in-memory shape)" {
			$a = New-Assessment @(
				[PSCustomObject]@{ TestId = '21776'; TestPillar = @('Identity'); TestStatus = 'Failed'; TestResult = "`nArray pillar finding" }
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath -Pillar 'All'

			$result.statistics.modifiedTasks | Should -Be 1
			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
		}

		It "Maps a multi-pillar test into every pillar where its TestId is mapped" {
			$a = New-Assessment @(
				[PSCustomObject]@{ TestId = '21776'; TestPillar = @('Identity', 'Devices'); TestStatus = 'Failed'; TestResult = "`nCross-pillar finding" }
			)
			# 21776 maps in identity (RMI_065); not present in devices map -> only identity override.
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath -Pillar 'All'

			$result.configuration.pillars.identity.taskOverrides.Contains('RMI_065') | Should -BeTrue
			$result.configuration.pillars.devices.taskOverrides.Count | Should -Be 0
		}
	}

	Context "Output document shape" {
		It "Produces the Workshop import structure with metadata, configuration and statistics" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`nFinding" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.metadata.exportType | Should -Be 'full-configuration'
			$result.configuration.globalSettings.preferences.autoSave | Should -BeTrue
			$result.statistics.totalTasks | Should -Be 1
			$result.statistics.modifiedTasks | Should -Be 1
			$result.statistics.pillarsWithChanges | Should -Contain 'identity'
		}
	}

	Context "Notes length hard-cap" {
		It "Caps combined notes at 1000 characters and appends a drop marker" {
			# 60 unique short findings all map to RMI_065; combined they exceed the cap.
			$tests = 1..60 | ForEach-Object {
				New-Test '21776' 'Identity' 'Failed' "`nFinding number $_ with some detail text"
			}
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults (New-Assessment $tests) -MappingFilePath $script:mappingPath

			$notes = $result.configuration.pillars.identity.taskOverrides['RMI_065'].notes
			$notes.Length | Should -BeLessOrEqual 1000
			$notes | Should -Match '\(\+\d+ more findings\)'
			$notes | Should -BeLike 'ZT Assessment result:*'
		}

		It "Leaves notes unchanged when comfortably under the cap" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`nShort finding" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`n$($script:iconFailed) Short finding`n"
		}
	}

	Context "Skip diagnostics" {
		It "Emits a Verbose message counting tests skipped for TestStatus = Skipped" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed'  "`nKept"
				New-Test '21777' 'Identity' 'Skipped' "`nIgnored"
			)
			$null = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			Should -Invoke Write-PSFMessage -ParameterFilter {
				$Level -eq 'Verbose' -and $Message -match "Skipped 1 test\(s\) with TestStatus = 'Skipped'\."
			}
		}

		It "Emits a Verbose message counting tests skipped by the -Pillar filter" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed' "`nIdentity finding"
				New-Test '24540' 'Devices'  'Failed' "`nDevice finding"
			)
			$null = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath -Pillar 'identity'

			Should -Invoke Write-PSFMessage -ParameterFilter {
				$Level -eq 'Verbose' -and $Message -match "outside the selected pillar 'identity'"
			}
		}
	}
}
