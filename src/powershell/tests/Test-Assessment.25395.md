When organizations configure Microsoft Entra Private Access with broad application segments—such as wide IP ranges, multiple protocols, or Quick Access configurations—they effectively replicate the over-permissive access model of traditional VPNs. This approach contradicts the Zero Trust principle of least-privilege access, where users should only reach the specific resources required for their role. Threat actors who compromise a user's credentials or device can leverage these broad network permissions to perform reconnaissance, identifying additional systems and services within the permitted range. 

With visibility into the network topology, they can escalate privileges by targeting vulnerable systems, move laterally to access sensitive data stores or administrative interfaces, and establish persistence by deploying backdoors across multiple accessible systems. The lack of granular segmentation also complicates incident response, as security teams cannot quickly determine which specific resources a compromised identity could access. By contrast, per-application segmentation with tightly scoped destination hosts, specific ports, and Custom Security Attributes enables dynamic, attribute-driven Conditional Access enforcement—requiring stronger authentication or device compliance for high-risk applications while streamlining access to lower-risk resources. 

This approach aligns with the Zero Trust "verify explicitly" principle by ensuring each access request is evaluated against the specific security requirements of the target application rather than applying uniform policies to broad network segments.

**Remediation action**
- [Transition from Quick Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-per-app-access) to per-app Private Access by creating individual Global Secure Access enterprise applications with specific FQDNs, IP addresses, and ports for each private resource.
- [Use Application Discovery](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-application-discovery) to identify which resources users access through Quick Access, then create targeted Private Access apps for those resources.
- [Create Custom Security Attribute sets](https://learn.microsoft.com/en-us/entra/fundamentals/custom-security-attributes-add) and definitions to categorize Private Access applications by risk level, department, or compliance requirements.
- [Assign Custom Security Attributes](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/custom-security-attributes-apps) to Private Access application service principals to enable attribute-based access control.
- [Create Conditional Access policies using application filters](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-filter-for-applications) to target Private Access apps based on their Custom Security Attributes, enforcing granular controls like MFA or device compliance.
- [Apply Conditional Access policies to Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-target-resource-private-access-apps) apps from within Global Secure Access for streamlined configuration.

Review
- [Zero Trust network segmentation guidance for software-defined perimeters](https://learn.microsoft.com/en-us/security/zero-trust/deploy/networks#1-network-segmentation-and-software-defined-perimeters). 


<!--- Results --->
%TestResult%
