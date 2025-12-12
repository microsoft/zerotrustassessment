If a macOS cloud LAPS (Local Administrator Password Solution) policy is not configured and assigned in Intune, local admin accounts on enrolled macOS devices may remain unmanaged, increasing the risk of unauthorized access, privilege escalation, and lateral movement by threat actors. Without enforced LAPS policies, organizations cannot ensure that admin account credentials are rotated, unique, and securely managed, exposing sensitive systems to potential compromise.

**Remediation Resources**

- [Configure macOS LAPS in Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/macos-laps)
- [depOnboardingSetting resource type - Microsoft Graph beta](https://learn.microsoft.com/en-us/graph/api/resources/intune-enrollment-deponboardingsetting?view=graph-rest-beta)

<!--- Results --->
%TestResult%
