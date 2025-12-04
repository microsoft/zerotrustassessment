[CmdletBinding()]
param (
	[bool]
	$TestGeneral = $true,

	[bool]
	$TestFunctions = $true,

	[bool]
	$TestAssessments = $true,

	[ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
	[Alias('Show')]
	$Output = "None",

	[string]
	$Include = "*",

	[string]
	$Exclude = "",

	[string]
	$ModuleName = 'ZeroTrustAssessment',

	[switch]
	$NoImport
)

Write-Host "Starting Tests"

$global:__testData = @{
	TestRoot = $PSScriptRoot
	ModuleName = $ModuleName
	ModuleRoot = (Get-Item -Path "$PSScriptRoot\..\src\powershell").FullName
	Tests = @{ }
}

Write-Host "Importing Tools"
foreach ($file in Get-ChildItem -Path "$PSScriptRoot\tools" -Recurse -Filter *.ps1) {
	. $file.FullName
}

$global:__pester_data = @{ }

if (-not $NoImport) {
	Write-Host "Importing Module"

	Remove-Module $ModuleName -ErrorAction Ignore
	Import-Module "$($global:__testData.ModuleRoot)\$ModuleName.psd1" -Global
	Import-Module "$($global:__testData.ModuleRoot)\$ModuleName.psm1" -Force -Global # This allows testing internal commands

	# Need to import explicitly so we can use the configuration class
	Import-Module Pester -Global 3>$null
}

Write-Host  "Creating test result folder"
$null = New-Item -Path $PSScriptRoot -Name TestResults -ItemType Directory -Force

$totalFailed = 0
$totalRun = 0

$testresults = @()
$config = [PesterConfiguration]::Default
$config.TestResult.Enabled = $true

#region Run General Tests
if ($TestGeneral)
{
	Write-Host  "Modules imported, proceeding with general tests"
	foreach ($file in (Get-ChildItem "$PSScriptRoot\general" | Where-Object Name -like "*.Tests.ps1"))
	{
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }

		Write-Host  "  Executing $($file.Name)"
		$config.TestResult.OutputPath = Join-Path "$PSScriptRoot\TestResults" "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
    	$results = Invoke-Pester -Configuration $config
		foreach ($result in $results)
		{
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block    = $_.Block
					Name	 = "It $($_.Name)"
					Result   = $_.Result
					Message  = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Run General Tests

$global:__pester_data.ScriptAnalyzer | Out-Host

#region Test Commands
if ($TestFunctions)
{
	Write-Host "Proceeding with individual tests"
	foreach ($file in (Get-ChildItem "$PSScriptRoot\commands" -Recurse -File | Where-Object Name -like "*Tests.ps1"))
	{
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }

		Write-Host "  Executing $($file.Name)"
		$config.TestResult.OutputPath = Join-Path "$PSScriptRoot\TestResults" "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
    	$results = Invoke-Pester -Configuration $config
		foreach ($result in $results)
		{
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block    = $_.Block
					Name	 = "It $($_.Name)"
					Result   = $_.Result
					Message  = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Test Commands

#region Test Assessments
if ($TestAssessments)
{
	Write-Host "Proceeding with assessment tests"
	foreach ($file in (Get-ChildItem "$PSScriptRoot\test-assessments" -Recurse -File | Where-Object Name -like "*Tests.ps1"))
	{
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }

		Write-Host "  Executing $($file.Name)"
		$config.TestResult.OutputPath = Join-Path "$PSScriptRoot\TestResults" "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
    	$results = Invoke-Pester -Configuration $config
		foreach ($result in $results)
		{
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -ne 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block    = $_.Block
					Name	 = "It $($_.Name)"
					Result   = $_.Result
					Message  = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Test Assessments

$testresults | Sort-Object Block, Name, Result, Message | Format-List

$nonCriticalFails = $testresults | Where-Object {
	$_.Block -match 'All Tests should be properly configured' -and
	$_.Name -match 'It should have an? \S+ defined for'
}

$absoluteFailed = $totalFailed - @($nonCriticalFails).Count

if ($totalFailed -eq 0) { Write-Host  "All $totalRun tests executed without a single failure!" }
else {
	Write-Host "$totalFailed tests out of $totalRun tests failed, $absoluteFailed of them critical"
}

if ($absoluteFailed -gt 0)
{
	throw "$totalFailed / $totalRun tests failed, $absoluteFailed of them critical!"
}
