Without proper activation alerts configured for highly privileged roles, organizations lack visibility into when these roles are being exercised. Threat actors who gain initial access through compromised accounts or insider threats can exploit this lack of monitoring to perform privilege escalation by activating highly privileged roles without detection. Once threat actors successfully activate privileged roles undetected, they can establish persistence through creation of additional administrative accounts, modification of security policies, or deployment of backdoors across the environment. The absence of real-time alerting enables threat actors to conduct lateral movement using elevated privileges to access sensitive systems, modify audit configurations, or disable security controls without triggering immediate response procedures. Finally, threat actors achieve impact through unauthorized access to sensitive data, deployment of ransomware with administrative privileges, or complete compromise of the identity infrastructure while evading detection due to insufficient monitoring of privileged role activations.

**Remediation action**

Configure notifications for privileged roles
- [Configure Microsoft Entra role settings in Privileged Identity Management (PIM)](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings#require-justification-on-active-assignment)
<!--- Results --->
%TestResult%
