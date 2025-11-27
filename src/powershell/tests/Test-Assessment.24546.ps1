
<#
.SYNOPSIS

#>



function Test-Assessment-24546 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
        MinimumLicense = ('Intune'),
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

    $activity = "Checking Windows Automatic Enrollment is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve Mobile Device Management Policies
    $MDMPoliciesUri = "policies/mobileDeviceManagementPolicies"

    try {
        # The policies/mobileDeviceManagementPolicies endpoint requires delegated permissions
        # and is not supported with application-only authentication (service principal)
        $MDMPolicies = Invoke-ZtGraphRequest -RelativeUri $MDMPoliciesUri -ApiVersion beta
    }
    catch {
        # Check if this is an authorization error
        $authType = (Get-MgContext).AuthType
        if ($_.Exception.Message -match "(Unauthorized|403|401)" -or $_.Exception.Message -match "Insufficient privileges") {
            if ($authType -eq 'AppOnly') {
                Write-PSFMessage -Level Warning -Message "Mobile Device Management policies could not be retrieved. The 'policies/mobileDeviceManagementPolicies' endpoint requires delegated permissions and is not supported with service principal authentication. This test will be marked as failed due to insufficient permissions."
            } else {
                Write-PSFMessage -Level Warning -Message "Mobile Device Management policies could not be retrieved due to insufficient permissions. Ensure the current user has the required permissions to access Mobile Device Management policies. This test will be marked as failed."
            }
        } else {
            # For other types of errors, log the full error
            Write-PSFMessage -Level Warning -Message "Failed to retrieve Mobile Device Management policies: $($_.Exception.Message). This test will be marked as failed."
        }

        # Set empty policies array to continue with test logic
        $MDMPolicies = @()
        Write-PSFMessage -Level Debug -Message "Continuing test evaluation with empty policy data"
    }

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
