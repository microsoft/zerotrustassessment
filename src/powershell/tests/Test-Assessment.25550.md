Azure Firewall Premium offers Transport Layer Security (TLS) inspection to decrypt and inspect outbound and east-west TLS traffic, and inbound TLS traffic when used with Azure Application Gateway. TLS inspection is critical for detecting advanced threats that use encrypted channels to evade traditional security controls.

When TLS inspection is enabled, Azure Firewall uses a customer-provided CA certificate stored in Azure Key Vault to decrypt, inspect, and then re-encrypt traffic before forwarding it to its destination. This enables advanced security capabilities such as IDPS and URL filtering to analyze encrypted traffic and identify malicious activity that would otherwise remain hidden.

This check verifies that Azure Firewall Premium has TLS inspection enabled. Without TLS inspection, the firewall cannot inspect encrypted payloads, significantly limiting visibility into threats that leverage TLS to evade detection.

**Remediation action**

- [Enable and use TLS inspection in Azure Firewall Premium policy](https://learn.microsoft.com/en-us/azure/firewall/premium-features)
- [Azure Firewall Premium features implementation guide](https://learn.microsoft.com/en-us/azure/firewall/premium-deploy-certificates-enterprise-ca)
- [Azure Firewall Premium certificates - How to create and configure intermediate CA certificates for TLS inspection](https://learn.microsoft.com/en-us/azure/firewall/premium-certificates)

<!--- Results --->
%TestResult%
