



<#
.SYNOPSIS

#>

function Test-Assessment-22659{
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 22659,
    	Title = 'All risky workload identity sign-ins are triaged',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking risky workload identity sign-ins'
    Write-ZtProgress -Activity $activity -Status 'Getting risky sign-in detections'

    # Get risky service principal sign-in detections
    $riskDetections = @()
    try {
        $response = Invoke-ZtGraphRequest -RelativeUri 'identityProtection/servicePrincipalRiskDetections' -ApiVersion 'beta'
        $riskDetections = $response.value | Where-Object {
            $_.activity -eq 'signIn' -and $_.riskState -eq 'atRisk'
        }
    }
    catch {
        Write-PSFMessage 'Failed to get service principal risk detections' -Level Warning -ErrorRecord $_
        return $false
    }

    $result = $riskDetections.Count -eq 0

    $testResultMarkdown = ''
    if ($result) {
        $testResultMarkdown = @"
✅ All risky workload identity sign-ins have been triaged and resolved.
"@
    }
    else {
        $testResultMarkdown = @"
❌ Found risky workload identities sign-ins that require triage.

%TestResult%

"@
    }

    # Create detailed table information if there are risky detections
    $mdInfo = ''
    if ($riskDetections) {
        $tableRows = ''
        $reportTitle = "Risky Workload Identity Sign-ins"

        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Service Principal | App ID | Risk State | Risk Level | Last Updated |
| :---------------- | :----- | :--------- | :--------- | :----------- |
{1}

'@

        foreach ($detection in $riskDetections) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}' -f $detection.servicePrincipalId, $detection.appId
            $tableRows += @"
| [$(Get-SafeMarkdown($detection.servicePrincipalDisplayName))]($portalLink) | $($detection.appId) | $($detection.riskState) | $($detection.riskLevel) | $(Get-FormattedDate($detection.riskLastUpdatedDateTime)) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $passed = $result
    Add-ZtTestResultDetail `
        -TestId '22659' `
        -Status $passed `
        -Result $testResultMarkdown
}
