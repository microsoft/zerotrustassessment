Azure Application Gateway Web Application Firewall (WAF) provides centralized protection for web applications against common exploits and vulnerabilities at the regional level. Request body inspection is a critical capability that allows the WAF to analyze the content of HTTP POST, PUT, and PATCH request bodies for malicious patterns. When request body inspection is disabled, threat actors can craft attacks that embed malicious SQL statements, scripts, or command injection payloads within form submissions, API calls, or file uploads that bypass all WAF rule evaluation. This creates a direct path for exploitation where threat actors gain initial access through unprotected application endpoints, execute arbitrary commands or queries against backend databases through SQL injection, exfiltrate sensitive data including credentials and customer information, establish persistence by modifying application data or injecting backdoors, and pivot to internal systems through compromised application server credentials. The WAF's managed rule sets, including OWASP Core Rule Set and Microsoft's Bot Manager rules, cannot evaluate threats they cannot see; disabling request body inspection renders these protections ineffective against body-based attack vectors that represent the majority of modern web application attacks.

**Remediation action**

Overview of WAF capabilities on Application Gateway including request body inspection
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview)

Guidance on creating and configuring WAF policies including request body inspection settings
- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag)

FAQ and best practices for tuning WAF including request body inspection limits
- [Tuning Web Application Firewall for Azure Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-faq)

<!--- Results --->
%TestResult%
