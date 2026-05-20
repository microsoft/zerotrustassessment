Azure Application Gateway Web Application Firewall (WAF) provides centralized protection for web applications through managed rulesets that contain pre-configured detection signatures for known attack patterns.

The Microsoft Default Ruleset and OWASP Core Rule Set are continuously updated managed rulesets that protect against the most common and dangerous web vulnerabilities without requiring security expertise to configure.

When no managed ruleset is enabled, the WAF policy provides no protection against known attack patterns, effectively operating as a pass-through despite being deployed.

Threat actors routinely scan for unprotected web applications and exploit well-documented vulnerabilities using automated toolkits; without managed rules, attackers can execute SQL injection to extract or modify database contents, perform cross-site scripting to hijack user sessions and steal credentials, exploit local file inclusion to read sensitive configuration files, and leverage command injection to gain shell access on backend servers.

These attack techniques have known signatures that managed rulesets detect and block, but an empty or disabled ruleset configuration means the WAF cannot recognize these patterns and will allow malicious requests to reach backend applications unimpeded.


**Remediation action**

- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including managed rulesets
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules) - Detailed documentation of available rulesets and rule groups
- [Create Web Application Firewall policies for Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-waf-policy-ag) - Step-by-step guidance on creating and configuring WAF policies with managed rulesets


<!--- Results --->
%TestResult%
