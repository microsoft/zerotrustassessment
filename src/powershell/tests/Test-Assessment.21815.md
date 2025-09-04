Threat actors target privileged accounts because they have access to the data and resources they want. This might include more access to your Microsoft Entra tenant, data in Microsoft SharePoint, or the ability to establish long-term persistence. Without a just-in-time (JIT) activation model, administrative privileges remain continuously exposed, providing attackers with an extended window to operate undetected. Just-in-time access mitigates risk by enforcing time-limited privilege activation with extra controls such as approvals, justification, and Conditional Access policy, ensuring that high-risk permissions are granted only when needed and for a limited duration. This restriction minimizes the attack surface, disrupts lateral movement, and forces adversaries to trigger actions that can be specially monitored and denied when not expected. Without just-in-time access, compromised admin accounts grant indefinite control, letting attackers disable security controls, erase logs, and maintain stealth, amplifying the impact of a compromise.

Use Microsoft Entra Privileged Identity Management (PIM) to provide time-bound just-in-time access to privileged role assignments. Use access reviews in Microsoft Entra ID Governance to regularly review privileged access to ensure continued need.

**Remediation action**

- [Start using Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create an access review of Azure resource and Microsoft Entra roles in PIM](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

