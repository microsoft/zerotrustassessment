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

    # Check if the content starts with ---
    if ($fileContent -match '(?ms)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$') {
        # Return everything after the second ---
        return $Matches[2]
    }

    # If no frontmatter found, return original content
    return $fileContent
}

function Get-ContentFromFrontMatter($fileContent, $key) {
    if ($fileContent -match '^---\s*\n([\s\S]*?)\n---') {
        $frontMatter = $Matches[1]
        if ($frontMatter -match "$($key):\s*(.*)") {
            return $Matches[1].Trim()
        }
    }
    return $null
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

            $docsTitle = Get-ContentFromFrontMatter -fileContent $recommendations[$testId] -key 'title'
            $docsContent = Get-MarkDownContent $recommendations[$testId]

            # Add the docsTitle to the hashtable
            $testMeta[$testId] = @{
                TestId = $testId
                Title = $docsTitle
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

            Set-Content -Path $file.FullName -Value $content
        }
        else {
            Write-Warning "Recommendations not found for $($file.BaseName)"
        }
    }
    else {
        Write-Warning "Test ID not found for $($file.BaseName)"
    }
}

# Save the hashtable to a json file
$testMeta | ConvertTo-Json | Set-Content -Path "$($PSScriptRoot)../../src/powershell/private/tests/TestMeta.json"
