When Microsoft 365 traffic bypasses Global Secure Access, organizations lose visibility and control over their most critical productivity workloads. Threat actors exploiting unmonitored Microsoft 365 connections can exfiltrate sensitive data through SharePoint, OneDrive, or Exchange without triggering security policies or generating actionable telemetry.

Token theft and replay attacks become more difficult to detect when traffic does not flow through the Security Service Edge, as source IP correlation with sign-in logs and Conditional Access evaluation cannot be applied consistently.

Organizations with significant bypassed traffic—whether due to incomplete client deployment, misconfigured forwarding profiles, or users on unmanaged devices—create blind spots where adversary-in-the-middle attacks, credential harvesting, and unauthorized data transfers can proceed undetected. Traffic that bypasses Global Secure Access also cannot benefit from compliant network checks in Conditional Access policies, tenant restrictions, or source IP restoration—leaving significant security controls ineffective.

## Remediation Steps

1. **Enable Microsoft 365 traffic profile**
   - Navigate to Global Secure Access > Connect > Traffic forwarding
   - Enable the Microsoft 365 traffic forwarding profile
   - [Learn more about managing Microsoft 365 profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-microsoft-profile)

2. **Deploy Global Secure Access client**
   - Install the Global Secure Access client on all managed Windows endpoints
   - Ensure client is configured to connect automatically
   - [Learn more about deploying the Windows client](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-windows-client)

3. **Review traffic forwarding rules**
   - Verify Microsoft 365 workloads are included in the forwarding profile
   - Check for any exclusions that may be bypassing critical traffic
   - [Learn more about Microsoft 365 traffic profile](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-microsoft-traffic-profile)
