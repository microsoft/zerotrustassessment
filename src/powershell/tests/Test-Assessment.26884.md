Azure Front Door is a global, scalable entry point that uses the Microsoft global edge network to deliver fast, secure, and highly scalable web applications. Web Application Firewall (WAF) integrated with Azure Front Door provides protection against common web exploits and vulnerabilities at the network edge. The Bot Manager rule set is a managed rule set available exclusively in Azure Front Door Premium SKU that provides protection against malicious bots while allowing legitimate bots such as search engine crawlers to access your applications. When bot protection is not enabled, threat actors can deploy automated attacks against web applications including credential stuffing attacks that test stolen username/password combinations at scale, web scraping that extracts sensitive data or intellectual property, inventory hoarding bots that deplete product availability, and application-layer DDoS attacks that exhaust backend resources. The Bot Manager rule set categorizes bots into good bots, bad bots, and unknown bots, allowing security teams to configure appropriate actions for each category. Bad bots can be blocked or challenged with CAPTCHA, while good bots like Googlebot and Bingbot are allowed through. Without bot protection, organizations lack visibility into bot traffic patterns and cannot distinguish between human users and automated clients, making it impossible to defend against sophisticated bot-driven attacks that bypass traditional rate limiting and IP-based controls.

**Remediation action**

Upgrade to Azure Front Door Premium if currently using Standard SKU to access bot protection features
- [Azure Front Door tier comparison](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison)

Create a WAF policy with Premium SKU if one does not exist
- [Create a WAF policy for Azure Front Door using the Azure portal](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)

Enable the Bot Manager rule set in the WAF policy
- [Configure bot protection for Web Application Firewall](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)

Associate the WAF policy with your Azure Front Door profile via security policies
- [Security policies in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/standard-premium/how-to-configure-https-custom-domain#associate-the-custom-domain-with-your-azure-front-door-profile)

Monitor bot traffic using Azure Front Door logs and metrics
- [Monitor metrics and logs in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-diagnostics)

<!--- Results --->
%TestResult%
