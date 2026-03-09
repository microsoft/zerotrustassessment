<#
.SYNOPSIS
    Exact Data Match is configured for sensitive information detection

.DESCRIPTION
    This test checks if EDM schemas are configured by querying:
    1. All EDM schemas in the organization
    2. Schema details including name, description, version, and dates
    3. Total count of configured schemas

.NOTES
    Test ID: 35034
    Category: Advanced Classification
    Required Module: ExchangeOnlineManagement v3.5.1+
    Required Connection: Connect-IPPSSession
#>

function Test-Assessment-35034 {
    [ZtTest(
        Category = 'Advanced Classification',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Microsoft 365 E3',
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35034,
        Title = 'Exact Data Match is configured for sensitive information detection',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Exact Data Match (EDM) configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying EDM schemas'

    $errorMsg = $null
    $edmSchemas = $null

    # Query: Get all EDM schemas with detailed properties
    try {
        $edmSchemas = Get-DlpEdmSchema -ErrorAction Stop | Select-Object -Property Name, Description, Version, CreatedDate, ModifiedDate
    }
    catch {
        $errorMsg = "Failed to retrieve EDM schemas: $_"
        Write-PSFMessage $errorMsg -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    # Check if query failed
    if ($null -ne $errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine EDM schema configuration due to permissions issues or service connection failure.`n`n%TestResult%"
        $passed = $false
        $customStatus = 'Investigate'
    }
    # Check schema count
    elseif ($null -eq $edmSchemas -or @($edmSchemas).Count -eq 0) {
        $testResultMarkdown = "❌ No EDM schemas are configured; relying solely on built-in SIT patterns for sensitive data detection.`n`n%TestResult%"
        $passed = $false
    }
    else {
        $testResultMarkdown = "✅ Exact Data Match (EDM) schemas are configured, enabling detection of organization-specific sensitive data patterns.`n`n%TestResult%"
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($null -ne $edmSchemas -and @($edmSchemas).Count -gt 0) {
        $formatTemplate = @'

## [{0}]({1})

| Schema name | Description | Version | Created date | Modified date |
| :---------- | :---------- | :------ | :----------- | :------------ |
{2}

'@

        $reportTitle = 'Exact Data Match Schemas'
        $portalLink = 'https://purview.microsoft.com/informationprotection/dataclassification/exactdatamatch'

        $tableRows = ''

        # Build table rows
        foreach ($schema in $edmSchemas) {
            $name = if ($schema.Name) { $schema.Name } else { 'N/A' }
            $description = if ($schema.Description) { $schema.Description } else { 'N/A' }
            $version = if ($schema.Version) { $schema.Version } else { 'N/A' }
            $created = if ($schema.CreatedDate) { $schema.CreatedDate } else { 'N/A' }
            $modified = if ($schema.ModifiedDate) { $schema.ModifiedDate } else { 'N/A' }

            $safeName = Get-SafeMarkdown -Text $name
            $safeDescription = Get-SafeMarkdown -Text $description
            $safeVersion = Get-SafeMarkdown -Text $version
            $safeCreated = Get-SafeMarkdown -Text $created
            $safeModified = Get-SafeMarkdown -Text $modified
            $tableRows += "| $safeName | $safeDescription | $safeVersion | $safeCreated | $safeModified |`n"
        }

        $tableRows += "`n**Summary:**`n"
        $tableRows += "* Total EDM Schemas: $(@($edmSchemas).Count)"

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35034'
        Title  = 'Exact Data Match (EDM) Configurations'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params['CustomStatus'] = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
