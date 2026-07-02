A threat actor who registers a domain that looks like the customer's domain, or who spoofs the From address of an executive, can deliver a payment-redirection or credential-harvesting message that bypasses standard sender authentication checks. Without impersonation protection turned on, the recipient sees a familiar name, opens the message, follows the link, and either submits credentials or approves a wire transfer. The Microsoft Defender for Office 365 anti-phishing policy provides user impersonation protection for named high-value users, domain impersonation protection for the customer's own and partner domains, mailbox intelligence that learns each recipient's normal contacts, and spoof intelligence that enforces SPF, DKIM, and DMARC outcomes. Impersonation lists should include board members, executives, finance, and key partners. This check confirms that at least one enabled anti-phishing policy is configured beyond the defaults with impersonation and spoof controls so these techniques are blocked at the front door.

**Remediation action**

To configure an anti-phishing policy with impersonation and spoof protection:
1. Sign in to [Microsoft 365 Defender](https://security.microsoft.com) as a Global Administrator or Security Administrator.
2. Navigate to **Email & collaboration > Policies & rules > Threat policies > Anti-phishing**.
3. Select an existing custom policy or click **Create** to add a new one.
4. Under **Phishing threshold & protection**, enable **Spoof intelligence**, **Mailbox intelligence**, and **Mailbox intelligence protection**.
5. Enable **Enable users to protect** and add key executives, board members, and finance users to the protected user list.
6. Enable **Enable domains to protect**, include your own domains, and optionally add partner domains.
7. Set **Phishing email threshold** to **2 - Aggressive** (Standard) or **3 - More aggressive** (Strict).
8. Set all quarantine actions (spoof, impersonation, mailbox intelligence) to **Quarantine** and select the **AdminOnlyAccessPolicy** quarantine policy.
9. Enable **Apply DMARC policy** and set **DMARC quarantine action** to **Quarantine** and **DMARC reject action** to **Reject**.
10. Assign the policy to recipients via an enabled rule.

- [Anti-phishing protection in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/anti-phishing-protection-about)
- [Configure anti-phishing policies in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/anti-phishing-policies-mdo-configure)
- [Recommended settings for anti-phishing policies](https://learn.microsoft.com/en-us/defender-office-365/recommended-settings-for-eop-and-office365#anti-phishing-policy-settings-in-microsoft-defender-for-office-365)
- [Spoof intelligence insight](https://learn.microsoft.com/en-us/defender-office-365/anti-spoofing-spoof-intelligence)
- [Set-AntiPhishPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-antiphishpolicy)

<!--- Results --->
%TestResult%
