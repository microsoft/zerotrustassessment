Device code flow is a cross-device authentication flow designed for input-constrained devices. It can be exploited in phishing attacks, where an attacker initiates the flow and tricks a user into completing it on their device, thereby sending the user's tokens to the attacker. Given the security risks and the infrequent legitimate use of device code flow, you should enable a Conditional Access policy to block this flow by default.

**Remediation action**

- [Deploy a Conditional Access policy to block device code flow](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow-policies).
<!--- Results --->
%TestResult%

