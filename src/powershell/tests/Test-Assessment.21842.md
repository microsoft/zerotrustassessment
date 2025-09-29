## Risk Explanation

When administrators retain access to Self-Service Password Reset (SSPR), threat actors who compromise administrative credentials can leverage this capability to bypass additional security controls and maintain persistent access to the environment. An administrative account with SSPR enabled creates a privileged pathway that allows password changes without requiring secondary authentication factors or administrative oversight, enabling lateral movement across critical systems. If threat actors obtain initial access to an administrative account through credential stuffing, phishing, or password spraying attacks, they can immediately reset the compromised account's password to prevent legitimate administrators from regaining control while establishing persistence through additional backdoor accounts or privileged role assignments. This autonomy in password management eliminates the security checkpoint that centralized password reset procedures provide, allowing threat actors to operate undetected while they escalate privileges, exfiltrate sensitive data, and deploy additional malicious payloads across the organization's infrastructure.

## Remediation Resources

- Disable SSPR for administrators by updating the authorization policy.
- Administrator reset policy differences: [Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-policy#administrator-reset-policy-differences)

<!--- Results --->
%TestResult%
