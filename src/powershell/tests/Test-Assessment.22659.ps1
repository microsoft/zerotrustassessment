<#
.SYNOPSIS
    Checks if all risky workload identities are triaged
#>

function Test-Assessment-22659 {
    [ZtTest(
        Category = 'Access control',
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

    $activity = 'Checking risky workload identity sign-in detections'
    Write-ZtProgress -Activity $activity -Status 'Getting risky service principal sign-in detections'

    # Query for all risky service principal risk detections
    $allRiskDetections = Invoke-ZtGraphRequest -RelativeUri 'identityProtection/servicePrincipalRiskDetections' -ApiVersion 'v1.0'

    # Filter client-side for signIn activity and atRisk state
    $riskySignInDetections = $allRiskDetections | Where-Object {
        $_.activity -eq 'signIn' -and $_.riskState -eq 'atRisk'
    }

    $passed = ($riskySignInDetections.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = 'All risky workload identity sign-ins have been triaged and resolved.'
    } else {
        $testResultMarkdown = 'Found risky workload identities sign-ins that require triage.`n`n'
        $testResultMarkdown += '## Untriaged Risky Workload Identity Sign-Ins`n`n'
        $testResultMarkdown += '| Service Principal Display Name | App ID | Risk State | Risk Level | Last Updated |`n'
        $testResultMarkdown += '| :--- | :--- | :--- | :--- | :--- |`n'
        foreach ($detection in $riskySignInDetections) {
            $testResultMarkdown += "| $($detection.displayName) | $($detection.appId) | $($detection.riskState) | $($detection.riskLevel) | $($detection.riskLastUpdatedDateTime) |`n"
        }
        $testResultMarkdown += '`n**Remediation Resources:**`n'
        $testResultMarkdown += '- [Investigate risky workload identities and perform appropriate remediation](https://learn.microsoft.com/en-us/entra/id-protection/concept-workload-identity-risk)`n'
        $testResultMarkdown += '- [Dismiss workload identity risks when determined to be false positives](https://learn.microsoft.com/en-us/graph/api/riskyserviceprincipal-dismiss?view=graph-rest-1.0)`n'
        $testResultMarkdown += '- [Confirm compromised workload identities when risks are validated](https://learn.microsoft.com/en-us/graph/api/riskyserviceprincipal-confirmcompromised?view=graph-rest-1.0)`n'
    }

    $params = @{
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
