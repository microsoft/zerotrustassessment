function Add-ZtOverviewPrivateAccess {
    [CmdletBinding()]
    param(
        $TestResults = $script:__ZtSession.TestResultDetail.Value.Values
    )

    $tenantInfoName = 'OverviewPrivateAccess'
    $segmentation = @($TestResults | Where-Object { $_.TestId -eq '25395' } | Select-Object -First 1)
    $authentication = @($TestResults | Where-Object { $_.TestId -eq '25396' } | Select-Object -First 1)
    $administration = @($TestResults | Where-Object { $_.TestId -eq '25384' } | Select-Object -First 1)

    if (-not $segmentation -or -not $authentication -or -not $administration -or
        -not $segmentation.TestData -or -not $authentication.TestData -or -not $administration.TestData) {
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $segmentationApps = @($segmentation.TestData.Applications)
    $authenticationApps = @($authentication.TestData.Applications)
    $segmentationTotal = [int]$segmentation.TestData.TotalApps
    $authenticationTotal = [int]$authentication.TestData.TotalApps

    if ($segmentationApps.Count -ne $segmentationTotal -or $authenticationApps.Count -ne $authenticationTotal) {
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $unmatchedAuthenticationApps = @($authenticationApps | Where-Object { $_.AppId -and $_.AppId -notin $segmentationApps.AppId })
    $unmatchedSegmentationApps = @($segmentationApps | Where-Object { $_.AppId -and $_.AppId -notin $authenticationApps.AppId })
    $populationMismatch = ($unmatchedAuthenticationApps.Count + $unmatchedSegmentationApps.Count) -gt 0
    $authenticationByAppId = @{}
    foreach ($app in $authenticationApps) {
        if ($app.AppId) {
            $authenticationByAppId[$app.AppId] = $app
        }
    }

    $broadSegments = @($segmentationApps | Where-Object { $_.Status -eq 'Fail' })
    $segmentationManualReview = @($segmentationApps | Where-Object { $_.Status -eq 'Manual Review' })
    $segmentationClean = @($segmentationApps | Where-Object { $_.Status -eq 'Pass' })
    $authenticationResults = @($segmentationClean | ForEach-Object { $authenticationByAppId[$_.AppId] } | Where-Object { $_ })

    if ($authenticationResults.Count -ne $segmentationClean.Count) {
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
        return
    }

    $passwordOnly = @($authenticationResults | Where-Object { $_.Status -eq 'Unprotected' }).Count
    $authenticationManualReview = @($authenticationResults | Where-Object { $_.Status -eq 'Manual Review' }).Count
    $strongAuth = @($authenticationResults | Where-Object { $_.Status -eq 'Protected' }).Count
    $assignments = @($administration.TestData.Assignments)
    $tenantWideAssignments = @($assignments | Where-Object { $_.directoryScopeId -eq '/' }).Count
    $appScopedAssignments = $assignments.Count - $tenantWideAssignments

    $nodes = @(
        @{ source = 'Private Access apps'; target = 'Broad segments - at-risk (25395)'; value = $broadSegments.Count },
        @{ source = 'Private Access apps'; target = 'Segmentation manual review (25395)'; value = $segmentationManualReview.Count },
        @{ source = 'Private Access apps'; target = 'Population mismatch - manual review (25396)'; value = ($unmatchedAuthenticationApps.Count + $unmatchedSegmentationApps.Count) },
        @{ source = 'Private Access apps'; target = 'Least-privilege segments (25395)'; value = $segmentationClean.Count },
        @{ source = 'Least-privilege segments (25395)'; target = 'Password-only - at-risk (25396)'; value = $passwordOnly },
        @{ source = 'Least-privilege segments (25395)'; target = 'Authentication manual review (25396)'; value = $authenticationManualReview },
        @{ source = 'Least-privilege segments (25395)'; target = 'Strong auth - Zero Trust (25396)'; value = $strongAuth },
        @{ source = 'Application Administrator assignments'; target = 'Tenant-wide admin - at-risk (25384)'; value = $tenantWideAssignments },
        @{ source = 'Application Administrator assignments'; target = 'App-scoped admin - Zero Trust (25384)'; value = $appScopedAssignments }
    )

    Add-ZtTenantInfo -Name $tenantInfoName -Value @{
        description        = 'Private Access applications pass through segmentation and strong-authentication gates. Application Administrator assignments are a separate control-plane denominator.'
        nodes              = $nodes
        adminAtRisk        = $tenantWideAssignments -gt 0
        populationMismatch = $populationMismatch
    }
}
