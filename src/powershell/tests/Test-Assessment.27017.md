Azure Application Gateway Web Application Firewall (WAF) supports JavaScript challenge as a defense mechanism against automated bots and headless browsers. JavaScript challenge works by serving a small JavaScript snippet that must be executed by the client browser to prove that the request originates from a real browser capable of running JavaScript, rather than a simple HTTP client or bot.

When a request triggers a JavaScript challenge, the WAF responds with a challenge page containing JavaScript code that the browser must execute to obtain a valid challenge cookie. If the client successfully executes the JavaScript and returns with a valid cookie, subsequent requests proceed normally until the cookie expires. Bots and automated tools that cannot execute JavaScript fail this challenge and are blocked from accessing protected resources. This mechanism is particularly effective against credential stuffing bots, web scrapers, and distributed denial of service bots that use simple HTTP libraries without JavaScript engines.

The `jsChallengeCookieExpirationInMins` setting controls how long the challenge cookie remains valid before the client must complete another challenge. JavaScript challenge provides a middle ground between allowing all traffic and blocking suspected bots outright—it verifies browser capability without requiring user interaction like CAPTCHA. By configuring custom rules with JavaScript challenge action, organizations can protect sensitive endpoints like login pages, API endpoints, and high-value resources from automated abuse while maintaining a seamless experience for legitimate users.


**Remediation action**

- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview) - Overview of WAF capabilities on Application Gateway including custom rules and actions
- [Create and use Web Application Firewall v2 custom rules on Application Gateway](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-custom-waf-rules) - Step-by-step guidance on creating custom rules with different actions including JavaScript challenge
- [Web Application Firewall custom rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview) - Detailed documentation of custom rule types and available actions
- [Bot protection overview for Application Gateway WAF](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection-overview) - Overview of bot protection capabilities including challenge actions


<!--- Results --->
%TestResult%
