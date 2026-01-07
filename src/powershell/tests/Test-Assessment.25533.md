DDoS attacks remain a major security and availability risk for customers with cloud-hosted applications.  These attacks aim to overwhelm an application's compute, network, or memory resources, rendering it inaccessible to legitimate users. Any public-facing endpoint exposed to the internet can be a potential target for a DDoS attack. Azure DDoS Protection provides always-on monitoring and automatic mitigation against DDoS attacks targeting public-facing workloads. Without Azure DDoS Protection (Network Protection or IP Protection), public IP addresses for services such as Application Gateways, Load Balancers, or virtual machines remain exposed to DDoS attacks that can overwhelm network bandwidth, exhaust system resources, and cause complete service unavailability. These attacks can disrupt access for legitimate users, degrade performance, and create cascading outages across dependent services.Azure DDoS Protection uses adaptive real-time tuning to profile normal traffic patterns and automatically detects anomalies indicative of an attack. When an attack is identified, mitigation is engaged at the Azure network edge to absorb and filter malicious traffic before it reaches your applications. This check verifies that Azure DDoS Protection is enabled for public IP addresses within a VNET, ensuring that applications are protected from DDoS attacks. If this check does not pass, your workloads remain significantly more vulnerable to downtime, customer impact, and operational disruption during an attack.

## Remediation Resources

- [Please check the articles below for guidance on how to enable DDoS Protection for Public IP addresses.](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection)
- [Please check the articles below for guidance on how to enable DDoS Protection for Public IP addresses.](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-ip-protection-portal)


<!--- Results --->
%TestResult%
