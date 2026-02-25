Azure Front Door Web Application Firewall (WAF) supports JavaScript challenge as a defense mechanism against automated bots and headless browsers across the global edge network. JavaScript challenge works by serving a small JavaScript snippet that must be executed by the client browser to prove that the request originates from a real browser capable of running JavaScript, rather than a simple HTTP client or bot.

When a request triggers a JavaScript challenge, the WAF responds with a challenge page containing JavaScript code that the browser must execute to obtain a valid challenge cookie. Bots and automated tools that cannot execute JavaScript fail this challenge and are blocked from accessing protected resources.

The `javascriptChallengeExpirationInMinutes` setting controls how long the challenge cookie remains valid before the client must complete another challenge. JavaScript challenge provides a middle ground between allowing all traffic and blocking suspected bots outright.

This check identifies Azure Front Door WAF policies that are attached to an Azure Front Door and verifies that at least one custom rule with JavaScript challenge action is configured and enabled.

**Remediation action**

- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [Web Application Firewall custom rules for Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-custom-rules)
- [Configure JavaScript challenge for Azure Front Door WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning#javascript-challenge)
- [Tutorial: Create a Web Application Firewall policy on Azure Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-create-portal)

<!--- Results --->
%TestResult%
