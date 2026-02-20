DDoS attacks remain a major security and availability risk for customers with cloud-hosted applications. These attacks aim to overwhelm an application's compute, network, or memory resources, rendering it inaccessible to legitimate users. Any public-facing endpoint exposed to the internet can be a potential target for a DDoS attack. Azure DDoS Protection provides always-on monitoring and automatic mitigation against DDoS attacks targeting public-facing workloads.

Without Azure DDoS Protection (Network Protection or IP Protection), public IP addresses for services such as Application Gateways, Load Balancers, Azure Firewalls, Azure Bastion, Virtual Network Gateways, or virtual machines remain exposed to DDoS attacks that can overwhelm network bandwidth, exhaust system resources, and cause complete service unavailability. These attacks can disrupt access for legitimate users, degrade performance, and create cascading outages across dependent services.

Azure DDoS Protection can be enabled in two ways:

- DDoS IP Protection — Protection is explicitly enabled on individual public IP addresses by setting ddosSettings.protectionMode to Enabled.
- DDoS Network Protection — Protection is enabled at the VNET level through a DDoS Protection Plan. Public IP addresses associated with resources in that VNET inherit the protection when ddosSettings.protectionMode is set to VirtualNetworkInherited. However, a public IP address with VirtualNetworkInherited is not protected unless the VNET actually has a DDoS Protection Plan associated and enableDdosProtection set to true.
This check verifies that every public IP address is actually covered by DDoS protection, either through DDoS IP Protection enabled directly on the public IP, or through DDoS Network Protection enabled on the VNET that the public IP's associated resource resides in. If this check does not pass, your workloads remain significantly more vulnerable to downtime, customer impact, and operational disruption during an attack.

**Remediation action**

To enable DDoS Protection for public IP addresses, refer to the following Microsoft Learn documentation:

- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)
- [Quickstart: Create and configure Azure DDoS Network Protection using Azure portal](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection)
- [Quickstart: Create and configure Azure DDoS IP Protection using Azure portal](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-ip-protection-portal)
- [Azure DDoS Protection SKU comparison](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-sku-comparison)

<!--- Results --->
%TestResult%
