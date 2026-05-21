Enabling the admin consent workflow in a Microsoft Entra tenant ensures that users who need access to an application that requires admin consent can submit a request for review rather than being blocked outright. Without the workflow, users who can't consent to an app on their own may resort to shadow IT workarounds, such as using personal accounts or unsanctioned alternatives—that are harder to monitor and secure. When the workflow is enabled, consent requests go through a logged, auditable process where designated reviewers are notified and evaluate each request before consent is granted. This improves observability into which applications users are requesting access to, and ensures that elevated permissions are reviewed and explicitly approved rather than silently blocked or granted without oversight.

**Remediation action**

For admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.

- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)
- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings
<!--- Results --->
%TestResult%
