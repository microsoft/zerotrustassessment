Azure Front Door Web Application Firewall (WAF) provides centralized protection for web applications against common exploits and vulnerabilities. Request body inspection is a critical capability that allows the WAF to analyze the content of HTTP POST, PUT, and PATCH request bodies for malicious patterns. When request body inspection is disabled, threat actors can craft attacks that embed malicious SQL statements, scripts, or command injection payloads within form submissions, API calls, or file uploads that bypass all WAF rule evaluation. This creates a direct path for exploitation where threat actors gain initial access through unprotected application endpoints, execute arbitrary commands or queries against backend databases through SQL injection, exfiltrate sensitive data including credentials and customer information, establish persistence by modifying application data or injecting backdoors, and pivot to internal systems through compromised application server credentials. The WAF's managed rule sets, including OWASP Core Rule Set and Microsoft's threat intelligence-based rules, cannot evaluate threats they cannot see; disabling request body inspection renders these protections ineffective against body-based attack vectors that represent the majority of modern web application attacks.

**Remediation action**

Overview of WAF capabilities on Azure Front Door including request body inspection
- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)

Detailed guidance on configuring WAF policy settings including request body inspection
- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-settings)

Best practices for tuning WAF including request body inspection limits
- [Tuning Azure Web Application Firewall for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning)

<!--- Results --->
%TestResult%
