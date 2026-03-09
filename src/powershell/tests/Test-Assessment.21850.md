When the smart lockout threshold is set to more than 10, threat actors can exploit the configuration to conduct reconnaissance, identify valid user accounts without triggering lockout protections, and establish initial access without detection. Once attackers gain initial access, they can move laterally through the environment by using the compromised account to access resources and escalate privileges.

Smart lockout helps lock out bad actors who try to guess your users' passwords or use brute force methods to get in. Smart lockout recognizes sign-ins that come from valid users and treats them differently than ones of attackers and other unknown sources. A threshold of more than 10 provides insufficient protection against automated password spray attacks, making it easier for threat actors to compromise accounts while evading detection mechanisms. 

**Remediation action**

- [Set Microsoft Entra smart lockout threshold to 10 or less](https://learn.microsoft.com/entra/identity/authentication/howto-password-smart-lockout?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

