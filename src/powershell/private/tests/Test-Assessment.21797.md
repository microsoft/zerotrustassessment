Assume any users at high risk are compromised by threat actors. Without investigation and remediation, threat actors can execute scripts, deploy malicious applications, or manipulate API calls to establish persistence, based on the potentially compromised user's permissions. Threat actors can then exploit misconfigurations or abuse OAuth tokens to move laterally across workloads like documents, SaaS applications, or Azure resources. Threat actors can gain access to sensitive files, customer records, or proprietary code and exfiltrate it to external repositories while maintaining stealth through legitimate cloud services. Finally, threat actors might disrupt operations by modifying configurations, encrypting data for ransom, or using the stolen information for further attacks, resulting in financial, reputational, and regulatory consequences.

**Remediation action**

- [Require a secure password change for elevated user risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Investigate risk](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

