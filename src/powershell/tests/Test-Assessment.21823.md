When guest self-service sign-up is enabled, threat actors can exploit this functionality to establish unauthorized initial access by creating legitimate guest accounts without requiring invitation approval from authorized personnel. Adversaries may create accounts that only have access to specific services, which can reduce the chance of detection, effectively bypassing traditional invitation-based controls that validate external user legitimacy.

Once threat actors successfully create these self-provisioned guest accounts, they gain persistent access to organizational resources and applications, enabling them to conduct reconnaissance activities to map internal systems, identify sensitive data repositories, and enumerate additional attack vectors within the tenant.  
The persistence tactic allows adversaries to maintain their foothold across restarts, changed credentials, and other interruptions that could cut off their access, while the guest account provides a seemingly legitimate identity that may evade detection by security monitoring systems focused on suspicious external access attempts.

Furthermore, threat actors can leverage these compromised guest identities to establish credential persistence and potentially escalate privileges by exploiting trust relationships between guest accounts and internal resources, or by using the guest account as a staging ground for lateral movement attacks against more privileged organizational assets. 

**Remediation action**
- [Configure guest self-service sign-up With Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-self-service-sign-up)<!--- Results --->
%TestResult%
