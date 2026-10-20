A stolen session token can let a threat actor access a sensitive cloud app from an unmanaged device without triggering a new sign-in. Conditional Access App Control routes the session through Microsoft Defender for Cloud Apps, where session policies can monitor activity, block downloads or copying, require step-up authentication, and apply sensitivity labels. This check confirms that at least one enabled Conditional Access policy routes targeted cloud apps through Defender for Cloud Apps session control.

## Remediation resources

- [Protect apps with Microsoft Defender for Cloud Apps Conditional Access App Control](https://learn.microsoft.com/en-us/defender-cloud-apps/proxy-intro-aad)
- [Deploy Conditional Access App Control for featured apps](https://learn.microsoft.com/en-us/defender-cloud-apps/proxy-deployment-aad)
- [Create access and session policies](https://learn.microsoft.com/en-us/defender-cloud-apps/session-policy-aad)
- [Conditional Access policy resource type](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)

<!--- Results --->
%TestResult%
