<#
.SYNOPSIS

#>

function Test-Assessment-21865 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Trusted network locations are configured to increase quality of risk detections"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query all named locations
    $allNamedLocations = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/namedLocations' -ApiVersion 'v1.0'

    # Check if at least one named location is configured as trusted
    if ($allNamedLocations | Where-Object { $_.isTrusted -eq $true }) {
        $passed = $true
        $testResultMarkdown = "✅ **Pass**: Trusted named locations are configured in Microsoft Entra ID to support location-based security controls.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ **Fail**: No trusted named locations configured, reducing location intelligence for risk detection and Conditional Access policies."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "All named locations"
    $totalNamedLocations = $allNamedLocations | Measure-Object | Select-Object -ExpandProperty Count
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations/menuId//fromNav/'
    $tableRows = ""


    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @'

## {0}

{1} [named locations]({2}) found.

| Name | Location type | Trusted | Creation date | Modified date |
| :--- | :------------ | :------ | :------------ | :------------ |
{3}

'@

        foreach ($namedLocation in $allNamedLocations) {

            $name = $namedLocation.displayName
            $locationType = switch ($namedLocation) {
                { $_.'@odata.type' -eq '#microsoft.graph.ipNamedLocation' } { 'IP-based' }
                { $_.'@odata.type' -eq '#microsoft.graph.countryNamedLocation' } { 'Country-based' }
                default { 'Unknown' }
            }
            $trusted = if ($namedLocation.isTrusted) { 'Yes' } else { 'No' }
            $createdDateTime = Get-FormattedDate -DateString $namedLocation.createdDateTime
            $modifiedDateTime = Get-FormattedDate -DateString $namedLocation.modifiedDateTime

            $tableRows += @"
| $name | $locationType | $trusted | $createdDateTime | $ModifiedDateTime |`n
"@
        }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $totalNamedLocations, $portalLink, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21865'
        Title              = 'Trusted network locations are configured to increase quality of risk detections'
        UserImpact         = 'Low'
        Risk               = 'Medium'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
