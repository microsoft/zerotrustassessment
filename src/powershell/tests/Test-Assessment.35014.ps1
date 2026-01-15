<#
.SYNOPSIS
    Sensitivity Label Policy Workload Coverage

.DESCRIPTION
    Sensitivity label policies must reach users across all their workloads (Exchange, SharePoint, Teams, OneDrive) to ensure consistent classification and protection. Label policies scoped to only email or only documents leave significant gaps in data protection—users may classify content in one service but bypass protection in another. Comprehensive workload coverage ensures labels are available wherever users create, edit, and share sensitive information. Organizations should verify that their label policies are configured to apply across all Microsoft 365 workloads, not just legacy email-only policies. Policies spanning multiple workloads demonstrate a mature, integrated information protection strategy that meets users where they work across the modern workplace.

.NOTES
    Test ID: 35014
    Pillar: Data
    Risk Level: High
    SFI Pillar: Protect tenants and production systems
#>

function Test-Assessment-35014 {
    [ZtTest(
        Category = 'Label Policy Configuration',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35014,
        Title = 'Sensitivity Label Policy Workload Coverage',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Sensitivity Label Policy Workload Coverage'
    Write-ZtProgress -Activity $activity -Status 'Querying label policies and workload scopes'

    $labelPolicies = $null
    $enabledPolicies = @()
    $policyWorkloadDetails = @()
    $multiWorkloadPoliciesCount = 0
    $emailOnlyPoliciesCount = 0
    $documentOnlyPoliciesCount = 0
    $xmlParseErrors = @()
    $errorMsg = $null

    try {
        # Q1: Retrieve all enabled label policies
        $enabledPolicies = Get-LabelPolicy | Where-Object { $_.Enabled -eq $true } -ErrorAction Stop

        Write-PSFMessage "Found $($enabledPolicies.Count) enabled label policies" -Level Verbose

        # Q2: Inspect policy settings for workload configuration via XML parsing
        foreach ($policy in $enabledPolicies) {
            $hasOutlook = $false
            $hasSharePoint = $false
            $hasTeams = $false
            $hasOneDrive = $false

            # Parse PolicySettingsBlob XML for workload configuration
            if (-not [string]::IsNullOrWhiteSpace($policy.PolicySettingsBlob)) {
                try {
                    $xmlSettings = [xml]$policy.PolicySettingsBlob

                    # Validate XML structure before accessing properties
                    if ($xmlSettings.settings -and $xmlSettings.settings.setting) {
                        # Access settings as XML elements for direct property lookup
                        foreach ($setting in $xmlSettings.settings.setting) {
                            # Add null safety for key and value attributes
                            if (-not $setting.key -or -not $setting.value) {
                                Write-PSFMessage "Skipping setting with null key or value in policy '$($policy.Name)'" -Level Verbose
                                continue
                            }

                            $key = $setting.key
                            $value = $setting.value

                            # Check for workload indicators in key names
                            if ($key -like '*Outlook*' -or $key -like '*Exchange*') {
                                $hasOutlook = $true
                            }
                            if ($key -like '*SharePoint*') {
                                $hasSharePoint = $true
                            }
                            if ($key -like '*Team*') {
                                $hasTeams = $true
                            }
                            if ($key -like '*OneDrive*') {
                                $hasOneDrive = $true
                            }
                        }
                    }
                    else {
                        Write-PSFMessage "Policy '$($policy.Name)' has PolicySettingsBlob but no settings elements found" -Level Verbose
                    }
                }
                catch {
                    # Track parsing errors for reporting
                    $xmlParseErrors += [PSCustomObject]@{
                        PolicyName = $policy.Name
                        Error      = $_.Exception.Message
                    }
                    Write-PSFMessage "Error parsing PolicySettingsBlob XML for policy '$($policy.Name)': $_" -Level Warning
                }
            }

            # Determine if policy has multi-workload coverage (Exchange/Outlook AND at least one other)
            $isMultiWorkload = $hasOutlook -and ($hasSharePoint -or $hasTeams -or $hasOneDrive)

            # Categorize policies
            if ($isMultiWorkload) {
                $multiWorkloadPoliciesCount++
            }
            elseif ($hasOutlook -and -not ($hasSharePoint -or $hasTeams -or $hasOneDrive)) {
                $emailOnlyPoliciesCount++
            }
            elseif (($hasSharePoint -or $hasTeams -or $hasOneDrive) -and -not $hasOutlook) {
                $documentOnlyPoliciesCount++
            }

            $policyWorkloadDetails += [PSCustomObject]@{
                Name            = $policy.Name
                Enabled         = $policy.Enabled
                ExchangeOutlook = $hasOutlook
                SharePoint      = $hasSharePoint
                Teams           = $hasTeams
                OneDrive        = $hasOneDrive
                IsMultiWorkload = $isMultiWorkload
                CreatedDate     = $policy.WhenCreatedUTC
            }
        }

        $labelPolicies = $enabledPolicies
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $investigateFlag = $false
    $passed = $false

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # Test passes if at least one enabled policy is configured for Exchange/Outlook
        # AND at least one other workload (SharePoint, Teams, OneDrive)
        if ($multiWorkloadPoliciesCount -ge 1) {
            $passed = $true
        }
        else {
            # Test fails if all enabled policies are scoped to only Exchange/email,
            # only SharePoint/documents, or scope cannot be verified
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""
    $mdInfo = ""

    if ($investigateFlag) {
        $testResultMarkdown = "⚠️ Label policies exist but workload coverage cannot be determined due to permissions or configuration issues.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Label policies are configured to reach users across multiple workloads (Exchange, SharePoint, Teams, OneDrive).`n`n"
        }
        else {
            $testResultMarkdown = "❌ Label policies are scoped to only one workload or workload configuration cannot be verified.`n`n"
        }

        $mdInfo += "## Label Policy Workload Distribution`n`n"

        if ($policyWorkloadDetails.Count -gt 0) {
            $mdInfo += "| Policy Name | Enabled | Exchange/Outlook | SharePoint | Teams | OneDrive | Multi-Workload |`n"
            $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

            foreach ($policy in $policyWorkloadDetails) {
                $enabledStatus = if ($policy.Enabled) { 'Yes' } else { 'No' }
                $exchangeStatus = if ($policy.ExchangeOutlook) { 'Yes' } else { 'No' }
                $sharePointStatus = if ($policy.SharePoint) { 'Yes' } else { 'No' }
                $teamsStatus = if ($policy.Teams) { 'Yes' } else { 'No' }
                $oneDriveStatus = if ($policy.OneDrive) { 'Yes' } else { 'No' }
                $multiWorkloadStatus = if ($policy.IsMultiWorkload) { 'Yes' } else { 'No' }

                $mdInfo += "| $($policy.Name) | $enabledStatus | $exchangeStatus | $sharePointStatus | $teamsStatus | $oneDriveStatus | $multiWorkloadStatus |`n"
            }

            $mdInfo += "`n"
        }

        # Build summary metrics
        $mdInfo += "## Summary`n`n"
        $mdInfo += "| Metric | Count |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total enabled label policies | $(@($labelPolicies).Count) |`n"
        $mdInfo += "| Policies with multi-workload coverage | $multiWorkloadPoliciesCount |`n"
        $mdInfo += "| Email-only policies | $emailOnlyPoliciesCount |`n"
        $mdInfo += "| Document-only policies | $documentOnlyPoliciesCount |`n"

        # Report XML parsing errors if any occurred
        if ($xmlParseErrors.Count -gt 0) {
            $mdInfo += "`n`n### ⚠️ XML Parsing Errors`n"
            $mdInfo += "The following policies could not be fully analyzed due to XML parsing issues:`n`n"
            $mdInfo += "| Policy Name | Error |`n"
            $mdInfo += "| :--- | :--- |`n"
            foreach ($parseError in $xmlParseErrors) {
                $mdInfo += "| $($parseError.PolicyName) | $($parseError.Error) |`n"
            }
            $mdInfo += "`n**Note**: These policies were analyzed with available data but workload coverage may be incomplete.`n"
        }

        $mdInfo += "`n[View Label Policies](https://purview.microsoft.com/informationprotection/labelpolicies)`n"
        $testResultMarkdown += $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '35014'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($investigateFlag -eq $true) {
        $params.CustomStatus = 'Investigate'
    }
    Add-ZtTestResultDetail @params
}
