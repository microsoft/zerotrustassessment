Without web content filtering policies configured in Global Secure Access, organizations lack granular control over which internet destinations users can access through the Secure Web Gateway. Threat actors can exploit this gap by luring users to malicious websites through phishing emails, social engineering, or compromised legitimate sites. Once a user navigates to a threat actor-controlled destination, the attacker can deliver malware payloads, harvest credentials through fake login pages, or exploit browser vulnerabilities to establish initial access. From this foothold, threat actors can conduct reconnaissance of the internal environment, move laterally by compromising additional systems, and exfiltrate sensitive data to external destinations. The lack of category-based filtering also enables users to inadvertently access illegal content, gambling sites, or other categories that create legal liability and compliance risk. Web content filtering policies provide the enforcement mechanism to block access to known-dangerous categories such as malware, phishing, hacking, and criminal activity sites at the network edge before connections are established, breaking the kill chain at the initial access stage.

**Remediation action**

Enable the Internet Access traffic forwarding profile to route traffic through Global Secure Access
- [Manage Internet Access profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-internet-access-profile)

Create web content filtering policies to block malicious and inappropriate web categories
- [Configure web content filtering](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering)

Review the available web content filtering categories to determine which categories to block
- [Web content filtering categories reference](https://learn.microsoft.com/en-us/entra/global-secure-access/reference-web-content-filtering-categories)

Create security profiles and link filtering policies to organize policy enforcement
- [Create a security profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-a-security-profile)

Create Conditional Access policies to apply security profiles to users and groups
- [Create and link Conditional Access policy](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-and-link-conditional-access-policy)

Configure the baseline security profile for tenant-wide policy enforcement without Conditional Access
- [Create a baseline profile](https://learn.microsoft.com/en-us/entra/architecture/gsa-poc-internet-access#create-a-baseline-profile-that-applies-to-all-internet-traffic-routed-through-the-service)

<!--- Results --->
%TestResult%
