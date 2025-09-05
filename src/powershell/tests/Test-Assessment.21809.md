Enabling the Admin consent workflow in a Microsoft Entra tenant is a vital security measure that mitigates risks associated with unauthorized application access and privilege escalation. This check is important because it ensures that any application requesting elevated permission undergoes a review process by designated administrators before consent is granted. The admin consent workflow in Microsoft Entra ID notifies reviewers who evaluate and approve or deny consent requests based on the application's legitimacy and necessity. If this check doesn't pass, meaning the workflow is disabled, any application can request and potentially receive elevated permissions without administrative review. This poses a substantial security risk, as malicious actors could exploit this lack of oversight to gain unauthorized access to sensitive data, perform privilege escalation, or execute other malicious activities.

**Remediation action**

For admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.

- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)
- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings
<!--- Results --->
%TestResult%

