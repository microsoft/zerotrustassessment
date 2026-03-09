Azure Application Gateway Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities, including SQL injection, cross-site scripting, and other OWASP Top 10 threats. WAF operates in two modes: Detection and Prevention. Detection mode logs matched requests but doesn't block traffic, while Prevention mode actively blocks malicious requests before they reach the backend application. When WAF is in Detection mode, web applications remain exposed to exploitation even though threats are being identified.

Without WAF in Prevention mode:

- Threat actors can exploit web application vulnerabilities such as SQL injection and cross-site scripting, because matched requests are only logged, not blocked.
- Organizations lose the active protection that managed and custom WAF rules provide, which reduces WAF to an observability tool rather than a security control.

**Remediation action**

- [Configure WAF on Azure Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#waf-modes) to switch the WAF policy from **Detection mode** to **Prevention mode**.
- [Create and manage WAF policies for Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/create-waf-policy-ag?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to apply Prevention mode settings across all Application Gateway instances.
<!--- Results --->
%TestResult%

