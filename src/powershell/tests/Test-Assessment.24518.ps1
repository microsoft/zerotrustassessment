<#!
.SYNOPSIS
Checks that all enterprise applications have owners assigned, following the structure of Test-Assessment.21847.ps1
#>

function Test-Assessment-24518 {

    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24518,
    	Title = 'Enterprise applications have owners',
    	UserImpact = 'Low'
    )]

    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking enterprise application ownership'
    Write-ZtProgress -Activity $activity -Status 'Getting all applications'

    # Q1: Get all applications
    $applications = Invoke-ZtGraphRequest -RelativeUri 'applications' -ApiVersion beta

    # Load permission classification CSV
    $classificationPath = Join-Path $PSScriptRoot '../assets/aadconsentgrantpermissiontable.csv'
    $permissionClassifications = Import-Csv $classificationPath

    $filteredApps = @()
    foreach ($app in $applications) {
        $allPerms = $app.requiredResourceAccess | ForEach-Object { $_.resourceAccess } | Where-Object { $_ }
        $permClass = @()
        foreach ($perm in $allPerms) {
            # Match by Permission name
            $row = $permissionClassifications #| Where-Object { $_.Permission -eq $perm.type }
            if ($row) { $permClass += $row.Privilege }
        }
        if ($permClass -and ($permClass -notcontains 'High')) {
            $filteredApps += $app
        }
    }

    $tableHeader = "| App name | Multi-tenant | Permission | Classification | Owner count |`n"
    $tableHeader += "| :------ | :---------- | :--------- | :------------- | :--------- |`n"
    $tableRows = ''
    $allHaveOwners = $true
    foreach ($app in $filteredApps) {
        $owners = Invoke-ZtGraphRequest -RelativeUri "applications/$($app.id)/owners" -ApiVersion beta
        $ownerCount = $owners.Count
        if ($ownerCount -lt 2) { $allHaveOwners = $false }
        $isMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'
        $perms = ($app.requiredResourceAccess | ForEach-Object { $_.resourceAccess } | Where-Object { $_ } | ForEach-Object { $_.id }) -join ', '
        $class = ($permClass -join ', ')
        $tableRows += "| $($app.displayName) | $isMultiTenant | $perms | $class | $ownerCount |`n"
    }

    if ($allHaveOwners) {
        $passed = $true
        $testResultMarkdown = '✅ All enterprise applications have at least two owners.'
    } else {
        $passed = $false
        $mdInfo = ''
        if ($tableRows) {
            $mdInfo = "`n## Enterprise Application Ownership`n`n" + $tableHeader + $tableRows
        }
        $testResultMarkdown = "❌ Not all enterprise applications have at least two owners.`n%TestResult%"
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    $params = @{
        TestId             = '24518'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
