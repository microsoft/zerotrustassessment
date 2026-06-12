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
				Should -Be "ZT Assessment result:`nHashtable finding`n"
		}
	}

	Context "Evidence (notes) carry-over" {
		It "Captures the first non-empty line of TestResult as the finding" {
			$a = New-Assessment @( New-Test '21776' 'Identity' 'Failed' "`nUser consent not restricted`nMore detail" )
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`nUser consent not restricted`n"
		}

		It "Combines and de-duplicates findings from multiple tests mapped to the same task" {
			$a = New-Assessment @(
				New-Test '21776' 'Identity' 'Failed' "`nShared finding"
				New-Test '21777' 'Identity' 'Failed' "`nShared finding"
			)
			$result = Convert-ZtAssessmentToWorkshop -AssessmentResults $a -MappingFilePath $script:mappingPath

			# Only one unique line should remain despite two contributing tests.
			$result.configuration.pillars.identity.taskOverrides['RMI_065'].notes |
				Should -Be "ZT Assessment result:`nShared finding`n"
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
}
