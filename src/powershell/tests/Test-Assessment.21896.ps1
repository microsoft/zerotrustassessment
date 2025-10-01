<#
    .SYNOPSIS
    Checks Service principals have certificates or credentials associated with them

#>

function Test-Assessment-21896 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce', 'External'),
        TestId = 21896,
        Title = 'Service principals don''t have certificates or credentials associated with them',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Service principals have certificates or credentials associated with them'
    Write-ZtProgress -Activity $activity -Status 'Getting Service Principals'

    # Start test as passed
    $passed = $true

    # Q2: Get service principals with any credentials using single SQL query
    $sqlPassCreds = @"
    SELECT distinct ON (id)
        id,
        appId,
        displayName,
        appOwnerOrganizationId,
        try_cast(unnest(passwordCredentials).endDateTime as date) as keyEndDateTime
    FROM ServicePrincipal
    WHERE passwordCredentials != '[]' and appOwnerOrganizationId != 'f8cdef31-a31e-4b4a-93e4-5f571e91255a'
    ORDER BY displayName, keyEndDateTime DESC
"@

    # SQL query to find service principals with key credentials
    $sqlKeyCreds = @"
    SELECT distinct ON (id)
        id,
        appId,
        displayName,
        appOwnerOrganizationId,
        try_cast(unnest(keyCredentials).endDateTime as date) as keyEndDateTime
    FROM ServicePrincipal
    WHERE keyCredentials != '[]' and appOwnerOrganizationId != 'f8cdef31-a31e-4b4a-93e4-5f571e91255a'
    ORDER BY displayName, keyEndDateTime DESC
"@

    $resultsPassCreds = Invoke-DatabaseQuery -Database $Database -Sql $sqlPassCreds
    $resultsKeyCreds = Invoke-DatabaseQuery -Database $Database -Sql $sqlKeyCreds

    if ($resultsPassCreds.Count -eq 0 -and $resultsKeyCreds.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = "Service principals don't have credentials associated with them."
    }
    else {
        $passed = $false
        $testResultMarkdown = "Found Service Principals with credentials configured in the tenant, which represents a security risk.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Service Principals with credentials configured in the tenant"
    $tableRows = ""

    if ($resultsPassCreds.Count -gt 0 -or $resultsKeyCreds.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Service Principal Name | Credentials Type | Credentials Expiration Date | Expiry Status |
| :--------------------- | :--------------- | :-------------------------- | :------------ |
{1}

'@

        foreach ($sp in $resultsPassCreds) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}' -f $sp.id, $sp.appId
            $expiryDate = $sp.keyEndDateTime.ToDateTime([TimeOnly]::MinValue)
            $expiryStatus = if ( (Get-Date) -gt $expiryDate) {
                '❗ Expired'
            }
            else {
                '✅ Current'
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($sp.displayName))]($portalLink) | Password Credentials | $(Get-FormattedDate($sp.keyEndDateTime)) | $expiryStatus |`n
"@
        }

        foreach ($sp in $resultsKeyCreds) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}' -f $sp.id, $sp.appId
            $expiryDate = $sp.keyEndDateTime.ToDateTime([TimeOnly]::MinValue)
            $expiryStatus = if ( (Get-Date) -gt $expiryDate) {
                '❗ Expired'
            }
            else {
                '✅ Current'
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($sp.displayName))]($portalLink) | Key Credentials | $(Get-FormattedDate($sp.keyEndDateTime)) | $expiryStatus |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21896'
        Title              = "Service principals don't have certificates or credentials associated with them"
        UserImpact         = 'Low'
        Risk               = 'Medium'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    if (!$passed) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
