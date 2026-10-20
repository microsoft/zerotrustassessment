Microsoft Threat Intelligence (MSTI) is the consolidated stream of indicators of compromise (IPs, domains, URLs, file hashes, certificates, email addresses) that Microsoft generates from its global signal set — Microsoft Defender Threat Intelligence (MDTI), Microsoft 365 Defender, Defender for Endpoint, Defender for Cloud, the Defender Experts hunting team, and partner contributions — and exposes to Sentinel through the Microsoft Threat Intelligence connector and the Defender Threat Intelligence connector. Once ingested, indicators land in the ThreatIntelligenceIndicator table and are matched in real time against ingested telemetry by the Microsoft-published TI Map analytics rules to surface high-fidelity matches against known-bad infrastructure. Without a TI feed integrated, Sentinel cannot perform indicator-matching detection: a threat actor leveraging tooled command-and-control infrastructure that Microsoft has already attributed walks past Sentinel because no rule joins ingested DNS/HTTP/TLS telemetry against a current indicator list. The same applies to phishing infrastructure, credential-harvest sites, and ransomware staging IPs. Integration is delivered through one of three documented connectors: the MicrosoftThreatIntelligence data connector (ingests Microsoft-curated indicators), the ThreatIntelligence (TIP) connector for Microsoft Graph Security TI Indicators API, or the ThreatIntelligenceTaxii connector for STIX/TAXII feeds.

**Remediation action**

- [Microsoft Sentinel threat intelligence overview](https://learn.microsoft.com/azure/sentinel/understand-threat-intelligence)
- [Connect Microsoft Defender Threat Intelligence to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-mdti-data-connector)
- [Connect threat intelligence platforms to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-threat-intelligence-tip)
- [Connect Microsoft Sentinel to STIX/TAXII threat intelligence feeds](https://learn.microsoft.com/azure/sentinel/connect-threat-intelligence-taxii)

<!--- Results --->
%TestResult%
