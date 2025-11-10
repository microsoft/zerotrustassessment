# Generates test scaffold based on the csv export from ADO (note: remove the spaces from the headers)
# Run this command after changing into the scaffold directory.

function Get-DefaultLevel
{
	[CmdletBinding()]
	param (
		$value
	)
    # if empty return Low
    if ([string]::IsNullOrEmpty($value)) {
        return "Low"
    }
    return $value
}

# Import the CSV file
$csv = Import-Csv -Path "$PSScriptRoot\ado-tests.csv"

# go through each row in the CSV file, check if the test exists in the ./src/private/tests directory ending with the same .id.ps1 format
# if it does not exist, create the file with the test scaffold
$createdTests = foreach ($row in $csv) {
    $testId = $row.ID
    $testTitle = $row.Title
    Write-Host "Processing test $testId - $testTitle"

    #$tags = $row.Categories
    $risk = Get-DefaultLevel $row.RiskLevel
    $userImpact = Get-DefaultLevel $row.UserImpact
    $implementationCost = Get-DefaultLevel $row.ImplementationCost

    # use wildcard for the Test-name prefix
    # Check if file name ends with .$testId.ps1 and if it does not exist, create the file
    $testFile = "../../src/powershell/tests/*.$testId.ps1"

    if (-not (Test-Path $testFile)) {
        Write-Host "Creating test file $testFile"

        $testContent = Get-Content -Path "$PSScriptRoot\Test-Template.ps1"
        $testContent = $testContent -replace "%testid%", $testId
        $testContent = $testContent -replace "%testTitle%", $testTitle
        $testContent = $testContent -replace "%risk%", $risk
        $testContent = $testContent -replace "%userImpact%", $userImpact
        $testContent = $testContent -replace "%implementationCost%", $implementationCost
        $testContent = $testContent -replace "%category%", $row.Categories

        $fileName = "Test-Assessment.$testId"
        $testPsFile = "../../src/powershell/tests/$fileName.ps1"
        $testContent | Set-Content -Path $testPsFile

        $markdownFile = "../../src/powershell/tests/$fileName.md"
        $markdownContent = Get-Content -Path "$PSScriptRoot\Test-Template.md"
        $markdownContent | Set-Content -Path $markdownFile

		"Test-Assessment-$testId"
    }
}


Write-Host "Add tests to Invoke-ZtTests"
# Write each item to a new line in the console
$createdTests | ForEach-Object { Write-Host $_ }
