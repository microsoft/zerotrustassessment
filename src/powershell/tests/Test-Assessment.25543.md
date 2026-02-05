Azure Front Door is a global, edge-based application delivery service that provides Layer 7 load balancing and acceleration. Web Application Firewall (WAF) in Azure Front Door protects web applications from common exploits and vulnerabilities such as SQL injection, cross-site scripting, and other OWASP Top 10 threats. 

Azure Front Door WAF operates in two modes: Detection and Prevention. Detection mode evaluates incoming HTTP/S requests against managed and custom WAF rules and logs matched requests for visibility and analysis, but it does not block traffic. Prevention mode evaluates requests in the same way but also actively blocks malicious requests that violate WAF rules, preventing them from reaching the backend application. Running WAF in Prevention mode is crucial for actively protecting applications against common web attacks. 

This check verifies that WAF is configured in Prevention mode, ensuring that identified threats are blocked before reaching your application. If WAF is in Detection mode, the check fails because malicious traffic will only be logged, not prevented, leaving applications exposed to exploitation. 

**Remediation action**

- [Configure Web Application Firewall (WAF) for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [Policy settings for Web Application Firewall in Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-mode)

<!--- Results --->
%TestResult%
