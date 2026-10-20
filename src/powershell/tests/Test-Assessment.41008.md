The Local Administrator Password Solution randomizes the built-in local Administrator password on every domain-joined and Microsoft Entra-joined device, stores each password centrally in Active Directory or Microsoft Entra ID, and rotates it on a defined schedule so that no two devices share the same secret. Without it, organizations typically image every workstation from the same baseline and inherit a single local Administrator password across the fleet. A threat actor who compromises any one of those workstations can extract the local Administrator credential and replay it against every other device that accepts the same password — the classic Pass-the-Hash attack. Once a single jump host or privileged-access workstation falls, the same credential reaches servers that hold directory secrets, and the intrusion escalates from one endpoint to forest-wide credential theft and persistent administrative control. The argument that a uniform local password is acceptable because the accounts are local to each device collapses the moment one device is breached. Microsoft Defender for Identity's posture engine lists every monitored device that lacks a managed local Administrator password as a Secure Score recommendation, and the documented remediation is to deploy Windows LAPS — the in-box successor to legacy LAPS — to every Windows endpoint and confirm that each device reports a recently rotated managed password.

**Remediation action**

- [What is Windows LAPS?](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)
- [Get started with Windows LAPS for Active Directory](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-scenarios-windows-server-active-directory)
- [Manage Windows LAPS in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/howto-manage-local-admin-passwords)
- [Microsoft Defender for Identity security posture assessments](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment)

<!--- Results --->
%TestResult%
