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
        $content = Get-Content -Path $file.FullName -Raw

        # Get the file name without the extension
        $id = $file.Name -replace '\.md$'

        $recommendations[$id] = Get-MarkDownContent $content
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

$entraDocsFolder = "$($PSScriptRoot)../../../entra-docs-pr"

$recommendations = Get-DocsRecommendations -entraDocsFolder $entraDocsFolder

# Update the recommendations in the tests
$testFiles = Get-ChildItem -Path "$($PSScriptRoot)../../src/powershell/private/tests" -Filter *.md

foreach ($file in $testFiles) {


    # Split the name with . and get the second part
    $testId = $file.BaseName.Split('.')[1]
    $testId

    if ($testId) {
        if ($recommendations.ContainsKey($testId)) {
            Write-Host "Updating $($file.BaseName)"

            $content = Get-Content -Path $file.FullName -Raw

            # Find everything before <!--- Results ---> and replace it with the recommendations from the docs
            $seperator = $content.IndexOf('<!--- Results --->')

            if($seperator -gt 0) {
                $content = $recommendations[$testId] + $content.Substring($seperator)
            }
            else {
                $content = $recommendations[$testId]
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
