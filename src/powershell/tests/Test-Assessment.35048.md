Azure Private Endpoints provide secure, private connectivity to PaaS services by routing traffic through the Azure backbone network instead of the public internet. Without Private Endpoints, services like Storage Accounts, SQL Databases, Key Vaults, and Cosmos DB are accessible over public IP addresses, creating exposure to:

- **Data exfiltration** — Attackers who gain network access can reach PaaS services directly over the internet.
- **Man-in-the-middle attacks** — Public endpoints traverse the internet where traffic can be intercepted.
- **Unauthorized access** — Public endpoints are discoverable and can be targeted by brute-force or credential stuffing attacks.
- **Compliance violations** — Many regulatory frameworks (PCI DSS, HIPAA, SOC 2) require private network connectivity for sensitive data services.

Zero Trust principles require that all access to resources is verified, least-privileged, and assumes breach. Private Endpoints enforce network-level isolation by ensuring that PaaS services are only reachable from within your virtual network, eliminating public internet exposure entirely.

**Remediation action**

To deploy Private Endpoints for PaaS services:

1. Navigate to the [Azure portal Private Endpoints blade](https://portal.azure.com/#browse/Microsoft.Network%2FprivateEndpoints).
2. Click **+ Create** to create a new Private Endpoint.
3. Select the **target resource** (e.g., Storage Account, SQL Server, Key Vault).
4. Choose the **virtual network and subnet** where the Private Endpoint will be placed.
5. Configure **Private DNS integration** to enable name resolution to the private IP address.
6. After creating the Private Endpoint, **disable public access** on the target resource.

To create a Private Endpoint using the Azure CLI:

```bash
az network private-endpoint create \
    --name <endpoint-name> \
    --resource-group <resource-group> \
    --vnet-name <vnet-name> \
    --subnet <subnet-name> \
    --private-connection-resource-id <target-resource-id> \
    --group-id <sub-resource> \
    --connection-name <connection-name>
```

To disable public access on a Storage Account after enabling Private Endpoint:

```bash
az storage account update --name <storage-account> --resource-group <resource-group> --default-action Deny
```

For more information, refer to the following Microsoft Learn documentation:

- [What is Azure Private Link?](https://learn.microsoft.com/en-us/azure/private-link/private-link-overview)
- [Create a Private Endpoint](https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-portal)
- [Azure Private Endpoint DNS configuration](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- [Azure network security best practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/network-best-practices)

<!--- Results --->
%TestResult%
