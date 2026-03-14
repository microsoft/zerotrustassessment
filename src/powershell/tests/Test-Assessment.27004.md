Global Secure Access maintains a system bypass list of destinations that are automatically excluded from Transport Layer Security (TLS) inspection. These bypass destinations represent known incompatibilities such as certificate pinning, mutual TLS requirements, or other technical constraints. Custom bypass rules that duplicate destinations in the system bypass list are redundant and serve no functional purpose.

Redundant rules consume policy capacity, create administrative overhead, and can cause confusion about which rules are necessary. TLS inspection supports up to 1,000 rules and 8,000 destinations per tenant. Maintaining a clean policy configuration with only necessary custom bypass rules improves manageability, simplifies security audits, and ensures that policy capacity is available for legitimate business requirements.

**Remediation action**

- Review and remove redundant custom TLS inspection bypass rules in the Microsoft Entra admin center. Navigate to **Global Secure Access** > **Secure** > **TLS inspection policies**.
- Review [the destinations included in the system bypass list](https://learn.microsoft.com/entra/global-secure-access/faq-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#what-destinations-are-included-in-the-system-bypass).
<!--- Results --->
%TestResult%

