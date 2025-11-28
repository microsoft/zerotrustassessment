
<#
.SYNOPSIS

#>



function Test-Assessment-24546 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
        MinimumLicense = ('P1'),
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24546,
    	Title = 'Windows automatic device enrollment is enforced to eliminate risks from unmanaged endpoints',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = "Checking Windows Automatic Enrollment is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve Mobile Device Management Policies
    $MDMPoliciesUri = "policies/mobileDeviceManagementPolicies"
    $MDMPolicies = Invoke-ZtGraphRequest -RelativeUri $MDMPoliciesUri -ApiVersion beta

    # Convert to array if it's a single value to ensure consistent handling
    if ($null -eq $MDMPolicies) {
        $MDMPolicies = @()
    }
    elseif ($MDMPolicies -isnot [array]) {
        $MDMPolicies = @($MDMPolicies)
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    $intunePolicy = $MDMPolicies | Where-Object { $_.displayName -eq 'Microsoft Intune' }

    if ($intunePolicy -and ($intunePolicy.appliesTo -ne 'none')) {
        $passed = $true
        $testResultMarkdown = "Windows Automatic Enrollment is enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Windows Automatic Enrollment is not enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Automatic Enrollment"
    $tableRows = ""

    if ($intunePolicy) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | User Scope |
| :---------- | :--------- |
{1}

'@

        $policyName = $intunePolicy.displayName
        $portalLink = 'https://intune.microsoft.com/#view/Microsoft_AAD_IAM/MdmConfiguration.ReactView/appId/0000000a-0000-0000-c000-000000000000/appName/Microsoft%20Intune'

        switch ($intunePolicy.appliesTo) {
            'none' {
                $userScope = "❌ None"
            }
            'selected' {
                $userScope = "✅ Specific Groups"
            }
            'all' {
                $userScope = "✅ All Users"
            }
            default {
                $userScope = "⚠️ Unknown Scope"
            }
        }


        $tableRows = "| [$(Get-SafeMarkdown($policyName))]($portalLink) | $userScope |`n"
    }

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $tableRows

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24546'
        Title  = 'Windows Automatic Enrollment is enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
