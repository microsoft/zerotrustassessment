Communication Compliance policies with Copilot content detection enable organizations to monitor and investigate how users interact with Microsoft Copilot in Teams, Outlook, and Microsoft 365 apps. Without Communication Compliance policies configured to capture Copilot interactions, organizations cannot detect when sensitive data is being exposed to AI services, how users are leveraging Copilot with confidential information, or detect potential policy violations involving AI-assisted data processing.

Copilot interaction capture through Communication Compliance enables organizations to implement governance and oversight of AI usage while maintaining user communication privacy controls. Users may unknowingly expose sensitive data (customer records, financial information, source code, trade secrets) to Copilot, creating a data spillage risk that becomes invisible without activity monitoring. Organizations must enable Communication Compliance policies targeting Copilot interactions to maintain visibility into how AI features are being used with sensitive data and ensure compliance with data governance policies.

**Remediation action**

To create and enable Communication Compliance policies for Copilot interaction capture:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Communication Compliance > Policies
3. Select "+ Create policy" to start the policy creation workflow
4. Choose the "Monitor for sensitive content" template or create a custom policy
5. Name the policy (e.g., "Copilot Data Protection")
6. Configure the scope (all users or specific groups)
7. On the Conditions page, add conditions to detect:
   - Sensitive information types (credit cards, SSN, financial data)
   - Keywords related to confidential data
   - Custom patterns for your organization's sensitive data
8. On the Review settings page, configure:
   - Reviewers (compliance team members)
   - Alert volume preference
   - Review mailbox for alerts
9. Enable the policy
10. Verify rule creation via PowerShell using Query 1 and 2

Via PowerShell (creation requires portal, but verification via cmdlets):

```powershell
Connect-ExchangeOnline
Get-SupervisoryReviewRule -IncludeRuleXml | Select-Object Name, Policy
Get-SupervisoryReviewPolicyV2 | Select-Object Name, Enabled, ReviewMailbox
```

For more information:
- [Communication Compliance overview](https://learn.microsoft.com/en-us/purview/communication-compliance)
- [Create Communication Compliance policies](https://learn.microsoft.com/en-us/purview/communication-compliance-policies)
- [SupervisoryReview cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/exchange/get-supervisoryreviewpolicyv2)
<!--- Results --->
%TestResult%
