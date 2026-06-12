The Purview Information Protection connector brings sensitivity label events from the Microsoft 365 audit log into Microsoft Sentinel. For AI workloads, this makes it possible to determine whether classified content was involved in a Copilot or agent interaction by correlating label events with session activity. Without this connector, that correlation cannot run.

When the Purview Information Protection connector is not enabled, Sentinel has no record of sensitivity label events and cannot determine whether classified content was involved in a Copilot or agent interaction. Threat actors who direct Copilot toward highly classified documents through a compromised account can exploit this gap because the sensitivity dimension of the session is invisible to the SIEM — only the undifferentiated Copilot activity event reaches Sentinel. Without this connector, the organization cannot distinguish a session that processed public content from one that accessed Highly Confidential material, preventing any triage based on data classification.

**Remediation action**

- [Connect Microsoft Purview Information Protection to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-microsoft-purview)
- [Sensitivity labels overview](https://learn.microsoft.com/purview/sensitivity-labels)

<!--- Results --->
%TestResult%
