When you configure Quick Access in Microsoft Entra Private Access without Conditional Access policies, threat actors who compromise user credentials gain unrestricted access to private resources. The Quick Access application serves as a container for private resources including FQDNs and IP addresses.

Without policy enforcement:

- Compromised accounts provide a direct pathway to internal systems.
- Threat actors operating from unmanaged devices or anomalous locations can access private resources indistinguishably from authorized users.
- Lateral movement across the internal network and data exfiltration from private applications become possible.
- Multifactor authentication requirements and device health checks can't be enforced.

**Remediation action**

- [Apply Conditional Access Policies to Microsoft Entra Private Access Apps](https://learn.microsoft.com/entra/global-secure-access/how-to-target-resource-private-access-apps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

