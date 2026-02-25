Azure Front Door Web Application Firewall (WAF) provides centralized, edge-based protection for globally distributed web applications through managed rulesets that contain pre-configured detection signatures for known attack patterns. The Microsoft Default Ruleset is a continuously updated managed ruleset that protects against the most common and dangerous web vulnerabilities without requiring security expertise to configure. When no managed ruleset is enabled, the WAF policy provides no protection against known attack patterns, effectively operating as a pass-through despite being deployed at the edge. Threat actors routinely scan for unprotected web applications and exploit well-documented vulnerabilities using automated toolkits; without managed rules, attackers can execute SQL injection to extract or modify database contents, perform cross-site scripting to hijack user sessions and steal credentials, exploit local file inclusion to read sensitive configuration files, and leverage command injection to gain shell access on backend servers. These attack techniques have known signatures that managed rulesets detect and block at the edge before malicious traffic reaches origin servers, but an empty or disabled ruleset configuration means the WAF cannot recognize these patterns and will allow malicious requests to pass through to the application.

**Remediation action**

Enable the Microsoft Default Ruleset on Azure Front Door WAF policies
- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)

Configure Default Rule Set groups and rules for comprehensive protection
- [Web Application Firewall DRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-drs)

Create and configure WAF policies with managed rulesets
- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)

<!--- Results --->
%TestResult%
