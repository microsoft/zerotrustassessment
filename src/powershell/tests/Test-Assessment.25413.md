Without network content filtering through file policies, threat actors can exfiltrate data to unsanctioned destinations through browsers, applications, add-ins, and APIs. When file policies are not configured, threat actors exploit unmanaged cloud applications and generative AI tools as exfiltration channels for sensitive information.

**Remediation action**

Follow these steps to configure file policy protection:

- [Configure web content filtering policies in Global Secure Access, which covers the foundational approach for creating filtering policies including file policies](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering)
- [Create and manage security profiles that group filtering policies for enforcement through Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-traffic-forwarding)
- [Link security profiles to Conditional Access policies for user-aware and context-aware enforcement of network security policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session)
- [Deploy the Global Secure Access client on end-user devices to enable traffic acquisition and policy enforcement](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-windows-client)

<!--- Results --->
%TestResult%
