<#
.SYNOPSIS

#>

function Test-Assessment-21824 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 21824,
    	Title = 'Guests don''t have long lived sign-in sessions',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guests don't have long lived sign-in sessions"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query for CA policies that are enabled and include guests or external users
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion 'v1.0'

    $filteredCAPolicies = $allCAPolicies | Where-Object {
        ($null -ne $_.conditions.users.includeGuestsOrExternalUsers) -and
        ($_.state -in @('enabled', 'enabledForReportingButNotEnforced')) -and
        ($null -eq $_.grantControls.termsOfUse -or $_.grantControls.termsOfUse.Count -eq 0) # Exclude Terms of Use policies
    }

    # Local filtering - validate sign-in frequency for guest sessions
    $matchedPolicies = $filteredCAPolicies | Where-Object {
        $signInFrequency = $_.sessionControls.signInFrequency
        if ($signInFrequency -and $signInFrequency.isEnabled) {
            ($signInFrequency.type -eq 'hours' -and $signInFrequency.value -le 24) -or
            ($signInFrequency.type -eq 'days' -and $signInFrequency.value -eq 1) -or
            ($null -eq $signInFrequency.type -and $signInFrequency.frequencyInterval -eq 'everyTime')
        }
        else {
            $false
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    if ($filteredCAPolicies.Count -eq $matchedPolicies.Count) {
        $passed = $true
        $testResultMarkdown = "Guests don't have long lived sign-in sessions.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "Guests do have long lived sign-in sessions.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Sign-in frequency policies"
    $tableRows = ""

    if ($filteredCAPolicies -and $filteredCAPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Sign-in Frequency | Status |
| :---------- | :---------------- | :----- |
{1}

'@

        foreach ($filteredCAPolicy in $filteredCAPolicies) {

            $policyName = $filteredCAPolicy.DisplayName

            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}' -f $filteredCAPolicy.Id

            $signInFrequency = $filteredCAPolicy.sessionControls.signInFrequency
            switch ($signInFrequency.type) {
                'hours' {
                    $signInFreqValue = "{0} hours" -f $signInFrequency.value
                }
                'days' {
                    $signInFreqValue = "{0} days" -f $signInFrequency.value
                }
                default {
                    if ($signInFrequency.frequencyInterval -eq 'everyTime') {
                        $signInFreqValue = "Every time"
                    }
                    else {
                        $signInFreqValue = "Not configured"
                    }
                }
            }

            $status = if ($matchedPolicies -and $matchedPolicies.Id -contains $filteredCAPolicy.Id) {
                "✅"
            }
            else {
                "❌"
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($policyName))]($portalLink) | $signInFreqValue | $status |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21824'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
