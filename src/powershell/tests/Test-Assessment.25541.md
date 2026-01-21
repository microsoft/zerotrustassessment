Azure Application Gateway is a Layer 7 load balancer that manages HTTP/S traffic, providing features such as SSL termination, URL-based routing, and integration with Web Application Firewall (WAF) for web application protection. Web Application Firewall (WAF) in Azure Application Gateway protects web applications from common exploits and vulnerabilities such as SQL injections, cross-site scripting, and other OWASP Top 10 threats.

Azure Web Application Firewall (WAF) on Application Gateway operates in two modes: **Detection** and **Prevention**. 

- **Detection mode** evaluates incoming HTTP/S requests against managed and custom WAF rules and logs matched requests for visibility and analysis, but it does not block traffic.
- **Prevention mode** evaluates requests in the same way but also actively blocks malicious requests that violate WAF rules, preventing them from reaching the backend application.

Running WAF in Prevention mode is crucial for actively protecting applications against common web attacks.

This check verifies that WAF is configured in Prevention mode, ensuring that identified threats are blocked before reaching your application. If WAF is in Detection mode, the check fails because malicious traffic will only be logged, not prevented, leaving applications exposed to exploitation.


**Remediation action**

- [Azure Web Application Firewall on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)
- [Web Application Firewall policy overview](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/policy-overview)
- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag)
- [Best practices for Azure Web Application Firewall on Azure Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/best-practices)

<!--- Results --->
%TestResult%
