Most enterprise estates run workloads outside Microsoft control planes — AWS accounts, Google Cloud projects, on-premises Linux/Windows servers emitting Syslog/CEF, third-party identity providers (Okta), endpoint security stacks (CrowdStrike, SentinelOne), email security gateways (Proofpoint, Mimecast), network appliances (Palo Alto Networks, Fortinet, Cisco ASA/FTD), CASBs, and SaaS audit logs. When these sources are not connected to Sentinel, the SIEM has a one-sided view of the kill chain: Sentinel can detect a Microsoft Entra sign-in but cannot see the preceding AWS IAM CreateAccessKey, the on-premises Linux SSH brute force, the perimeter firewall command-and-control beacon, or the third-party EDR malware detonation that precedes lateral movement. Threat actors operate end-to-end across Microsoft and non-Microsoft surfaces, and a SIEM that ignores the non-Microsoft surface produces detection-blind windows large enough for a full intrusion lifecycle to complete. Sentinel exposes built-in third-party connectors (AmazonWebServicesS3, GCP, Syslog/CEF, Okta SSO, codeless connectors for SaaS APIs) precisely so the SIEM can correlate identity, endpoint, network, and cloud events across the customer's full estate.

**Remediation action**

- [Connect AWS to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-aws)
- [Connect GCP to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-google-cloud-platform)
- [Collect Syslog/CEF logs](https://learn.microsoft.com/azure/sentinel/connect-cef-syslog-ama)
- [Find your Microsoft Sentinel data connector](https://learn.microsoft.com/azure/sentinel/data-connectors-reference)

<!--- Results --->
%TestResult%
