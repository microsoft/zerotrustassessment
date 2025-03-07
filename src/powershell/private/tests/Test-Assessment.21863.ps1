<#
.SYNOPSIS

#>

function Test-Assessment-21863{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "All high-risk sign-ins are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting risky sign ins."

    $filter = "riskState eq 'atRisk' and riskLevel eq 'high'"

    $riskDetections = Invoke-ZtGraphRequest -RelativeUri 'identityProtection/riskDetections' -Filter $filter

    # Determine pass/fail - pass if no untriaged risky users found
    $result = ($riskDetections.value.Count -eq 0)
    $passed = $result

    # Prepare the markdown output
    if ($result) {
        $testResultMarkdown = "No untriaged risky sign ins in the tenant.%TestResult%"
    }
    else {
        $testResultMarkdown = "Found **$($riskDetections.Count)** untriaged high-risk sign ins.%TestResult%"
    }

    # Build the detailed sections of the markdown
    $mdInfo = ""

    if (!$result) {
        $mdInfo += "`n## Untriaged High-Risk Sign ins`n`n"
        $mdInfo += "| Date | User Principal Name  | Type | Risk Level |`n"
        $mdInfo += "| :---- | :---- | :---- | :---- |`n"

        foreach ($risk in $riskDetections) {
            $userPrincipalName = $risk.userPrincipalName
            $riskLevel = Get-FormattedRiskLevel -RiskLevel $risk.riskLevel
            $riskEventType = $risk.riskEventType
            $riskDate = $risk.detectedDateTime # ID protection returns us format by default
            $mdInfo += "| $riskDate | $userPrincipalName |  $riskEventType | $riskLevel |`n"
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21863' -Title "All high-risk sign-ins are triaged" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
