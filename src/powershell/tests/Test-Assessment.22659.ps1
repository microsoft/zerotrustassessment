



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
    $details = [System.Collections.ArrayList]::new()

    if ($riskDetections) {
        foreach ($detection in $riskDetections) {
            [void]$details.Add("Service Principal: $($detection.servicePrincipalDisplayName)")
            [void]$details.Add("- App ID: $($detection.appId)")
            [void]$details.Add("- Risk State: $($detection.riskState)")
            [void]$details.Add("- Risk Level: $($detection.riskLevel)")
            [void]$details.Add("- Last Updated: $($detection.riskLastUpdatedDateTime)")
            [void]$details.Add("")
        }
    }

    $testResultMarkdown = ''
    if ($result) {
        $testResultMarkdown = @"
✅ All risky workload identity sign-ins have been triaged and resolved.
"@
    }
    else {
        $testResultMarkdown = @"
❌ Found risky workload identities sign-ins that require triage.

$($details -join "`n")

"@
    }

    $passed = $result
    Add-ZtTestResultDetail `
        -TestId '22659' `
        -Status $passed `
        -Result $testResultMarkdown
}
