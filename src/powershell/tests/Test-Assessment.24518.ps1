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

    # ==> If no applications with < 2 owners found, test passes
    if (-not $applications -or $applications.Count -eq 0) {
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

    # Load permission classification CSV
    $classificationPath = Join-Path $PSScriptRoot '../assets/aadconsentgrantpermissiontable.csv'
    if (-not (Test-Path $classificationPath)) {
        return
    }

    $permissionClassifications = Import-Csv $classificationPath

    # Filter by permission classification (exclude High privilege apps)
    # SQL already filtered for < 2 owners
    $filteredApps = @()
    foreach ($app in $applications) {
        # Check permissions
        $allPerms = $app.requiredResourceAccess | ForEach-Object { $_.resourceAccess } | Where-Object { $_ }
        $permClass = @()

        foreach ($perm in $allPerms) {
            $row = $permissionClassifications | Where-Object { $_.Type -eq $perm.type }
            if ($row) { $permClass += $row.Privilege }
        }

        # Only include apps without High privilege permissions
        if ($permClass -and ($permClass -notcontains 'High')) {
            $filteredApps += $app
        }
    }

    # ==> If no apps with insufficient owners and non-High permissions, test passes
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
            $ownerCount = ($ownersList | Measure-Object).Count
        }

        $isMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'

        $permDisplay = @()
        $classDisplay = @()

        foreach ($req in $app.requiredResourceAccess) {
            $resourceAppId = $req.resourceAppId
            if (-not $resourceAppId) { continue }

            # Use cached Service Principal details to minimize calls
            if (-not $spCache.ContainsKey($resourceAppId)) {
                $spResponse = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -Filter "appId eq '$resourceAppId'" -ApiVersion v1.0
                $spObj = $spResponse | Select-Object -First 1
                $spCache[$resourceAppId] = $spObj
            }

            $spObj = $spCache[$resourceAppId]
            if (-not $spObj) { continue }

            # Match and classify permissions
            foreach ($perm in $req.resourceAccess) {
                $permId = $perm.id
                $permType = $perm.type

                # Get permission name from Graph response (oauth2PermissionScopes or appRoles)
                $permDef = @($spObj.oauth2PermissionScopes + $spObj.appRoles) | Where-Object { $_.id -eq $permId }
                $permName = if ($permDef) {
                                if ($permDef.displayName) { $permDef.displayName } else { $permDef.value }
                            } else {
                                $permId
                }


                # Find classification for this permission type
                $classRow = $permissionClassifications | Where-Object { $_.Type -eq $permType }
                $classification = if ($classRow) { ($classRow.Privilege | Sort-Object -Unique) -join ', ' } else { 'Unknown' }

                $permDisplay += $permName
                $classDisplay += $classification
            }
        }

        $permList = if ($permDisplay) { ($permDisplay | Sort-Object -Unique) -join ', '} else { 'None' }
        $classList = if ($classDisplay) { ($classDisplay | Sort-Object -Unique) -join ', '} else { 'Unknown' }

        # Build clickable Entra portal link for the application
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
