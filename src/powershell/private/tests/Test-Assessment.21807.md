If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.

If these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.

Attackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.

**Remediation action**

- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

