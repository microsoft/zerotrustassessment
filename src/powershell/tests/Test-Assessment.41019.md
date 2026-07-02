When Microsoft Defender for Identity raises an alert that a user account has been compromised — for example through Pass-the-Hash, Pass-the-Ticket, suspicious sign-in from an exposed credential, or stolen access — the account stays under the threat actor's control until it is disabled, its password is reset, and any active sessions are revoked. While the account remains active, the threat actor can continue lateral movement to sensitive servers, request additional Kerberos tickets, dump credentials from more endpoints, and persist by registering a new authentication method or creating a mail forwarding rule. Microsoft Defender for Identity flags the impacted user and surfaces containment actions in Microsoft Defender XDR; this check confirms there are no open identity alerts whose subject account has not yet been remediated, so the kill chain is closed at the credential stage rather than allowed to advance to data access.

**Remediation action**

- [Investigate identities in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/investigate-users)
- [Microsoft Defender for Identity remediation actions](https://learn.microsoft.com/en-us/defender-for-identity/remediation-actions)
- [Investigate alerts in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/investigate-alerts)
- [Investigate risk with Microsoft Entra ID Protection](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-investigate-risk)

<!--- Results --->
%TestResult%
