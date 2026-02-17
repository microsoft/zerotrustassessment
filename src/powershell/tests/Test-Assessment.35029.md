Mail flow rules (transport rules) in Exchange Online allow organizations to automatically apply information protection policies to email messages based on conditions such as sender, recipient, content patterns, or organizational attributes. When mail flow rules with rights protection are not configured, organizations must rely solely on users to manually apply sensitivity labels or encrypt messages—a approach that is inconsistent, error-prone, and does not scale. Without automated rights protection rules, sensitive emails are frequently sent unencrypted, allowing unauthorized access, forwarding, and printing of confidential information. Rights protection rules automatically apply encryption, restriction labels, and permissions to messages matching specific criteria (e.g., emails to external domains, messages containing credit card numbers, emails from finance departments). Configuring at least one mail flow rule with rights protection for high-risk email scenarios ensures sensitive information is automatically protected at the message transport layer, reducing the risk of data exfiltration, unauthorized access, and compliance violations.

**Remediation action**

- Plan mail flow rule strategy: identify high-risk scenarios (external email, financial data, healthcare records)
- Navigate to mail flow rules in Exchange Admin Center
    - [Mail flow rules](https://admin.exchange.microsoft.com/#/transportrules)
- Create RMS templates or configure OME before creating rules
- Create rule for external email protection
- Create rules for sensitive content detection
- Configure rule priority/order
- Test rules with test emails
- Enable and monitor in production

For more information:
- [Mail flow rules in Exchange Online](https://learn.microsoft.com/en-us/exchange/security-and-compliance/mail-flow-rules/mail-flow-rules)
<!--- Results --->
%TestResult%
