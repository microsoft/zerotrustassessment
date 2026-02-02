Mail flow rules (transport rules) in Exchange Online allow organizations to automatically apply information protection policies to email messages based on conditions such as sender, recipient, content patterns, or organizational attributes. When mail flow rules with rights protection are not configured, organizations must rely solely on users to manually apply sensitivity labels or encrypt messages—an approach that is inconsistent, error-prone, and does not scale. Without automated rights protection rules, sensitive emails are frequently sent unencrypted, allowing unauthorized access, forwarding, and printing of confidential information. Rights protection rules automatically apply encryption, restriction labels, and permissions to messages matching specific criteria (e.g., emails to external domains, messages containing credit card numbers, emails from finance departments). Configuring at least one mail flow rule with rights protection for high-risk email scenarios ensures sensitive information is automatically protected at the message transport layer, reducing the risk of data exfiltration, unauthorized access, and compliance violations.


**Remediation action**

1. [Plan mail flow rule strategy and identify high-risk scenarios (external email, financial data, health records)](https://learn.microsoft.com/en-us/powershell/module/exchange/get-transportrule).
2. [Ensure RMS templates and OME are configured prior to creating transport rules that rely on them](https://learn.microsoft.com/en-us/exchange/security-and-compliance/mail-flow-rules/mail-flow-rules).
3. Create targeted transport rules that apply OME encryption or RMS templates for specific conditions (recipient domain, sensitive content, sender groups).
4. Test rules to validate behavior and minimize false positives.
5. Enable rules in production and monitor using mail flow reports and message trace.

<!--- Results -->
%TestResult%
