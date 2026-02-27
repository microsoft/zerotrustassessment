Global Secure Access maintains a system bypass list of destinations that are automatically excluded from TLS inspection due to known incompatibilities such as certificate pinning, mutual TLS requirements, or other technical constraints. When administrators create custom bypass rules that duplicate destinations already covered by the system bypass list, these rules are redundant and serve no functional purpose. Redundant rules consume policy capacity (TLS inspection supports up to 1,000 rules and 8,000 destinations per tenant), create administrative overhead during policy reviews, and may cause confusion about which rules are actually necessary for the organization's specific requirements versus which are duplicating built-in protections. Maintaining a clean policy configuration with only necessary custom bypass rules improves manageability, makes security audits more straightforward, and ensures that policy capacity is available for legitimate business requirements rather than duplicated system functionality.

**Remediation action**

Review and remove redundant custom bypass rules in the Microsoft Entra admin center under Global Secure Access > Secure > TLS inspection policies

Reference the current system bypass list:
- [FAQ: What destinations are included in the system bypass?](https://learn.microsoft.com/en-us/entra/global-secure-access/faq-transport-layer-security#what-destinations-are-included-in-the-system-bypass)

<!--- Results --->
%TestResult%
