<#
.SYNOPSIS
    Checks that enterprise applications require explicit assignment or have scoped provisioning controls.
#>

function Test-Assessment-21869 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21869,
    	Title = 'Enterprise applications must require explicit assignment or scoped provisioning',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Checking enterprise applications assignment and provisioning requirements'
    Write-ZtProgress -Activity $activity -Status 'Getting service principals without assignment requirements'

    # Query 1: Get service principals that don't require assignment
    $sql = @"
SELECT
    id,
    appId,
    displayName,
    preferredSingleSignOnMode,
    accountEnabled
FROM ServicePrincipal
WHERE appRoleAssignmentRequired = 'false'
    AND preferredSingleSignOnMode IS NOT NULL
    AND preferredSingleSignOnMode IN ('password', 'saml', 'oidc')
    AND accountEnabled = true
ORDER BY LOWER(displayName) ASC
"@

    $servicePrincipals = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    Write-PSFMessage "Found $($servicePrincipals.Count) service principals without assignment requirements" -Level Verbose

    if ($servicePrincipals.Count -eq 0) {
        # No applications without assignment requirements - pass

        $params = @{
            TestId             = '21869'
            Status             = $true
            Result             = 'All enterprise applications have explicit assignment requirements.'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Track applications with issues
    $appsWithoutProvisioningJobs = @()
    $appsWithUnscopedProvisioning = @()

    # Query 2 & 3: Check provisioning jobs and scoping for each service principal
    $totalApps = $servicePrincipals.Count
    $currentApp = 0

    foreach ($sp in $servicePrincipals) {
        $currentApp++
        Write-ZtProgress -Activity $activity -Status "Checking provisioning for $($sp.displayName) ($currentApp of $totalApps)"

        Write-PSFMessage "Checking provisioning jobs for: $($sp.displayName) (ID: $($sp.id))" -Level Verbose

        # Query 2: Get provisioning jobs for this service principal
        $provisioningJobsUri = "servicePrincipals/$($sp.id)/synchronization/jobs"

        try {
            $provisioningJobs = Invoke-ZtGraphRequest -RelativeUri $provisioningJobsUri -ApiVersion beta

            if (-not $provisioningJobs -or $provisioningJobs.Count -eq 0) {
                # No provisioning jobs configured - this is a failure
                Write-PSFMessage "No provisioning jobs found for $($sp.displayName)" -Level Verbose

                $appsWithoutProvisioningJobs += @{
                    ServicePrincipal = $sp
                    Reason = 'No provisioning jobs configured'
                }
                continue
            }

            Write-PSFMessage "Found $($provisioningJobs.Count) provisioning job(s) for $($sp.displayName)" -Level Verbose

            # Query 3: Check scoping filters for each provisioning job
            $jobsWithoutScoping = @()

            foreach ($job in $provisioningJobs) {
                Write-PSFMessage "Checking scoping for job: $($job.id) - $($job.templateId)" -Level Verbose

                # Get the provisioning schema to check scoping filters
                $schemaUri = "servicePrincipals/$($sp.id)/synchronization/jobs/$($job.id)/schema"

                try {
                    $schema = Invoke-ZtGraphRequest -RelativeUri $schemaUri -ApiVersion beta

                    $scopingInfo = 'Scoping configured'
                    $hasScopingFilter = $true

                    # Check if ALL objectMappings have a scope configured
                    if ($schema -and $schema.synchronizationRules) {
                        Write-PSFMessage "Analyzing $($schema.synchronizationRules.Count) synchronization rule(s)" -Level Verbose

                        foreach ($rule in $schema.synchronizationRules) {
                            if ($rule.objectMappings) {
                                # Check if any mapping lacks a scope
                                $mappingWithoutScope = $rule.objectMappings | Where-Object { -not $_.scope }

                                if ($mappingWithoutScope) {
                                    $hasScopingFilter = $false
                                    $scopingInfo = 'No scoping configured'
                                    Write-PSFMessage "Found objectMapping without scope in rule: $($rule.name)" -Level Verbose
                                    break  # Exit early - we found a mapping without scope
                                }
                            }
                        }
                    } else {
                        Write-PSFMessage 'No synchronization rules found in schema' -Level Verbose
                        $hasScopingFilter = $false
                        $scopingInfo = 'No synchronization rules found'
                    }

                    # Only track jobs WITHOUT proper scoping
                    if (-not $hasScopingFilter) {
                        $jobsWithoutScoping += @{
                            JobId = $job.id
                            JobName = $job.templateId
                            Scoping = $scopingInfo
                        }
                    }

                } catch {
                    Write-PSFMessage "Error checking schema for job $($job.id): $_" -Level Warning
                    $jobsWithoutScoping += @{
                        JobId = $job.id
                        JobName = $job.templateId
                        Scoping = 'Error retrieving scoping information'
                    }
                }
            }

            # If any jobs lack proper scoping, add to failures
            if ($jobsWithoutScoping.Count -gt 0) {
                Write-PSFMessage "Found $($jobsWithoutScoping.Count) job(s) without proper scoping for $($sp.displayName)" -Level Verbose

                $appsWithUnscopedProvisioning += @{
                    ServicePrincipal = $sp
                    Jobs = $jobsWithoutScoping
                    Reason = 'Provisioning jobs lack proper scoping filters'
                }
            } else {
                Write-PSFMessage "All provisioning jobs have proper scoping for $($sp.displayName)" -Level Verbose
            }

        } catch {
            Write-PSFMessage "Error checking provisioning jobs for $($sp.displayName): $_" -Level Warning
            # If we can't check provisioning, treat as no provisioning
            $appsWithoutProvisioningJobs += @{
                ServicePrincipal = $sp
                Reason = 'Error checking provisioning configuration'
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $totalIssues = $appsWithoutProvisioningJobs.Count + $appsWithUnscopedProvisioning.Count

    Write-PSFMessage "Assessment data: TotalApps=$totalApps, IssuesFound=$totalIssues" -Level Verbose

    if ($totalIssues -eq 0) {
        $passed = $true
        $testResultMarkdown = 'All enterprise applications require explicit assignment or have scoped provisioning controls.'
    } else {
        $passed = $false
        $testResultMarkdown = 'Found enterprise applications that lack both assignment requirements and provisioning scoping.'
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build markdown output
    $mdInfo = ""

    if ($totalIssues -gt 0) {
        # Applications without provisioning jobs
        if ($appsWithoutProvisioningJobs.Count -gt 0) {
            $mdInfo += "`n## Applications without provisioning jobs ($($appsWithoutProvisioningJobs.Count))`n`n"
            $mdInfo += "| Display name | Reason |`n"
            $mdInfo += "| :----------- | :----- |`n"

            foreach ($app in $appsWithoutProvisioningJobs) {
                $sp = $app.ServicePrincipal
                $spLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($sp.id)/appId/$($sp.appId)"
                $displayName = $sp.displayName
                $displayNameLink = "[$displayName]($spLink)"

                $mdInfo += "| $displayNameLink | $($app.Reason) |`n"
            }
            $mdInfo += "`n"
        }

        # Applications with unscoped provisioning
        if ($appsWithUnscopedProvisioning.Count -gt 0) {
            $mdInfo += "## Applications with unscoped provisioning ($($appsWithUnscopedProvisioning.Count))`n`n"
            $mdInfo += "These applications do not require assignment and have provisioning jobs without proper scoping filters.`n`n"

            foreach ($app in $appsWithUnscopedProvisioning) {
                $sp = $app.ServicePrincipal
                $spLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($sp.id)/appId/$($sp.appId)"
                $displayName = $sp.displayName
                $displayNameLink = "[$displayName]($spLink)"

                $mdInfo += "### $displayNameLink`n`n"
                $mdInfo += "**Display name:** $displayNameLink`n`n"
                $mdInfo += "**Provisioning jobs:**`n`n"
                $mdInfo += "| Job id | Job name | Job scoping |`n"
                $mdInfo += "| :----- | :------- | :---------- |`n"

                foreach ($job in $app.Jobs) {
                    $mdInfo += "| ``$($job.JobId)`` | $($job.JobName) | $($job.Scoping) |`n"
                }
                $mdInfo += "`n"
                $mdInfo += "**Reason for fail:** Enterprise application does not require assignment and provisioning is not properly scoped`n`n"
            }
        }
    }

    # Append details to the test result
    $testResultMarkdown += $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '21869'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
