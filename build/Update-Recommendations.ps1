#requires -Version 7.4
#requires -Modules Refactor, PSFramework
<#

.SYNOPSIS
    Updates the tests recommendations from the Entra docs

.DESCRIPTION
    Updates the tests recommendations from the Entra docs

	Assume the path to the Entra docs is in a parent directory to this repo with the name 'entra-docs-pr'
	Assume the path to the Intune docs is in a parent directory to this repo with the name 'memdocs-pr'
#>
[CmdletBinding()]
param (
	# Disables importing the ZeroTrustAssessment module
	[switch]
	$NoImport,

	# Check the markdown links after updating to ensure they are valid
	[switch]
	$DisableLinkValidation = $true
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}

if (-not $NoImport) {
	Import-Module "$PSScriptRoot/../src/powershell/ZeroTrustAssessmentV2.psd1" -Force -Global
}
. "$PSScriptRoot/commands/Set-TestMetadata.ps1"


#region Functions
function Get-DocsRecommendations {
	[CmdletBinding()]
	param (
		$recommendationsFolder
	)

	$recommendationsFolder = Resolve-Path $recommendationsFolder
	Write-Host "Reading the recommendations from the $recommendationsFolder"

	# Read all the .md files in the secure-recommendations folder
	$recommendationsFiles = Get-ChildItem -Path $recommendationsFolder -Filter *.md

	Write-Host "Found $($recommendationsFiles.Count) recommendation files."
	# Create a hashtable to store the recommendations
	$recommendations = @{}

	# Loop through each file and extract the recommendations
	foreach ($file in $recommendationsFiles) {

		# Get the file name without the extension
		$id = $file.Name -replace '\.md$'

		$recommendations[$id] = Get-Content -Path $file.FullName -Raw
	}

	return $recommendations
}
function Get-MarkDownContent {
	[CmdletBinding()]
	param (
		$fileContent
	)

	$markdownContent = $fileContent # Default to the original content

	# Check if the content starts with ---
	if ($fileContent -match '(?ms)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$') {
		# Return everything after the second ---
		$markdownContent = $Matches[2]
	}

	# Fix relative links to include the full path
	$markdownContent = $markdownContent.replace('](/', '](https://learn.microsoft.com/')
	$markdownContent = $markdownContent.replace('](../../', '](https://learn.microsoft.com/en-us/entra/')

	$markdownContent = Update-MarkdownLinks -Content $markdownContent

	return $markdownContent
}

function Update-MarkdownLinks {
	[CmdletBinding()]
	param(
		[string]$Content
	)

	# Regular expression to match markdown links starting with https://learn.microsoft.com
	$pattern = '\[(.*?)\]\((https://learn\.microsoft\.com[^\)]+)\)'

	# Replace matching links
	$updatedContent = [regex]::Replace($Content, $pattern, {
			param($match)
			Update-SingleLink -match $match
		})

	return $updatedContent
}

function Update-SingleLink {
	[CmdletBinding()]
	param(
		[System.Text.RegularExpressions.Match]$match
	)

	$linkText = $match.Groups[1].Value
	$url = $match.Groups[2].Value

	# Handle URLs with hash anchors
	$hashIndex = $url.IndexOf('#')
	$hashPart = ""

	if ($hashIndex -ge 0) {
		# Extract the hash part
		$hashPart = $url.Substring($hashIndex)
		# Remove the hash part from the URL for processing
		$url = $url.Substring(0, $hashIndex)
	}

	# Check if URL already has parameters
	if ($url -match "\?") {
		$appendChar = "&"
	}
	else {
		$appendChar = "?"
	}

	# Remove tracking parameter if it already exists (to avoid duplication)
	$url = $url -replace "\??wt\.mc_id=zerotrustrecommendations_automation_content_cnl_csasci", ""

	# markdown extensions to remove
	$mdExtensions = @('.md', '.yml')

	# Remove any markdown extensions from the URL
	foreach ($ext in $mdExtensions) {
		if ($url.EndsWith($ext)) {
			$url = $url.Substring(0, $url.Length - $ext.Length)
		}
	}

	# Create the new link with tracking parameter and add back the hash part if it existed
	return "[$linkText]($url$($appendChar)wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci$hashPart)"
}

function Test-FolderMarkdownLinks {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]$FolderPath,
		[int]$TimeoutSeconds = 30,
		[switch]$IncludeRelativeLinks
	)

	# Function to test a single URL
	function Test-Url {
		[CmdletBinding()]
		param (
			[string]$Url,
			[int]$Timeout
		)

		try {
			$request = [System.Net.WebRequest]::Create($Url)
			$request.Method = "HEAD"
			$request.Timeout = $Timeout * 1000
			$request.AllowAutoRedirect = $true

			try {
				$response = $request.GetResponse()
				$status = [int]$response.StatusCode
				$response.Close()
				return @{
					IsValid    = $true
					StatusCode = $status
					Error      = $null
				}
			}
			catch [System.Net.WebException] {
				$status = [int]$_.Exception.Response.StatusCode
				return @{
					IsValid    = $false
					StatusCode = $status
					Error      = $_.Exception.Message
				}
			}
		}
		catch {
			return @{
				IsValid    = $false
				StatusCode = 0
				Error      = $_.Exception.Message
			}
		}
	}

	# Function to print a separator line
	function Write-Separator {
		[CmdletBinding()]
		param ()
		Write-Host ("-" * 80)
	}

	# Check if folder exists
	if (-not (Test-Path $FolderPath)) {
		throw "Folder not found: $FolderPath"
	}

	$fileStats = @{
		TotalFiles      = 0
		FilesWithErrors = 0
		TotalLinks      = 0
		InvalidLinks    = 0
	}
	$colorMap = @{
		$true  = "Green"
		$false = "Red"
	}

	# Get all markdown files recursively
	$mdFiles = Get-ChildItem -Path $FolderPath -Filter "*.md" -Recurse

	$fileStats.TotalFiles = $mdFiles.Count
	Write-Host "Found $($mdFiles.Count) markdown files to process..."
	Write-Separator

	foreach ($file in $mdFiles) {
		$content = Get-Content -Path $file.FullName -Raw

		# Add null check before attempting regex match
		if ($null -eq $content) {
			Write-Warning "File content is null for $($file.FullName)"
			continue
		}

		# Regular expression to match markdown links
		$pattern = '\[([^\]]*)\]\(([^\)]+)\)'
		$markdownLinks = [regex]::Matches($content, $pattern)
		$hasInvalidLinks = $false
		$fileLinksCount = 0
		$fileInvalidCount = 0

		if ($markdownLinks.Count -gt 0) {
			Write-Host "Processing: $($file.Name)" -ForegroundColor Cyan

			foreach ($link in $markdownLinks) {
				$linkText = $link.Groups[1].Value
				$url = $link.Groups[2].Value.Trim()

				# Skip anchor links
				if ($url.StartsWith("#")) {
					continue
				}

				# Skip relative links unless specifically included
				if (-not $url.StartsWith("http") -and -not $IncludeRelativeLinks) {
					continue
				}

				$fileLinksCount++
				$fileStats.TotalLinks++

				$result = Test-Url -Url $url -Timeout $TimeoutSeconds

				if (-not $result.IsValid) {
					$hasInvalidLinks = $true
					$fileInvalidCount++
					$fileStats.InvalidLinks++

					# Calculate line number
					$lineNumber = ($content.Substring(0, $link.Index).Split("`n")).Count

					Write-Host "  Line $lineNumber - INVALID LINK" -ForegroundColor Red
					Write-Host "    Text: $linkText"
					Write-Host "    URL:  $url"
					Write-Host "    Error: $($result.Error) (Status: $($result.StatusCode))"
				}
			}

			if ($fileLinksCount -gt 0) {
				Write-Host "  Links checked: $fileLinksCount, Invalid: $fileInvalidCount" -ForegroundColor $colorMap[($fileInvalidCount -lt 1)]
				Write-Separator
			}
		}

		if ($hasInvalidLinks) {
			$fileStats.FilesWithErrors++
		}
	}

	# Print final summary
	Write-Host "`nVALIDATION SUMMARY" -ForegroundColor Cyan
	Write-Separator
	Write-Host "Total Files Processed: $($fileStats.TotalFiles)"
	Write-Host "Files With Invalid Links: $($fileStats.FilesWithErrors)" -ForegroundColor $colorMap[($fileStats.FilesWithErrors -lt 1)]
	Write-Host "Total Links Checked: $($fileStats.TotalLinks)"
	Write-Host "Invalid Links Found: $($fileStats.InvalidLinks)" -ForegroundColor $colorMap[($fileStats.InvalidLinks -lt 1)]
	Write-Separator
}

function Get-FrontMatterList {
	[CmdletBinding()]
	param (
		$content
	)
	$results = @{}
	if ($content -match '^---\s*\n([\s\S]*?)\n---') {
		$frontMatter = $Matches[1]
		# Split the front matter into lines
		$lines = $frontMatter -split '\r?\n'
		foreach ($line in $lines) {
			if ($line -match '^(.*?)\s*:\s*(.*)$') {
				$key = $Matches[1].Trim()
				$value = $Matches[2].Trim()
				$results[$key] = $value
			}
		}
	}
	return $results
}

function Remove-TrailingEmptyLines {
	[CmdletBinding()]
	param (
		[string]$Content
	)

	# Split content into lines, remove trailing empty lines, then join back
	$lines = $Content -split '\r?\n'
	for ($i = $lines.Length - 1; $i -ge 0; $i--) {
		if ([string]::IsNullOrWhiteSpace($lines[$i])) {
			$lines = $lines[0..($i - 1)]
		}
		else {
			break
		}
	}

	return ($lines -join "`n") + "`n"
}
#endregion Functions

$entraDocsFolder = Join-Path -Path "$($PSScriptRoot)/../../entra-docs-pr" -ChildPath 'docs/includes/secure-recommendations'
$intuneDocsFolder = Join-Path -Path "$($PSScriptRoot)/../../memdocs-pr" -ChildPath 'intune/intune-service/protect/includes/secure-recommendations'

$entraRecommendations = Get-DocsRecommendations -recommendationsFolder $entraDocsFolder
$intuneRecommendations = Get-DocsRecommendations -recommendationsFolder $intuneDocsFolder

$recommendations = $entraRecommendations + $intuneRecommendations

# Update the recommendations in the tests
$testFiles = Get-ChildItem -Path "$($PSScriptRoot)/../src/powershell/tests" -Filter *.md
# Read the existing test metadata and merge with the new recommendations

foreach ($file in $testFiles) {
	# Split the name with . and get the second part
	$testId = $file.BaseName.Split('.')[1]
	$testId

	if (-not $testId) {
		Write-Warning "Test ID not found for $($file.BaseName)"
		continue
	}

	if (-not $recommendations.ContainsKey($testId)) {
		Write-Warning "Recommendations not found for $($file.BaseName)"
		continue
	}

	# Create a hashtable to store the testid and docsTitle
	Write-Host "Checking $($file.BaseName)"

	$content = Get-Content -Path $file.FullName -Raw

	$docRawContent = $recommendations[$testId] # Includes front matter and markdown content
	$frontMatter = Get-FrontMatterList -content $docRawContent
	$docsTitle = $frontMatter['title']

	$docsContent = Get-MarkDownContent $docRawContent

	#region Update MetaData for Test
	$testData = Get-ZtTest -Tests $testId
	if (-not $testData) {
		Write-Warning "The Test $testId could not be found! Make sure the code implementation exists and is correct. Also make sure the ZeroTrustAssessment module has been reimported since adding it."
	}
	else {
		$update = @{
			Test = $testId
		}
		if ($testData.TestId -ne $testId) {
			$update.TestId = $testId
		}
		if ($testData.Title -ne $docsTitle) {
			$update.Title = $docsTitle
		}
		if ($testData.Category -ne $frontMatter['# category']) {
			$update.Category = $frontMatter['# category']
		}
		if ($testData.ImplementationCost -ne $frontMatter['# implementationcost']) {
			$update.ImplementationCost = $frontMatter['# implementationcost']
		}
		if ($testData.RiskLevel -ne $frontMatter['# risklevel']) {
			$update.RiskLevel = $frontMatter['# risklevel']
		}
		if ($testData.UserImpact -ne $frontMatter['# userimpact']) {
			$update.UserImpact = $frontMatter['# userimpact']
		}
		if ($testData.SfiPillar -ne $frontMatter['# sfipillar']) {
			$update.SfiPillar = $frontMatter['# sfipillar']
		}
		#$frontMatter['# pillar'] #Code to identity for now until we get the front-matter in
		if (-not $testData.Pillar) {
			$update.Pillar = 'Identity'
		}
		elseif ($testData.Pillar -ne 'Identity') {
			Write-Verbose "[$testId] Pillar Update notice: Current Pillar set to '$($testData.Pillar)'. NOT reverting to 'Identity' for now, pending code update."
		}
		if ($update.Count -gt 1) {
			try {
				Write-Verbose "[$testId] Updating metadata: $($update.Keys.Where{$_ -ne 'Test'} -join ',')"
				Set-TestMetadata @update -ErrorAction Stop
			}
			catch {
				Write-Warning "[$testId] Failed to update metadata: $_"
			}
		}
	}
	#endregion Update MetaData for Test

	Write-Host "$testId Title: $docsTitle"
	# Find everything before <!--- Results ---> and replace it with the recommendations from the docs
	$seperator = $content.IndexOf('<!--- Results --->')
	$prevContent = $content.Substring(0, $seperator)
	if ($seperator -gt 0) {
		if ($docsContent -eq $prevContent) {
			Write-Host " → No change."
			continue
		}
		else {
			$content = $docsContent + $content.Substring($seperator)
		}
	}
	else {
		$content = $docsContent
	}

	# Split the content into lines, start from the last line and remove

	$cleanContent = Remove-TrailingEmptyLines -Content $content

	Set-Content -Path $file.FullName -Value $cleanContent
}

if ($CheckLinks) {
	Write-Host "`nChecking markdown links in test files..."
	Test-FolderMarkdownLinks -FolderPath "$($PSScriptRoot)../../src/powershell/tests" -IncludeRelativeLinks
}
