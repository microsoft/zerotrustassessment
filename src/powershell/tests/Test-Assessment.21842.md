Self-Service Password Reset (SSPR) for administrators allows password changes to happen without strong secondary authentication factors or administrative oversight. Threat actors who compromise administrative credentials can use this capability to bypass other security controls and maintain persistent access to the environment.

Once compromised, attackers can immediately reset the password to lock out legitimate administrators. They can then establish persistence, escalate privileges, and deploy malicious payloads undetected.

**Remediation action**

- [Disable SSPR for administrators by updating the authorization policy](https://learn.microsoft.com/entra/identity/authentication/concept-sspr-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#administrator-reset-policy-differences)  
<!--- Results --->
%TestResult%

