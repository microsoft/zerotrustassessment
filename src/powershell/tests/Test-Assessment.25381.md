Traffic forwarding profiles are the foundational mechanism through which Global Secure Access captures and routes network traffic to Microsoft's Security Service Edge (SSE) infrastructure. Without enabling the appropriate traffic forwarding profiles, network traffic bypasses the Global Secure Access service entirely, leaving users without zero trust network access protections.

There are three distinct profiles: the **Microsoft traffic profile** captures Microsoft Entra ID, Microsoft Graph, SharePoint Online, Exchange Online, and other Microsoft 365 workloads; the **Private Access profile** captures traffic destined for internal corporate resources configured through Quick Access or per-app access; and the **Internet Access profile** captures traffic to the public internet including non-Microsoft SaaS applications.

When these profiles are disabled, corresponding network traffic is not tunneled through Global Secure Access, meaning security policies, web content filtering, threat protection, and Universal Continuous Access Evaluation cannot be enforced. A threat actor who compromises user credentials can access corporate resources without the security controls that Global Secure Access would otherwise apply.

For **Private Access**, disabled profiles mean remote users cannot securely connect to internal applications, file servers, or Remote Desktop sessions through the zero-trust model—potentially forcing fallback to legacy VPN solutions with broader network access.

For **Internet Access**, disabled profiles mean users accessing external SaaS applications, collaboration tools, or web resources are not protected by security policies, and data exfiltration to unauthorized internet destinations cannot be prevented.

**Remediation action**

Enable all traffic forwarding profiles to ensure comprehensive protection:

- [Enable the Microsoft 365 traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-microsoft-profile)
- [Enable the Private Access traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-private-access-profile)
- [Enable the Internet Access traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-internet-access-profile)
- [Understand traffic forwarding profile concepts](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-traffic-forwarding)
<!--- Results --->
%TestResult%
