
function Test-Assessment-25539 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure Firewall Premium SKU'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25539,
        Title = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }
    #region Azure Connection Verification
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch [Management.Automation.CommandNotFoundException] {
        Write-PSFMessage $_.Exception.Message -Tag Test  -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }
    #endregion Azure Connection Verification

    #region Data Collection
    $azAccessToken = ($accessToken.Token)
    $resourceManagementUrl = (Get-AzContext).Environment.ResourceManagerUrl
    $subId = (Get-AzContext).Subscription.Id

    $listUri = $resourceManagementUrl.TrimEnd('/') + "/subscriptions/$subId/providers/Microsoft.Network/firewallPolicies?api-version=2025-03-01"

    try {
        $listResponse = Invoke-WebRequest -Uri $listUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like "*403*" -or $_.Exception.Message -like "*Forbidden*") {
            Write-PSFMessage "The signed in user does not have access to the Azure subscription to enumerate firewall policies." -Tag Test -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
        else {
            throw
        }
    }

    $policies = $listResponse.Content | ConvertFrom-Json
    $policyItems = @()
    if ($policies.value) {
        $policyItems = $policies.value
    }

    $firewallPolicies = @()
    foreach ($policy in $policyItems) {
        # fetch full details to inspect intrusionDetection and sku
        $detailUri = $resourceManagementUrl.TrimEnd('/') + "$($policy.id)?api-version=2025-03-01"
        try {
            $detailResp = Invoke-WebRequest -Uri $detailUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
            $detail = $detailResp.Content | ConvertFrom-Json
        }
        catch {
            Write-PSFMessage "Unable to retrieve details for $($policy.name): $($_.Exception.Message)" -Tag Test -Level Warning
            continue
        }

        $policyObj = [PSCustomObject]@{
            Name                   = $detail.name
            Id                     = $detail.id
            IntrusionDetectionMode = if ($detail.properties.intrusionDetection -and $detail.properties.intrusionDetection.mode) {
                $detail.properties.intrusionDetection.mode
            }
            else {
                'Off'
            }
        }
        $firewallPolicies += $policyObj
    }

    $nonCompliant = $firewallPolicies | Where-Object { $_.IntrusionDetectionMode -notin @('Deny') }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ''

    # Check if no firewall policies exist
    if ($firewallPolicies.Count -eq 0) {
        Write-Debug "No firewall policies found in the subscription."
        Write-Warning "No firewall policies found in the subscription."
        Write-Host "No firewall policies found in the subscription."
        Write-PSFMessage "No firewall policies found in the subscription." -Tag Stage -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $passed = ($nonCompliant.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "Intrusion Detection is enabled in 'Deny' mode for all Azure Firewall policies.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Azure Firewall policies are not configured with IDPS 'Deny' mode.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Result Reporting
    $mdInfo = ''

    # Create mapping for IntrusionDetectionMode to UI labels
    $modeMapping = @{
        'Off'   = 'Disabled'
        'Alert' = 'Alert'
        'Deny'  = 'Alert and deny'
    }

    # Display table based on test result
    if ($passed) {
        # Show all policies with checkmarks when passed
        $mdInfo = "## Firewall policy IDPS status`n`n"
        $mdInfo += "| Name | Intrusion Detection Mode |`n"
        $mdInfo += "| :--- | :--- |`n"

        foreach ($item in $firewallPolicies | Sort-Object Name) {
            $policyLink = "https://portal.azure.com/#@/resource$($item.Id)"
            $displayMode = $modeMapping[$item.IntrusionDetectionMode]
            $safePolicyName = Get-SafeMarkdown -Text $item.Name
            $mdInfo += "| ✅ [$safePolicyName]($policyLink) | $displayMode |`n"
        }
    }
    else {
        # Show only non-compliant policies when failed
        $mdInfo = "## Firewall policies without 'Alert and deny' mode`n`n"
        $mdInfo += "| Name | Intrusion Detection Mode |`n"
        $mdInfo += "| :--- | :--- |`n"

        foreach ($item in $nonCompliant | Sort-Object Name) {
            $policyLink = "https://portal.azure.com/#@/resource$($item.Id)"
            $displayMode = $modeMapping[$item.IntrusionDetectionMode]
            $safePolicyName = Get-SafeMarkdown -Text $item.Name
            $mdInfo += "| ❌ [$safePolicyName]($policyLink) | $displayMode |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    $params = @{
        TestId = '25539'
        Status = $passed
        Result = $testResultMarkdown
    }
    #endregion Result Reporting
    Add-ZtTestResultDetail @params
}
