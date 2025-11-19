# Convert the risk event type to human-readable format.
function Get-RiskEventTypeLabel {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Risk event type to format
        [string] $RiskEventType
    )

    process {
        if([System.String]::IsNullOrEmpty($RiskEventType)) {
            return $null
        }

        $riskEventTypeList = @{
            "riskyIPAddress" = "Activity from anonymous IP address"
            "generic" = "Additional risk detected (sign-in)"
            "adminConfirmedUserCompromised" = "Admin confirmed user compromised"
            "anomalousToken" = "Anomalous Token (sign-in)"
            "anonymizedIPAddress" = "Anonymous IP address"
            "unlikelyTravel" = "Atypical travel"
            "mcasImpossibleTravel" = "Impossible travel"
            "maliciousIPAddress" = "Malicious IP address"
            "mcasFinSuspiciousFileAccess" = "Mass Access to Sensitive Files"
            "investigationsThreatIntelligence" = "Microsoft Entra threat intelligence (sign-in)"
            "newCountry" = "New country"
            "passwordSpray" = "Password spray"
            "suspiciousBrowser" = "Suspicious browser"
            "suspiciousInboxForwarding" = "Suspicious inbox forwarding"
            "mcasSuspiciousInboxManipulationRules" = "Suspicious inbox manipulation rules"
            "tokenIssuerAnomaly" = "Token issuer anomaly"
            "unfamiliarFeatures" = "Unfamiliar sign-in properties"
            "nationStateIP" = "Verified threat actor IP"
        }

        return $riskEventTypeList[$RiskEventType]
    }
}
