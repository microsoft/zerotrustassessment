Azure Firewall provides centralized inspection, logging, and enforcement for outbound network traffic. When you don't route outbound traffic from virtual network (VNet) integrated workloads through Azure Firewall, traffic can leave your environment without inspection or policy enforcement. VNet integrated workloads include virtual machines, AKS node pools, App Service with VNet integration, and Azure Functions in VNet.

Without routing outbound traffic through Azure Firewall:

- Threat actors can use uninspected outbound paths for data exfiltration and command-and-control communication.
- Organizations lose consistent enforcement of egress security controls such as threat intelligence filtering, intrusion detection and prevention, and TLS inspection.
- Security teams lack visibility into outbound traffic patterns, which makes it difficult to detect and investigate suspicious network activity.

**Remediation action**

- [Configure Azure Firewall routing](https://learn.microsoft.com/azure/firewall/tutorial-firewall-deploy-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-routing) to direct outbound traffic from workload subnets through the firewall's private IP address.
- [Manage route tables and routes](https://learn.microsoft.com/azure/virtual-network/manage-route-table?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to create user-defined routes for the default route (0.0.0.0/0) pointing to the Azure Firewall private IP.
- [Control App Service outbound traffic with Azure Firewall](https://learn.microsoft.com/azure/app-service/network-secure-outbound-traffic-azure-firewall?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for App Service VNet integration scenarios.
- [Configure Azure Firewall rules](https://learn.microsoft.com/azure/firewall/rule-processing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to allow required outbound traffic while blocking malicious destinations.
<!--- Results --->
%TestResult%

