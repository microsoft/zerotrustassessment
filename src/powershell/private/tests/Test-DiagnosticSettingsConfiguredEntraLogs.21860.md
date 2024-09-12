Logging and archiving Microsoft Entra logs helps detect unauthorized access attempts. These logs enable security teams to implement monitoring and detection security controls, proactively hunt for threats, respond to incidents, provide evidence for compliance and audits, assess system health, and other functions. This archival process is usually managed using a Security Information and Event Management (SIEM) system.

Without archived logs, it's challenging to identify and investigate how an attacker gained initial access. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, indicators of compromise, and other risks. This lack of visibility can prevent the timely detection of breaches, which can allow attackers to maintain undetected access for extended periods.

#### Remediation

- Deploy conditional access policies to enforce authentication strength for guests  
- [Overview of Microsoft Entra authentication strength](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)
- [Conditional Access - Authentication strength for external users](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-authentication-strength-external)
- For organizations with a closer business relationship and vetting on their MFA practices, consider deploying cross-tenant access settings to accept the MFA claim  
- [Configure B2B collaboration cross-tenant access](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration)

<!--- Results --->
%TestResult%
