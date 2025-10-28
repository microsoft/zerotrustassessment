<#
.SYNOPSIS
    Checks if all risky workload identities are triaged
#>

function Test-Assessment-21862{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21862,
    	Title = 'All risky workload identities are triaged',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if( -not (Get-ZtLicense EntraWorkloadID) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraWorkloadID
        return
    }

    $activity = "Checking All risky workload identities are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting risky service principals"

    $untriagedRiskyPrincipals = Invoke-ZtGraphRequest -RelativeUri "identityProtection/riskyServicePrincipals" -ApiVersion v1.0 -Filter "riskState eq 'atRisk'"

    Write-ZtProgress -Activity $activity -Status "Getting service principal risk detections"

    $servicePrincipalRiskDetections = Invoke-ZtGraphRequest -RelativeUri "identityProtection/servicePrincipalRiskDetections" -ApiVersion v1.0 -Filter "riskState eq 'atRisk'"

    $untriagedRiskDetections = $servicePrincipalRiskDetections | Where-Object { $_.riskState -eq 'atRisk' }

    $passed = ($untriagedRiskyPrincipals.Count -eq 0) -and ($untriagedRiskDetections.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "All risky workload identities have been triaged"
    }
    else {
        $riskySPCount = $untriagedRiskyPrincipals.Count
        $riskyDetectionCount = $untriagedRiskDetections.Count
        $testResultMarkdown = "Found $riskySPCount untriaged risky service principals and $riskyDetectionCount untriaged risk detections"

        if ($riskySPCount -gt 0) {
            $testResultMarkdown += "`n`n## Untriaged Risky Service Principals`n`n"
            $testResultMarkdown += "| Service Principal | Type | Risk Level | Risk State | Risk Last Updated |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- |`n"
            foreach ($sp in $untriagedRiskyPrincipals) {
                $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/$($sp.id)/appId/$($sp.appId)"
                $testResultMarkdown += "| [$($sp.displayName)]($portalLink) | $($sp.servicePrincipalType) | $(Get-FormattedRiskLevel -RiskLevel $sp.riskLevel) | $(Get-RiskStateLabel -RiskState $sp.riskState) | $($sp.riskLastUpdatedDateTime) |`n"
            }
        }

        if ($riskyDetectionCount -gt 0) {
            $testResultMarkdown += "`n`n## Untriaged Risk Detection Events`n`n"
            $testResultMarkdown += "| Service Principal | Risk Level | Risk State | Risk Event Type | Risk Last Updated |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- |`n"
            foreach ($detection in $untriagedRiskDetections) {
                $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/$($detection.servicePrincipalId)/appId/$($detection.appId)"
                $testResultMarkdown += "| [$($detection.servicePrincipalDisplayName)]($portalLink) | $(Get-FormattedRiskLevel -RiskLevel $detection.riskLevel) | $(Get-RiskStateLabel -RiskState $detection.riskState) | $(Get-RiskEventTypeLabel -RiskEventType $detection.riskEventType) | $($detection.detectedDateTime) |`n"
            }
        }
    }

    Add-ZtTestResultDetail -Status $passed -Result $testResultMarkdown
}
