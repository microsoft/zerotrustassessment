Azure Application Gateway Web Application Firewall (WAF) supports rate limiting through custom rules that restrict the number of requests clients can make within a specified time window. Rate limiting is a critical defense mechanism that protects applications from abuse by throttling clients that exceed defined request thresholds. 

Without rate limiting configured, threat actors can execute brute force attacks that attempt thousands of password combinations per minute against authentication endpoints, credential stuffing attacks that test stolen credentials at scale, API abuse that extracts large volumes of data or consumes expensive backend resources, and application-layer denial of service attacks that flood endpoints with requests to exhaust server capacity. 

Rate limiting rules use the `RateLimitRule` rule type and allow administrators to define thresholds based on request count per minute, with the ability to group requests by client IP address (using `groupBy` with `ClientAddr` variable) to track and limit individual clients. When a client exceeds the configured threshold, the WAF can block subsequent requests, log the violation, or redirect to a custom page. Unlike managed rulesets that detect attack patterns, rate limiting provides a quantitative defense that limits the impact of any volumetric attack regardless of whether the individual requests appear malicious. By configuring rate limiting on Application Gateway WAF, organizations can ensure that no single client can monopolize application resources or execute high-volume automated attacks.


**Remediation action**

- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including custom rules
- [Create and use Web Application Firewall v2 custom rules on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-custom-waf-rules) - Step-by-step guidance on creating custom rules including rate limiting
- [Web Application Firewall custom rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview) - Detailed documentation of custom rule types including RateLimitRule
- [Rate limiting in Application Gateway WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/rate-limiting-overview) - Overview of rate limiting capabilities and configuration options


<!--- Results --->
%TestResult%
