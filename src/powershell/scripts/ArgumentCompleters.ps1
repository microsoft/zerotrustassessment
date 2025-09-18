<#
.SYNOPSIS
    Provides intelligent tab completion for Zero Trust Assessment test IDs and names.

.DESCRIPTION
    This script implements sophisticated argument completion for the -Tests parameter of
    Invoke-ZtAssessment and Invoke-ZeroTrustAssessment cmdlets. It enables users to search
    and select tests using partial test IDs, test titles, categories, or common abbreviations.

    Key Features:
    - Fast tab completion with caching for improved performance
    - Smart search with synonym support (e.g., 'mfa' finds multifactor authentication tests)
    - Multi-word search capability
    - Support for comma-separated test lists
    - Tooltip display with test details
    - Intelligent sorting (exact matches first, then relevance-based)

.EXAMPLE
    Basic test ID completion:
    Invoke-ZtAssessment -Tests 217<TAB>

    Completes to specific test ID starting with 217 (e.g., 21773, 21793)

.EXAMPLE
    Partial test ID with multiple matches:
    Invoke-ZtAssessment -Tests 21<CTRL+SPACE>

    Shows all test IDs starting with 21 (e.g., 210, 211, 212, etc.)

.EXAMPLE
    Search by test title keywords:
    Invoke-ZtAssessment -Tests mfa<TAB>

    Shows all multifactor authentication related tests

.EXAMPLE
    Multi-word search:
    Invoke-ZtAssessment -Tests "mfa high"<TAB>

    Shows tests with both "mfa" and "high" in title/risk level

.EXAMPLE
    Synonym support:
    Invoke-ZtAssessment -Tests ca<TAB>

.NOTES
    File: ArgumentCompleters.ps1
    Author: Zero Trust Assessment Team
    Purpose: Provides tab completion for test selection in PowerShell cmdlets

    Supported Synonyms:
    - 'mfa', '2fa' → multifactor authentication, multi-factor authentication
    - 'ca' → conditional access
    - 'pim' → privileged identity management
    - 'sspr' → self service password reset
    - 'ad', 'aad' → active directory, azure active directory, entra

    Performance Notes:
    - Optimized search algorithms for fast completion even with large test sets

    This file is automatically loaded when the ZeroTrustAssessmentV2 module is imported.
    The completion functionality is registered for both Invoke-ZtAssessment and
    Invoke-ZeroTrustAssessment cmdlets.
#>

# Zero Trust Assessment Argument Completers

# Helper function to paginate completion results
function Get-PaginatedCompletions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$CompletionResults,

        [int]$PageSize = 10
    )

    if ($CompletionResults.Count -le $PageSize) {
        return $CompletionResults
    }

    # Take first page
    $pagedResults = $CompletionResults | Select-Object -First $PageSize

    # Add pagination indicator
    $remainingCount = $CompletionResults.Count - $PageSize
    $paginationText = "... and $remainingCount more tests (use search to narrow results)"
    $paginationItem = [System.Management.Automation.CompletionResult]::new(
        '...',
        $paginationText,
        'Text',
        "Total: $($CompletionResults.Count) tests available. Use search terms like 'mfa', 'high', 'access', etc. to filter results."
    )

    return $pagedResults + $paginationItem
}

# Synonym mapping for common abbreviations
$script:Synonyms = @{
    'mfa' = @('multifactor', 'multi-factor', 'authentication')
    '2fa' = @('two factor', 'multifactor', 'authentication')
    'ca' = @('conditional access')
    'pim' = @('privileged identity')
    'sspr' = @('self service password')
    'ad' = @('active directory', 'entra')
    'aad' = @('azure active directory', 'entra')
}

function Get-ZtTestCompletion {
    [CmdletBinding()]
    param([string]$WordToComplete)

    try {
        # Generate completions with simplified matching logic
        $completions = foreach ($test in Get-ZtTest) {
            if ([string]::IsNullOrWhiteSpace($test.TestId) -or [string]::IsNullOrWhiteSpace($test.Title)) { continue }

            # Build search fields more robustly - always include Title, add others if they exist
            $searchFields = @($test.Title)
            if ($test.Category) { $searchFields += $test.Category }
            if ($test.RiskLevel) { $searchFields += $test.RiskLevel }

            $isMatch = $false
            $priority = 4

            # Empty search matches all
            if ([string]::IsNullOrWhiteSpace($WordToComplete)) {
                $isMatch = $true
                $priority = 1
            }
            # Exact TestId match
            elseif ("$($test.TestId)".StartsWith($WordToComplete, [StringComparison]::OrdinalIgnoreCase)) {
                $isMatch = $true
                $priority = 1
            }
            else {
                # Search in fields with synonym support
                $searchWords = $WordToComplete.Split(' ', [StringSplitOptions]::RemoveEmptyEntries)

                if ($searchWords.Count -gt 1) {
                    # Multi-word: ALL words must be found across ANY fields (more intuitive)
                    $allWordsFound = $true
                    foreach ($word in $searchWords) {
                        $wordFound = $false

                        # Check if this word exists in any field
                        foreach ($field in $searchFields) {
                            if ($field.Contains($word, [StringComparison]::OrdinalIgnoreCase)) {
                                $wordFound = $true
                                break
                            }
                        }

                        # Check synonyms if direct match fails
                        if (-not $wordFound -and $script:Synonyms.ContainsKey($word.ToLower())) {
                            foreach ($synonym in $script:Synonyms[$word.ToLower()]) {
                                foreach ($field in $searchFields) {
                                    if ($field.Contains($synonym, [StringComparison]::OrdinalIgnoreCase)) {
                                        $wordFound = $true
                                        break
                                    }
                                }
                                if ($wordFound) { break }
                            }
                        }

                        if (-not $wordFound) {
                            $allWordsFound = $false
                            break
                        }
                    }

                    if ($allWordsFound) {
                        $isMatch = $true
                        $priority = 3
                    }
                }
				else {
                    # Single word: check all fields
                    $searchWord = $searchWords[0]
                    foreach ($field in $searchFields) {
                        if ($field.Contains($searchWord, [StringComparison]::OrdinalIgnoreCase)) {
                            $isMatch = $true
                            $priority = if ($test.Title.StartsWith($searchWord, [StringComparison]::OrdinalIgnoreCase)) { 2 } else { 3 }
                            break
                        }
                    }

                    # Check synonyms if no direct match
                    if (-not $isMatch -and $script:Synonyms.ContainsKey($searchWord.ToLower())) {
                        foreach ($synonym in $script:Synonyms[$searchWord.ToLower()]) {
                            foreach ($field in $searchFields) {
                                if ($field.Contains($synonym, [StringComparison]::OrdinalIgnoreCase)) {
                                    $isMatch = $true
                                    $priority = 3
                                    break
                                }
                            }
                            if ($isMatch) { break }
                        }
                    }
                }
            }

            if ($isMatch) {
                # Create tooltip and display text
                $tooltipParts = @($test.Title)
                if ($test.Category) { $tooltipParts += "Category: $($test.Category)" }
                if ($test.RiskLevel) { $tooltipParts += "Risk Level: $($test.RiskLevel)" }

                $listItemText = "$($test.TestId) - $($test.Title)"
                if ($test.Category) { $listItemText += " [$($test.Category)]" }

                [PSCustomObject]@{
                    CompletionResult = [System.Management.Automation.CompletionResult]::new(
                        $test.TestId,
                        $listItemText,
                        'ParameterValue',
                        ($tooltipParts -join "`n")
                    )
                    Priority = $priority
                    NumericId = if ([int]::TryParse($test.TestId, [ref]$null)) { [int]$test.TestId } else { [int]::MaxValue }
                }
            }
        }

        # Sort results
        $sortedResults = $completions | Sort-Object Priority, NumericId | ForEach-Object CompletionResult

        # Apply pagination if we have more than 10 results
        return Get-PaginatedCompletions -CompletionResults $sortedResults
    }
    catch {
        Write-Debug "Error in Get-ZtTestCompletion: $($_.Exception.Message)"
        return @()
    }
}

# Main argument completer script block
$ztTestsCompleterScript = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # Handle comma-separated values and remove quotes
    $searchTerm = if ($wordToComplete.Contains(',')) {
        ($wordToComplete -split ',')[-1].Trim()
    } else { $wordToComplete }

    $searchTerm = $searchTerm.Trim('"', "'")

    # For Ctrl+Space scenarios, ensure we handle null/empty properly
    if ([string]::IsNullOrEmpty($searchTerm)) {
        $searchTerm = ""
    }

    return Get-ZtTestCompletion -WordToComplete $searchTerm
}

# Register argument completer for both--the cmdlet and its alias
$commandNames = @(
	'Get-ZtTest'
    'Invoke-ZtAssessment',
    'Invoke-ZeroTrustAssessment'
)

$commandNames | ForEach-Object {
    Register-ArgumentCompleter -CommandName $_ -ParameterName 'Tests' -ScriptBlock $ztTestsCompleterScript
}
