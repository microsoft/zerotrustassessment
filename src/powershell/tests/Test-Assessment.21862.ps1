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

    $activity = "Checking All risky workload identities are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting risky service principals"

    $riskyServicePrincipals = Invoke-ZtGraphRequest -RelativeUri "identityProtection/riskyServicePrincipals" -ApiVersion v1.0 -Filter "riskState eq 'atRisk'"

    Write-ZtProgress -Activity $activity -Status "Getting service principal risk detections"

    $servicePrincipalRiskDetections = (Get-Content C:\tmp\test1.json | ConvertFrom-Json).value
    #"Invoke-ZtGraphRequest -RelativeUri "identityProtection/servicePrincipalRiskDetections" -ApiVersion v1.0 -Filter "riskState eq 'atRisk'""

    $untriagedRiskyPrincipals = $riskyServicePrincipals | Where-Object { $_.riskState -eq 'atRisk' }
    $untriagedRiskDetections = $servicePrincipalRiskDetections | Where-Object { $_.riskState -eq 'atRisk' }

    $passed = ($untriagedRiskyPrincipals.Count -eq 0) -and ($untriagedRiskDetections.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "All risky workload identities have been triaged ✅"
    }
    else {
        $riskySPCount = $untriagedRiskyPrincipals.Count
        $riskyDetectionCount = $untriagedRiskDetections.Count
        $testResultMarkdown = "Found $riskySPCount untriaged risky service principals and $riskyDetectionCount untriaged risk detections ❌"

        if ($riskySPCount -gt 0) {
            $testResultMarkdown += "`n`n**Untriaged Risky Service Principals:**"
            foreach ($sp in $untriagedRiskyPrincipals) {
                $testResultMarkdown += "`n- **$($sp.displayName)** (ID: $($sp.id))"
                $testResultMarkdown += "`n  - Risk Level: $($sp.riskLevel)"
                $testResultMarkdown += "`n  - Risk State: $($sp.riskState)"
                $testResultMarkdown += "`n  - Last Updated: $($sp.riskLastUpdatedDateTime)"
            }
        }

        if ($riskyDetectionCount -gt 0) {
            $testResultMarkdown += "`n`n**Untriaged Risk Detections Events:**"
            foreach ($detection in $untriagedRiskDetections) {
                $testResultMarkdown += "`n- **Service Principal:** $($detection.servicePrincipalDisplayName)"
                $testResultMarkdown += "`n  - Risk Level: $($detection.riskLevel)"
                $testResultMarkdown += "`n  - Risk Event Type: $($detection.riskEventType)"
                $testResultMarkdown += "`n  - Detected: $($detection.detectedDateTime)"
            }
        }
    }

    $result = $passed


    Add-ZtTestResultDetail -TestId '21862' -Title "All risky workload identities are triaged" `
        -UserImpact Low -Risk Medium -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
