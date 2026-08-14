Identities and devices are the two pivot points of nearly every modern intrusion: a threat actor first compromises a user, enumerates Entra group memberships and device ownership for Discovery, and then chains lateral hops across managed devices for Lateral Movement before reaching a high-value target. Microsoft Security Copilot's Microsoft Entra and Microsoft Intune plugins surface, in natural language, the same identity and device context that analysts would otherwise gather by hand from Microsoft Graph — sign-in risk, role assignments, group membership, device compliance, OS version, and last sync — and condense it into the incident workspace. The plugins are only as useful as the underlying Graph data planes; if the Entra users, devices, or Intune managedDevices endpoints are unreachable for the assessment principal, or if Security Copilot itself is not provisioned, analysts revert to manual cross-portal navigation, mean-time-to-respond (MTTR) increases, and the threat actor's window for Collection and Exfiltration widens.

**Remediation action**

- [Get started with Security Copilot](https://learn.microsoft.com/copilot/security/get-started-security-copilot)
- [Manage plugins in Microsoft Security Copilot](https://learn.microsoft.com/copilot/security/manage-plugins)

<!--- Results --->
%TestResult%
