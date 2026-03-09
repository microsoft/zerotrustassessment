Azure Front Door Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities, including SQL injection, cross-site scripting, and other OWASP Top 10 threats. WAF operates in two modes: Detection and Prevention. Detection mode evaluates and logs requests that match WAF rules but doesn't block traffic, while Prevention mode actively blocks malicious requests before they reach the backend application. When WAF is in Detection mode, web applications remain exposed to exploitation even though threats are being identified.

Without WAF in Prevention mode:

- Threat actors can exploit web application vulnerabilities because matched requests are only logged, not blocked.
- Organizations lose active protection at the global edge that managed and custom WAF rules provide, which reduces WAF to an observation tool rather than a security control.

**Remediation action**

- [Configure WAF for Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to switch the WAF policy from **Detection mode** to **Prevention mode**.
- [Configure WAF policy settings for Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#waf-mode) to enable **Prevention mode** in the policy settings.
<!--- Results --->
%TestResult%

