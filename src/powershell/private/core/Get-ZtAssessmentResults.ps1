<#
.SYNOPSIS
    Gets the results of all the Zero Trust Assessment tests
#>

function Get-ZtAssessmentResults {
    [CmdletBinding()]
    param ()

    $mgContext = Get-MgContext

    $tenantId = $mgContext.TenantId
    $org = GetOrganization
    $account = $mgContext.Account

    $currentVersion = ((Get-Module -Name ZeroTrustAssessmentV2).Version | Select-Object -Last 1).ToString()
    $latestVersion = GetModuleLatestVersion

    $tests = $__ZtSession.TestResultDetail.values | Sort-Object -Property @{Expression = { $_.TestRisk }}, @{Expression = { $_.TestStatus } }

    # Sort by risk then by status
    $ztTestResults = [PSCustomObject]@{
        ExecutedAt     = GetFormattedDate(Get-Date)
        TenantId       = $tenantId
        TenantName     = $org.TenantName
        Domain         = $org.Domain
        Account        = $account
        CurrentVersion = $currentVersion
        LatestVersion  = $latestVersion
        TestResultSummary = GetTestResultSummary $__ZtSession.TestResultDetail.values
        Tests          = @($tests) # Use @() to ensure it's an array
        TenantInfo     = $__ZtSession.TenantInfo
        EndOfJson      = "EndOfJson" # Always leave this as the last property. Used by the script to determine the end of the JSON
    }

    Write-PSFMessage $ztTestResults -Level Debug -Tag ZtAssessmentResults
    return $ztTestResults
}

function GetModuleLatestVersion() {
    if (Get-Command 'Find-Module' -ErrorAction SilentlyContinue) {
        return (Find-Module -Name ZeroTrustAssessmentV2).Version
    }

    return 'Unknown'
}

function GetFormattedDate($date) {
    if(!$IsCoreCLR) { # Prevent 5.1 date format to json issue
        return $date.ToString("o")
    }
    else {
        return $date
    }
}

function GetOrganization() {
    $org = Invoke-ZtGraphRequest -RelativeUri 'organization'
    $defaultDomain = $org.verifiedDomains | Where-Object { $_.isDefault } | Select-Object -First 1
    return [PSCustomObject]@{
        TenantName = $org.displayName
        Domain     = $defaultDomain.name
    }
}

function GetTestPassedCount($testResults, $pillar) {
    return $testResults | Where-Object { $_.TestPillar -eq $pillar -and $_.TestStatus -eq 'Passed' } | Measure-Object | Select-Object -ExpandProperty Count
}

function GetTestTotalCount($testResults, $pillar) {
    return $testResults | Where-Object { $_.TestPillar -eq $pillar -and $_.TestStatus -ne 'Skipped' -and $_.TestStatus -ne 'Planned'  } | Measure-Object | Select-Object -ExpandProperty Count
}

function GetTestResultSummary($testResults) {
    $summary = [PSCustomObject]@{
        IdentityPassed = GetTestPassedCount $testResults 'Identity'
        IdentityTotal = GetTestTotalCount $testResults 'Identity'
        DevicesPassed = GetTestPassedCount $testResults 'Devices'
        DevicesTotal = GetTestTotalCount $testResults 'Devices'
        DataPassed = GetTestPassedCount $testResults 'Data'
        DataTotal = GetTestTotalCount $testResults 'Data'
    }

    return $summary
}
