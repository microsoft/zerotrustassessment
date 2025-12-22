Universal Continuous Access Evaluation (Universal CAE) is a platform feature of Global Secure Access that ensures network access tokens are validated every time a connection to a new application resource is established through GSA tunnels.

Without Universal CAE enabled, Global Secure Access tokens remain valid for 60-90 minutes regardless of changes to user state. A threat actor who obtains a GSA access token through theft or replay can continue accessing all GSA-protected network resources—including Private Access tunnels to internal servers, Remote Desktop sessions, file shares, and Internet Access tunnels to external SaaS applications—even after the user's account is disabled, password is reset, or an administrator explicitly revokes their sessions.

When critical events occur (user account deletion, password change, MFA enablement, session revocation, or high user risk detection), Universal CAE communicates these signals to Global Secure Access in near real-time, prompting immediate reauthentication. Without this capability, departing employees or malicious insiders maintain network-level access to private corporate resources and internet applications holding company data for up to 90 minutes after remediation actions are taken.

Universal CAE also enables Strict Enforcement mode, which blocks access when token replay is attempted from a different IP address than the original authentication, protecting against certain token theft scenarios. Unlike traditional CAE which requires each application to adopt special libraries and is limited to first-party Microsoft applications, Universal CAE extends these protections to any application accessed through Global Secure Access without requiring the application to be CAE-aware.

**Remediation action**
- [Review Universal CAE capabilities for Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-universal-continuous-access-evaluation)
- [Remove or modify Conditional Access policies that disable CAE for GSA workloads](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-continuous-access-evaluation#customize-continuous-access-evaluation)
- [Configure Strict Enforcement mode for enhanced token replay protection](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-universal-continuous-access-evaluation#strict-enforcement-mode)

<!--- Results --->
%TestResult%
