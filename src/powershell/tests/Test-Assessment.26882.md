Azure Application Gateway Web Application Firewall (WAF) provides bot protection through the Microsoft Bot Manager ruleset, which identifies and categorizes automated traffic based on behavioral patterns, known bot signatures, and IP reputation. Without bot protection enabled, threat actors leverage automated tools to perform large-scale attacks that would be impractical manually: credential stuffing attacks that test stolen username and password combinations across login endpoints at thousands of attempts per minute, content scraping that extracts proprietary data and pricing information for competitive exploitation, inventory hoarding bots that deplete product availability for legitimate customers, and application-layer denial of service attacks that overwhelm backend resources.

These automated attacks often originate from distributed botnets that rotate IP addresses to evade simple rate limiting, making signature-based bot detection essential. The Bot Manager ruleset classifies bots into categories including known good bots (search engines), known bad bots (scrapers, spammers), and unknown bots, allowing granular policy enforcement. Without this classification, malicious bot traffic blends with legitimate requests, consuming application resources and enabling fraud that damages revenue and customer trust. By enabling the Bot Manager ruleset on Application Gateway WAF, organizations ensure automated attacks are identified and blocked before they can exploit application vulnerabilities or exhaust backend capacity.

**Remediation action**

- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including bot protection
- [Configure bot protection for Web Application Firewall on Azure Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection) - Step-by-step guidance on enabling and configuring bot protection
- [Web Application Firewall bot protection overview](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection-overview) - Detailed documentation of bot categories and detection capabilities

<!--- Results --->
%TestResult%
