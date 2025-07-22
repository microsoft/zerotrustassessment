When guest self-service sign-up is enabled, threat actors can exploit it to establish unauthorized access by creating legitimate guest accounts without requiring approval from authorized personnel. These accounts can be scoped to specific services to reduce detection and effectively bypass invitation-based controls that validate external user legitimacy.

Once created, self-provisioned guest accounts provide persistent access to organizational resources and applications. Threat actors can use them to conduct reconnaissance activities to map internal systems, identify sensitive data repositories, and plan further attack vectors. This persistence allows adversaries to maintain access across restarts, credential changes, and other interruptions, while the guest account itself offers a seemingly legitimate identity that might evade security monitoring focused on external threats.

Additionally, compromised guest identities can be used to establish credential persistence and potentially escalate privileges. Attackers can exploit trust relationships between guest accounts and internal resources, or use the guest account as a staging ground for lateral movement toward more privileged organizational assets.

**Remediation action**
- [Configure guest self-service sign-up With Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-self-service-sign-up)<!--- Results --->
%TestResult%

