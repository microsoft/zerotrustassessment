Unmaintained or orphaned redirect URIs in app registrations create significant security vulnerabilities when they reference domains that no longer point to active resources. Threat actors can exploit these "dangling" DNS entries by provisioning resources at abandoned domains, effectively taking control of redirect endpoints. This vulnerability enables attackers to intercept authentication tokens and credentials during OAuth 2.0 flows, which can lead to unauthorized access, session hijacking, and potential broader organizational compromise.

**Remediation action**

- [Redirect URI (reply URL) outline and restrictions](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

