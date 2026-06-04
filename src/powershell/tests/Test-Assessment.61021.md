The Microsoft 365 Copilot data connector brings Copilot activity logs into Microsoft Sentinel, including which prompts were issued, what grounding sources were consulted, and what responses were returned. This enables analysts to correlate Copilot sessions with identity and sensitivity label signals to determine whether Copilot was part of a security event. This check verifies the connector is enabled on at least one Sentinel-onboarded workspace.

When the Microsoft 365 Copilot connector is not enabled, Sentinel has no record of Copilot prompts, grounding sources consulted, or responses returned. Threat actors who have compromised a user account can exploit this gap because Copilot-assisted reconnaissance — rapidly enumerating and summarizing sensitive documents across the user's scope — leaves no trace in any Sentinel table. Without this connector, the organization cannot correlate a Copilot session with concurrent Entra sign-in anomalies or Purview label events, making it impossible to determine whether Copilot was part of an attack.

**Remediation action**

- [Connect the Microsoft 365 Copilot data connector](https://learn.microsoft.com/azure/sentinel/data-connectors-reference)
- [Auditing Microsoft 365 Copilot interactions](https://learn.microsoft.com/purview/audit-copilot)
- [Microsoft Sentinel data connectors reference](https://learn.microsoft.com/azure/sentinel/data-connectors-reference)

<!--- Results --->
%TestResult%
