Azure Front Door Web Application Firewall (WAF) supports rate limiting through custom rules that restrict the number of requests clients can make within a specified time window across the global edge network. Rate limiting is a critical defense mechanism that protects applications from abuse by throttling clients that exceed defined request thresholds before traffic reaches origin servers.

Without rate limiting configured, threat actors can execute brute force attacks, credential stuffing attacks, API abuse, and application-layer denial of service attacks that flood endpoints with requests to exhaust server capacity.

Rate limiting rules use the `RateLimitRule` rule type and allow administrators to define thresholds based on request count per minute, with the ability to group requests by client IP address. When a client exceeds the configured threshold, the WAF can block subsequent requests, log the violation, issue a CAPTCHA challenge, or redirect to a custom page.

This check identifies Azure Front Door WAF policies that are attached to an Azure Front Door and verifies that at least one rate limiting rule is configured and enabled.

**Remediation action**

- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [Web Application Firewall custom rules for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-custom-rules)
- [Rate limiting for Azure Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-rate-limit)
- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)

<!--- Results --->
%TestResult%
