<#!
.SYNOPSIS
Checks that all enterprise applications have owners assigned and lists permission names with classifications.
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
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking enterprise application ownership'
    Write-ZtProgress -Activity $activity -Status 'Getting applications with insufficient owners'

    # Get applications from database that:
    # 1. Have requiredResourceAccess (permissions)
    # 2. Have fewer than 2 owners
    $sqlApp = @"
SELECT
    id,
    displayName,
    signInAudience,
    requiredResourceAccess,
    owners
FROM Application
WHERE requiredResourceAccess IS NOT NULL
    AND requiredResourceAccess != '[]'
    AND (
        owners IS NULL
        OR owners = '[]'
        OR json_array_length(owners) < 2
    )
ORDER BY displayName
"@

    $applications = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp

    # Load permission classification CSV
    $classificationPath = Join-Path $PSScriptRoot '../assets/aadconsentgrantpermissiontable.csv'
    if (-not (Test-Path $classificationPath)) {
        return
    }

    $permissionClassifications = Import-Csv $classificationPath

    # Filter by permission classification (exclude High privilege apps)
    # SQL already filtered for < 2 owners
    $filteredApps = @()

    if ($applications -and $applications.Count -gt 0) {
        foreach ($app in $applications) {
            # Check if app has any High privilege permissions
            $hasHighPrivilege = $false

            foreach ($req in $app.requiredResourceAccess) {
                foreach ($perm in $req.resourceAccess) {
                    $classification = $permissionClassifications | Where-Object { $_.Type -eq $perm.type -and $_.Privilege -eq 'High' }
                    if ($classification) {
                        $hasHighPrivilege = $true
                        break
                    }
                }
                if ($hasHighPrivilege) { break }
            }

            # Only include apps without High privilege permissions
            if (-not $hasHighPrivilege) {
                $filteredApps += $app
            }
        }
    }

    # ==> If no problematic apps found, test passes
    if ($filteredApps.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = 'All enterprise applications have at least two owners.'

        $params = @{
            TestId = '24518'
            Status = $passed
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Build report table for apps that failed the check
    $tableHeader =  "| App name | Multi-tenant | Permission  | Classification | Owner count |`n"
    $tableHeader += "| :-------- | :------------ | :---------- | :------------- | :----------- |`n"
    $tableRows = ''

    # Cache service principals to avoid redundant Graph calls
    $spCache = @{}

    foreach ($app in $filteredApps) {

        # Get owner count from database field
        $ownerCount = 0
        if ($app.owners -and $app.owners -ne '[]') {
            $ownersList = $app.owners | ConvertFrom-Json
            $ownerCount = $ownersList.Count
        }

        $isMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'

        # Collect unique permissions and classifications
        $permissionSet = @{}
        $classificationSet = @{}

        foreach ($req in $app.requiredResourceAccess) {
            # Cache service principal lookup
            if (-not $spCache.ContainsKey($req.resourceAppId)) {
                $spResponse = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -Filter "appId eq '$($req.resourceAppId)'" -ApiVersion v1.0
                $spCache[$req.resourceAppId] = $spResponse | Select-Object -First 1
            }

            $spObj = $spCache[$req.resourceAppId]
            if (-not $spObj) { continue }

            # Process each permission
            foreach ($perm in $req.resourceAccess) {
                # Get permission name
                $permDef = @($spObj.oauth2PermissionScopes + $spObj.appRoles) | Where-Object { $_.id -eq $perm.id }
                $permName = if ($permDef) { $permDef.displayName ?? $permDef.value } else { $perm.id }
                $permissionSet[$permName] = $true

                # Get classification
                $classRow = $permissionClassifications | Where-Object { $_.Type -eq $perm.type }
                if ($classRow) {
                    $classRow.Privilege | ForEach-Object { $classificationSet[$_] = $true }
                }
            }
        }

        $permList = if ($permissionSet.Count -gt 0) { ($permissionSet.Keys | Sort-Object) -join ', ' } else { 'None' }
        $classList = if ($classificationSet.Count -gt 0) { ($classificationSet.Keys | Sort-Object) -join ', ' } else { 'Unknown' }

        # Build clickable Entra portal link
        $entraLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/$($app.id)"
        $safeDisplayName = Get-SafeMarkdown -Text $app.displayName
        $appLink = "[$safeDisplayName]($entraLink)"

        $tableRows += "| $appLink | $isMultiTenant | $permList | $classList | $ownerCount |`n"
    }

    # If we have filtered apps, it means there are apps with < 2 owners (test fails)
    $passed = $false
    $mdInfo = "`n## Enterprise Application Ownership`n`n" + $tableHeader + $tableRows
    $testResultMarkdown = "Not all enterprise applications have at least two owners.`n$mdInfo"

    $params = @{
        TestId = '24518'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
