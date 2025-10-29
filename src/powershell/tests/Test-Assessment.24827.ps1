<#
.SYNOPSIS
    Unmanaged and unprotected Apps are restricted from Accessing Corporate Data
#>

function Test-Assessment-24827 {
    [ZtTest(
    	Category = 'Data',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24827,
    	Title = 'Conditional Access policies block access from unmanaged apps',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that unmanaged and unprotected Apps are restricted from Accessing Corporate Data"
    Write-ZtProgress -Activity $activity

    # Query 1: All
    $allCompliantAppCAPUri = "identity/conditionalAccess/policies?`$filter=state eq 'enabled' and grantControls/builtInControls/any(bc: bc eq 'compliantApplication') and conditions/platforms/includePlatforms/any(p: p eq 'iOS' or p eq 'android')&`$select=id,displayName,grantControls,conditions"
    $allCompliantAppCAP = Invoke-ZtGraphRequest -RelativeUri $allCompliantAppCAPUri -ApiVersion beta

    #region Assessment Logic
    $passed = ($allCompliantAppCAP.Where{$null -eq $_.conditions.platforms.includePlatforms}.Count -gt 0) -or ( # not platform filtered
        $allCompliantAppCAP.Where{$_.conditions.platforms.includePlatforms -contains 'android'}.Count -gt 0 -and # at least one android
        $allCompliantAppCAP.Where{$_.conditions.platforms.includePlatforms -contains 'iOS'}.Count -gt 0 # at least one iOS
    )

    if ($passed) {
        $testResultMarkdown = "At least one enabled conditional access policy with Application Protection exists for iOS and Android. The platforms could be part of same or different policy with the required grant control.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No conditional access policy with Application Protection exists for iOS and Android or both.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "iOS & Android Conditional Access Policies"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($allCompliantAppCAP.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Platforms |
| :---------- | :-------- |
{1}

'@

        foreach ($policy in $allCompliantAppCAP) {
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
        TestId             = '24827'
        Title              = "Unmanaged and unprotected Apps are restricted from Accessing Corporate Data"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
