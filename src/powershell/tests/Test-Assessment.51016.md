The Intune Administrator role grants tenant-wide write access to every device-management surface — compliance policies, app deployment, device wipes, RBAC roles, automatic enrollment, and security baselines — so a single compromised assignment is sufficient to weaponise the entire managed fleet. When the role is granted as a permanent active assignment (instead of via Microsoft Entra Privileged Identity Management (PIM) eligibility), every credential-theft event against a privileged admin is an immediate path to full tenant compromise: the threat actor does not need to wait for an elevation prompt, request approval, or re-authenticate to begin wiping devices, pushing malicious apps to every enrolled endpoint, or escalating other accounts into the role. PIM disrupts this kill chain by enforcing that the role is held as eligible, not active: the admin must explicitly request activation each time, the activation gate requires re-authentication (typically MFA + justification + time-bounded window), every activation is logged for security review, and stolen long-lived tokens cannot exercise the privilege without going through the activation step. Without PIM coverage on the Intune Administrator role, the entire tenant control plane sits behind nothing more than the admin's password and the prevailing Conditional Access posture — a posture that does not survive token theft, session-cookie replay, or phishing-resistant MFA bypass via attacker-in-the-middle.

**Remediation action**

- [What is Microsoft Entra Privileged Identity Management?](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Assign Microsoft Entra roles in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-add-role-to-user)
- [Configure Microsoft Entra role settings in PIM (activation rules)](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings)
- [Intune Administrator role permissions](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference#intune-administrator)
- [Role-based access control with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control)
- [Manage emergency access accounts in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)

<!--- Results --->
%TestResult%
