Describe "ReportTemplate markers" {
	# Defined at discovery time so the -ForEach cases below can be expanded.
	$script:AssetRoot = Join-Path $PSScriptRoot "../../src/powershell/assets"
	$script:TemplateCases = @(
		@{ Name = 'ReportTemplate.html'; Path = (Join-Path $script:AssetRoot 'ReportTemplate.html'); IsDefault = $true }
		@{ Name = 'ReportTemplate.classic.html'; Path = (Join-Path $script:AssetRoot 'ReportTemplate.classic.html'); IsDefault = $false }
	)

	BeforeAll {
		$here = $PSScriptRoot
		$srcRoot = Join-Path $here "../../src/powershell"

		if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
			function global:Write-PSFMessage {
				param($Level, $Message, $StringValues, $ErrorRecord, $Tag)
			}
		}

		# Get-HtmlReport resolves the default template relative to $script:ModuleRoot.
		$script:ModuleRoot = (Resolve-Path $srcRoot).Path
		. (Join-Path $srcRoot "private/core/Get-HtmlReport.ps1")

		$script:StartMarker = 'reportData={'
		$script:EndMarker = 'EndOfJson:"EndOfJson"}'

		function script:Measure-Marker {
			param([string]$Content, [string]$Marker)
			([regex]::Matches($Content, [regex]::Escape($Marker))).Count
		}
	}

	Context "Template <Name>" -ForEach $script:TemplateCases {
		BeforeAll {
			$script:TemplateContent = if (Test-Path $Path -PathType Leaf) { Get-Content -Path $Path -Raw } else { '' }
		}

		It "exists and is a fully built bundle" {
			$Path | Should -Exist
			(Get-Item $Path).Length | Should -BeGreaterThan 100KB
		}

		It "contains exactly one JSON start marker" {
			Measure-Marker -Content $script:TemplateContent -Marker $script:StartMarker | Should -Be 1
		}

		It "contains exactly one JSON end marker" {
			Measure-Marker -Content $script:TemplateContent -Marker $script:EndMarker | Should -Be 1
		}

		It "has the end marker after the start marker" {
			$script:TemplateContent.IndexOf($script:EndMarker) |
				Should -BeGreaterThan $script:TemplateContent.IndexOf($script:StartMarker)
		}

		It "is self-contained with no external script or stylesheet references" {
			([regex]::Matches($script:TemplateContent, '<script[^>]+\ssrc=')).Count | Should -Be 0
			([regex]::Matches($script:TemplateContent, '<link[^>]+stylesheet')).Count | Should -Be 0
		}
	}

	Context "Get-HtmlReport round trip" {
		BeforeAll {
			$script:FakeResults = @{
				TenantId   = 'ffffffff-1111-2222-3333-444444444444'
				TenantName = 'ZtMarkerRoundTripTenant'
				Tests      = @()
				EndOfJson  = 'EndOfJson'
			} | ConvertTo-Json -Depth 5 -Compress

			$script:WorkPath = Join-Path $TestDrive 'report'
			$null = New-Item -ItemType Directory -Path $script:WorkPath -Force
		}

		It "injects the payload into <Name>" -ForEach $script:TemplateCases {
			$html = if ($IsDefault) {
				Get-HtmlReport -AssessmentResults $script:FakeResults -Path $script:WorkPath
			}
			else {
				Get-HtmlReport -AssessmentResults $script:FakeResults -Path $script:WorkPath -TemplatePath $Path
			}

			$html | Should -Match 'ZtMarkerRoundTripTenant'
			# The placeholder payload is replaced wholesale, so its sentinel must be gone.
			Measure-Marker -Content $html -Marker $script:EndMarker | Should -Be 0
		}

		It "throws a clear error when the markers are missing" {
			$broken = Join-Path $script:WorkPath 'broken-template.html'
			Set-Content -Path $broken -Value '<html><body>no markers here</body></html>' -Encoding utf8NoBOM

			{ Get-HtmlReport -AssessmentResults $script:FakeResults -Path $script:WorkPath -TemplatePath $broken } |
				Should -Throw -ExpectedMessage '*markers were not found*'
		}
	}
}
