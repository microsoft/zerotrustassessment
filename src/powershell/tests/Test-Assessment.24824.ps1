<#
.SYNOPSIS
    Non-compliant Devices are Restricted from Accessing Corporate Data
#>

function Test-Assessment-24824 {
    [ZtTest(
    	Category = 'Data',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24824,
    	Title = 'Conditional Access policies block access from noncompliant devices',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that Non-compliant Devices are Restricted from Accessing Corporate Data "
    Write-ZtProgress -Activity $activity

    # Query 1: All
    $allCompliantDeviceCAPUri = "identity/conditionalAccess/policies?`$filter=state eq 'enabled' and grantControls/builtInControls/any(bc: bc eq 'compliantDevice')&`$select=id,displayName,grantControls,conditions"
    $allCompliantDeviceCAP = Invoke-ZtGraphRequest -RelativeUri $allCompliantDeviceCAPUri -ApiVersion beta

    #region Assessment Logic
    $passed = ($allCompliantDeviceCAP.Where{$null -eq $_.conditions.platforms.includePlatforms}.Count -gt 0) -or ( # not platform filtered
        $allCompliantDeviceCAP.Where{$_.conditions.platforms.includePlatforms -contains 'android'}.Count -gt 0 -and # at least one android
        $allCompliantDeviceCAP.Where{$_.conditions.platforms.includePlatforms -contains 'iOS'}.Count -gt 0 -and # at least one iOS
        $allCompliantDeviceCAP.Where{$_.conditions.platforms.includePlatforms -contains 'macOS'}.Count -gt 0 -and # at least one Windows
        $allCompliantDeviceCAP.Where{$_.conditions.platforms.includePlatforms -contains 'windows'}.Count -gt 0# at least one Windows
    )

    if ($passed) {
        $testResultMarkdown = "At least one enabled conditional access policy with device compliance exists for each platform (Windows, macOS, iOS, Android), or a policy exists with no platform section (applies to all).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No conditional access policy with device compliance exists for one or more platforms, and no policy applies to all platforms.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Conditional Access Policies with Device Compliance"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($allCompliantDeviceCAP.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Platforms |
| :---------- | :-------- |
{1}

'@

        foreach ($policy in $allCompliantDeviceCAP) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'
            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $platformFilter = 'All Platforms'
            if ($null -ne $policy.conditions.platforms.includePlatforms) {
                $platformFilter = ($policy.conditions.platforms.includePlatforms -join ', ')
            }

            $tableRows += @"
| [$policyName]($portalLink) | $platformFilter |
"@
        }

         # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24824'
        Title              = "Non-compliant Devices are Restricted from Accessing Corporate Data "
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
