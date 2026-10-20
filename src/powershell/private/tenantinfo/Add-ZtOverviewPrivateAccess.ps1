<#
.SYNOPSIS
    Builds the Private Access Zero Trust posture funnel (spec 27021).

.DESCRIPTION
    Aggregates the per-item rows published by the segmentation (25395), authentication (25396)
    and administration (25384) checks into a Sankey funnel.

    Each gate keeps its child roll-up verdict; the flow widths only quantify the gap and never
    replace that verdict. A child that was skipped, errored, timed out or was excluded from the
    run has no verdict, so its band is reported as unavailable instead of being folded into pass,
    fail or manual review.

    Every Private Access application enters at the source node and flows through two sequential
    gates. Segmentation and authentication are joined on App ID over the union of both app
    populations, so authentication-only apps (for example Quick Access) stay visible. Only apps
    that clear segmentation are partitioned by the authentication gate. Administration is
    denominated in role assignments, not applications, so it is rendered as a separate band.
#>

function Add-ZtOverviewPrivateAccess {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'OverviewPrivateAccess'

    $activity = 'Building Private Access Zero Trust posture'
    Write-ZtProgress -Activity $activity -Status 'Processing'

    # Skipped, errored and never-run children have no verdict to roll up, so their gate is unavailable
    $gateStatuses = @{}
    foreach ($testId in '25395', '25396', '25384') {
        $gateStatuses[$testId] = switch (Get-ZtTestResultStatus -TestId $testId) {
            'Passed' { 'Passed' }
            'Failed' { 'Failed' }
            'Investigate' { 'Investigate' }
            default { 'Unavailable' }
        }
    }

    $segmentationGate = $gateStatuses['25395']
    $authenticationGate = $gateStatuses['25396']
    $administrationGate = $gateStatuses['25384']

    $segmentationAvailable = $segmentationGate -ne 'Unavailable'
    $authenticationAvailable = $authenticationGate -ne 'Unavailable'
    $administrationAvailable = $administrationGate -ne 'Unavailable'

    if (-not ($segmentationAvailable -or $authenticationAvailable -or $administrationAvailable)) {
        Write-PSFMessage '🟦 Skipping: No Private Access check results available' -Tag Test -Level VeryVerbose
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $segmentationRows = @(Get-ZtTestData -Name 'PrivateAccessSegmentation')
    $authenticationRows = @(Get-ZtTestData -Name 'PrivateAccessAuthentication')
    $administration = Get-ZtTestData -Name 'PrivateAccessAdministration'

    # Distinct, case-insensitive App IDs: equal row counts do not prove the children saw the same apps
    $segmentationByAppId = @{}
    foreach ($row in $segmentationRows) {
        if ($row.AppId) {
            $segmentationByAppId[([string]$row.AppId).Trim().ToLowerInvariant()] = [string]$row.Status
        }
    }

    $authenticationByAppId = @{}
    foreach ($row in $authenticationRows) {
        if ($row.AppId) {
            $authenticationByAppId[([string]$row.AppId).Trim().ToLowerInvariant()] = [string]$row.Status
        }
    }

    # Denominate the funnel in the union so authentication-only apps are not dropped from the source
    $population = @(@($segmentationByAppId.Keys) + @($authenticationByAppId.Keys) | Select-Object -Unique)

    # Gate 1 - partition every Private Access app by its segmentation status
    $broadSegments = 0
    $segmentationReview = 0
    $segmentationUnavailable = 0
    $leastPrivilegeApps = [System.Collections.Generic.List[string]]::new()

    foreach ($appId in $population) {
        switch ($segmentationByAppId[$appId]) {
            'Fail' { $broadSegments++ }
            'ManualReview' { $segmentationReview++ }
            'Pass' { $leastPrivilegeApps.Add($appId) }
            # No segmentation row: 25395 never evaluated this app, so its segmentation state is unknown
            default { $segmentationUnavailable++ }
        }
    }

    # Gate 2 - partition only the segmentation-clean apps, joined to the auth gate on App ID
    $bothPopulationsComplete = $segmentationAvailable -and $authenticationAvailable
    $passwordOnly = 0
    $authenticationReview = 0
    $authenticationUnavailable = 0
    $strongAuth = 0

    foreach ($appId in $leastPrivilegeApps) {
        switch ($authenticationByAppId[$appId]) {
            'Pass' { $strongAuth++ }
            'Fail' { $passwordOnly++ }
            'ManualReview' { $authenticationReview++ }
            default {
                # An unmatched app is only a genuine review item when both children completed
                if ($bothPopulationsComplete) { $authenticationReview++ } else { $authenticationUnavailable++ }
            }
        }
    }

    # Gate 3 - separate band denominated in Application Administrator assignments
    $tenantWideAdmin = 0
    $scopedAdminAtRisk = 0
    $scopedAdminZeroTrust = 0
    if ($administrationAvailable -and $administration) {
        $tenantWideAdmin = [Math]::Max(0, ($administration.TenantWide -as [int]) ?? 0)
        $scopedTotal = [Math]::Max(0, ($administration.Scoped -as [int]) ?? 0)
        # Scoped assignments held by groups, service principals or guests still fail 25384
        $scopedAdminAtRisk = [Math]::Min($scopedTotal, [Math]::Max(0, ($administration.ScopedAtRisk -as [int]) ?? 0))
        $scopedAdminZeroTrust = $scopedTotal - $scopedAdminAtRisk
    }

    $gates = @(
        [PSCustomObject]@{ testId = '25395'; name = 'Least-privilege segmentation'; status = $segmentationGate }
        [PSCustomObject]@{ testId = '25396'; name = 'Strong authentication'; status = $authenticationGate }
        [PSCustomObject]@{ testId = '25384'; name = 'Administrative containment'; status = $administrationGate }
    )

    $allGateStatuses = @($segmentationGate, $authenticationGate, $administrationGate)
    $degraded = $allGateStatuses -contains 'Unavailable'

    $populationMismatch = $false
    if ($bothPopulationsComplete) {
        $populationMismatch =
            @($segmentationByAppId.Keys | Where-Object { -not $authenticationByAppId.ContainsKey($_) }).Count -gt 0 -or
            @($authenticationByAppId.Keys | Where-Object { -not $segmentationByAppId.ContainsKey($_) }).Count -gt 0
    }

    $overallStatus = if ($allGateStatuses -contains 'Failed') {
        'Failed'
    }
    # An unavailable gate cannot be asserted to pass, so the overall result stays short of Passed
    elseif (($allGateStatuses -contains 'Investigate') -or $degraded -or $populationMismatch) {
        'Investigate'
    }
    else {
        'Passed'
    }

    $nodes = @(
        @{ source = 'Private Access apps'; target = 'Broad segments - at-risk'; value = $broadSegments }
        @{ source = 'Private Access apps'; target = 'Segmentation manual review'; value = $segmentationReview }
        @{ source = 'Private Access apps'; target = 'Segmentation unavailable'; value = $segmentationUnavailable }
        @{ source = 'Private Access apps'; target = 'Least-privilege segments'; value = $leastPrivilegeApps.Count }
        @{ source = 'Least-privilege segments'; target = 'Password-only - at-risk'; value = $passwordOnly }
        @{ source = 'Least-privilege segments'; target = 'Authentication manual review'; value = $authenticationReview }
        @{ source = 'Least-privilege segments'; target = 'Authentication unavailable'; value = $authenticationUnavailable }
        @{ source = 'Least-privilege segments'; target = 'Strong auth - Zero Trust'; value = $strongAuth }
        @{ source = 'Application Administrator assignments'; target = 'Tenant-wide admin - at-risk'; value = $tenantWideAdmin }
        @{ source = 'Application Administrator assignments'; target = 'App-scoped admin - at-risk'; value = $scopedAdminAtRisk }
        @{ source = 'Application Administrator assignments'; target = 'App-scoped admin - Zero Trust'; value = $scopedAdminZeroTrust }
        @{ source = 'Application Administrator assignments'; target = 'Administration unavailable'; value = [int](-not $administrationAvailable) }
    )

    $description = "$($population.Count) Private Access application(s) evaluated. $strongAuth reached the Zero Trust set by clearing both least-privilege segmentation and strong authentication."
    if ($degraded) {
        $unavailableGates = @($gates | Where-Object { $_.status -eq 'Unavailable' } | ForEach-Object { $_.name })
        $description += " Flow widths are incomplete because the following gate(s) produced no result: $($unavailableGates -join ', ')."
    }

    $summary = @{
        description        = $description
        nodes              = $nodes
        # Per-gate roll-up verdicts; the widths quantify the gap but never determine the verdict
        gates              = $gates
        overallStatus      = $overallStatus
        # At least one gate has no verdict, so the funnel is only a partial view
        degraded           = $degraded
        applicationCount   = $population.Count
        # An over-privileged Application Administrator can rewrite segments and authentication for every app
        adminAtRisk        = ($tenantWideAdmin + $scopedAdminAtRisk) -gt 0
        tenantWideAdmin    = $tenantWideAdmin
        scopedAdminAtRisk  = $scopedAdminAtRisk
        # The two gates evaluated different app sets, so unmatched apps need review
        populationMismatch = $populationMismatch
    }

    Add-ZtTenantInfo -Name $tenantInfoName -Value $summary
}
