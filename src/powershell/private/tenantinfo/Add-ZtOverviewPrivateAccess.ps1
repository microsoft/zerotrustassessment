<#
.SYNOPSIS
    Builds the Private Access Zero Trust posture funnel (spec 27021).

.DESCRIPTION
    Aggregates the per-item rows published by the segmentation (25395), authentication (25396)
    and administration (25384) checks into a Sankey funnel.

    Every Private Access application enters at the source node and flows through two sequential
    gates. Segmentation and authentication share the application denominator and are joined on
    App ID, so only apps that clear segmentation are partitioned by the authentication gate.
    Administration is denominated in role assignments, not applications, so it is rendered as a
    separate band.
#>

function Add-ZtOverviewPrivateAccess {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'OverviewPrivateAccess'

    $activity = 'Building Private Access Zero Trust posture'
    Write-ZtProgress -Activity $activity -Status 'Processing'

    $segmentation = @(Get-ZtTestData -Name 'PrivateAccessSegmentation')
    $authentication = @(Get-ZtTestData -Name 'PrivateAccessAuthentication')
    $administration = Get-ZtTestData -Name 'PrivateAccessAdministration'

    if ($segmentation.Count -eq 0 -and $authentication.Count -eq 0 -and $null -eq $administration) {
        Write-PSFMessage '🟦 Skipping: No Private Access check results available' -Tag Test -Level VeryVerbose
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    # Gate 1 - partition every Private Access app by its segmentation status
    $broadSegments = @($segmentation | Where-Object { $_.Status -eq 'Fail' }).Count
    $segmentationReview = @($segmentation | Where-Object { $_.Status -eq 'ManualReview' }).Count
    $leastPrivilegeApps = @($segmentation | Where-Object { $_.Status -eq 'Pass' })

    # Gate 2 - partition only the segmentation-clean apps, joined to the auth gate on App ID
    $authByAppId = @{}
    foreach ($row in $authentication) {
        if ($row.AppId) { $authByAppId[[string]$row.AppId] = $row.Status }
    }

    $passwordOnly = 0
    $authenticationReview = 0
    $strongAuth = 0
    foreach ($app in $leastPrivilegeApps) {
        switch ($authByAppId[[string]$app.AppId]) {
            'Pass' { $strongAuth++ }
            'Fail' { $passwordOnly++ }
            # An app with no matching authentication row was not evaluated by 25396
            default { $authenticationReview++ }
        }
    }

    # Gate 3 - separate band denominated in Application Administrator assignments
    $tenantWideAdmin = ($administration.TenantWide -as [int]) ?? 0
    $scopedAdmin = ($administration.Scoped -as [int]) ?? 0

    $nodes = @(
        @{ source = 'Private Access apps'; target = 'Broad segments - at-risk'; value = $broadSegments }
        @{ source = 'Private Access apps'; target = 'Segmentation manual review'; value = $segmentationReview }
        @{ source = 'Private Access apps'; target = 'Least-privilege segments'; value = $leastPrivilegeApps.Count }
        @{ source = 'Least-privilege segments'; target = 'Password-only - at-risk'; value = $passwordOnly }
        @{ source = 'Least-privilege segments'; target = 'Authentication manual review'; value = $authenticationReview }
        @{ source = 'Least-privilege segments'; target = 'Strong auth - Zero Trust'; value = $strongAuth }
        @{ source = 'Application Administrator assignments'; target = 'Tenant-wide admin - at-risk'; value = $tenantWideAdmin }
        @{ source = 'Application Administrator assignments'; target = 'App-scoped admin - Zero Trust'; value = $scopedAdmin }
    )

    $summary = @{
        description = "$($segmentation.Count) Private Access application(s) evaluated. $strongAuth reached the Zero Trust set by clearing both least-privilege segmentation and strong authentication."
        nodes       = $nodes
        # A tenant-wide Application Administrator can rewrite segments and authentication for every app
        adminAtRisk = $tenantWideAdmin -gt 0
        # The two gates disagree on the app population, so unmatched apps need review
        populationMismatch = ($segmentation.Count -ne $authentication.Count)
    }

    Add-ZtTenantInfo -Name $tenantInfoName -Value $summary
}
