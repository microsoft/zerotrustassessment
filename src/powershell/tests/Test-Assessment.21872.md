Threat actors can exploit the lack of multifactor authentication during new device registration. Once authenticated, they can register rogue devices, establish persistence, and circumvent security controls tied to trusted endpoints. This foothold enables attackers to exfiltrate sensitive data, deploy malicious applications, or move laterally, depending on the permissions of the accounts being used by the attacker. Without MFA enforcement, risk escalates as adversaries can continuously reauthenticate, evade detection, and execute objectives.

**Remediation action**

- [Deploy a Conditional Access policy to require multifactor authentication for device registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

