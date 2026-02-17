Azure Firewall is a cloud-native network security service that provides centralized inspection, logging, and enforcement for network traffic flowing between application workloads and external destinations. Routing outbound traffic through Azure Firewall enables organizations to apply consistent security controls such as threat intelligence filtering, intrusion detection and prevention, TLS inspection, and egress policy enforcement.

In a secure network architecture, outbound traffic from workloads hosted in Azure virtual networks should be explicitly routed through Azure Firewall before reaching the internet or external services. VNET integrated workloads include VMs, AKS Node Pools, AKS Pods, App Service (VNet Integration Route All), and Functions in VNet. This is typically achieved by configuring routing so that outbound traffic from workload subnets uses Azure Firewall as the next hop. Without this routing in place, outbound traffic may bypass the firewall entirely, reducing visibility and allowing traffic to leave the environment without inspection or policy enforcement.

This check verifies that outbound traffic from in-scope workloads across all subscriptions in the tenant is routed through Azure Firewall by validating that the effective network routes direct outbound traffic to the firewall's private IP address. The check enumerates each accessible subscription and evaluates outbound routing for eligible workload network interfaces within those subscriptions. If outbound traffic is not routed through Azure Firewall, the check fails because traffic may bypass centralized security controls, increasing the risk of data exfiltration, command-and-control communication, and undetected malicious activity.

**Remediation action**

- [Deploy and configure Azure Firewall using the Azure portal](https://learn.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal#configure-routing)
- [Control outbound traffic with Azure Firewall ](https://learn.microsoft.com/en-us/azure/app-service/network-secure-outbound-traffic-azure-firewall)

<!--- Results --->
%TestResult%
