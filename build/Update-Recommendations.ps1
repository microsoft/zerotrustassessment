<#

.SYNOPSIS
    Updates the tests recommendations from the Entra docs
#>

# Assume the path to the Entra docs is in a parent directory to this repo with the name 'entra-docs-pr'

function Get-DocsRecommendations($entraDocsFolder) {
    $recommendationsFolder = Join-Path -Path $entraDocsFolder -ChildPath 'docs/includes/secure-recommendations'

    Write-Host "Reading the recommendations from the Entra docs at $recommendationsFolder"

    # Read all the .md files in the secure-recommendations folder
    $recommendationsFiles = Get-ChildItem -Path $recommendationsFolder -Filter *.md

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
function Get-MarkDownContent($fileContent) {

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
    } else {
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
    param (
        [Parameter(Mandatory=$true)]
        [string]$FolderPath,
        [int]$TimeoutSeconds = 30,
        [switch]$IncludeRelativeLinks
    )

    # Function to test a single URL
    function Test-Url {
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
                    IsValid = $true
                    StatusCode = $status
                    Error = $null
                }
            }
            catch [System.Net.WebException] {
                $status = [int]$_.Exception.Response.StatusCode
                return @{
                    IsValid = $false
                    StatusCode = $status
                    Error = $_.Exception.Message
                }
            }
        }
        catch {
            return @{
                IsValid = $false
                StatusCode = 0
                Error = $_.Exception.Message
            }
        }
    }

    # Function to print a separator line
    function Write-Separator {
        Write-Host ("-" * 80)
    }

    # Check if folder exists
    if (-not (Test-Path $FolderPath)) {
        throw "Folder not found: $FolderPath"
    }

    $fileStats = @{
        TotalFiles = 0
        FilesWithErrors = 0
        TotalLinks = 0
        InvalidLinks = 0
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
                Write-Host "  Links checked: $fileLinksCount, Invalid: $fileInvalidCount" -ForegroundColor $(if ($fileInvalidCount -gt 0) { "Red" } else { "Green" })
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
    Write-Host "Files With Invalid Links: $($fileStats.FilesWithErrors)" -ForegroundColor $(if ($fileStats.FilesWithErrors -gt 0) { "Red" } else { "Green" })
    Write-Host "Total Links Checked: $($fileStats.TotalLinks)"
    Write-Host "Invalid Links Found: $($fileStats.InvalidLinks)" -ForegroundColor $(if ($fileStats.InvalidLinks -gt 0) { "Red" } else { "Green" })
    Write-Separator
}

function Get-FrontMatterList($content) {
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

$entraDocsFolder = "$($PSScriptRoot)../../../entra-docs-pr"

$recommendations = Get-DocsRecommendations -entraDocsFolder $entraDocsFolder

# Update the recommendations in the tests
$testFiles = Get-ChildItem -Path "$($PSScriptRoot)../../src/powershell/private/tests" -Filter *.md
$testMeta = @{} # We will store the TestId and Title so it can be used to display the test results

foreach ($file in $testFiles) {
    # Split the name with . and get the second part
    $testId = $file.BaseName.Split('.')[1]
    $testId

    # Create a hashtable to store the testid and docsTitle
    if ($testId) {
        if ($recommendations.ContainsKey($testId)) {
            Write-Host "Checking $($file.BaseName)"

            $content = Get-Content -Path $file.FullName -Raw

            $docRawContent = $recommendations[$testId] # Includes front matter and markdown content
            $frontMatter = Get-FrontMatterList -content $docRawContent
            $docsTitle = $frontMatter['title']

            $docsContent = Get-MarkDownContent $docRawContent

            # Add the docsTitle to the hashtable with sorted attributes
            $testMeta[$testId] = [ordered]@{
                TestId = $testId
                Title = $docsTitle
                Category = $frontMatter['# category']
                ImplementationCost = $frontMatter['# implementationcost']
                RiskLevel = $frontMatter['# risklevel']
                UserImpact = $frontMatter['# userimpact']
            }

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
        else {
            Write-Warning "Recommendations not found for $($file.BaseName)"
        }
    }
    else {
        Write-Warning "Test ID not found for $($file.BaseName)"
    }
}


# Sort the hashtable by TestId and convert to ordered dictionary
$sortedTestMeta = [ordered]@{}
$testMeta.Keys | Sort-Object | ForEach-Object {
    $sortedTestMeta[$_] = $testMeta[$_]
}

# Save the sorted hashtable to a json file
$sortedTestMeta | ConvertTo-Json | Set-Content -Path "$($PSScriptRoot)../../src/powershell/private/tests/TestMeta.json"

Test-FolderMarkdownLinks -FolderPath "$($PSScriptRoot)../../src/powershell/private/tests" -IncludeRelativeLinks
