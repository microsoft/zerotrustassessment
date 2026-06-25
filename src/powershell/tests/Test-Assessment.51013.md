When App Protection Policies (MAM) do not act on a user authentication failure, an employee who has been off-boarded — or a user whose account has been disabled by Identity Protection due to high risk, blocked by Conditional Access, or whose refresh token has been revoked — can continue to read corporate email in Outlook, access files in OneDrive, and participate in Teams chats from their personal phone for an extended window until the auth token cached by the managed app expires (which can be hours or days). Threat actors who compromise an account, off-boarded staff who keep their personal device, or users whose token was revoked after a security incident can use that residual access to exfiltrate corporate data, forward sensitive mail, or screenshot Teams conversations long after the account is supposed to be locked out. The MAM `appActionIfUnableToAuthenticateUser` setting closes this window by instructing managed apps to either block access immediately or wipe corporate data the next time the app tries to refresh the user's auth token and the refresh fails — the precise condition that occurs when an Entra ID account is disabled, blocked by Conditional Access, or has had its tokens revoked. Without an App Protection Policy that sets this action to `block` or `wipe` on both iOS and Android, the off-boarding and token-revocation control plane has a multi-hour blind spot on every personally owned phone in the estate.

**Remediation action**

- [App protection policies overview](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [iOS app protection policy settings: Conditional launch](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios)
- [Android app protection policy settings: Conditional launch](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)
- [Create and assign app protection policies](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
- [Wipe corporate data from Intune-managed apps](https://learn.microsoft.com/en-us/intune/intune-service/apps/apps-selective-wipe)

<!--- Results --->
%TestResult%
