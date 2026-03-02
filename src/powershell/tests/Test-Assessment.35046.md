Microsoft Defender for Cloud provides advanced threat detection and security monitoring for Azure data services. When Defender plans are not enabled (set to "Free" tier), organizations lose critical security capabilities including real-time threat detection, vulnerability assessment, and anomaly detection for their data workloads.

The following Defender for Cloud data service plans provide distinct protection:

- **Defender for Storage** — Detects unusual access patterns, suspicious data exfiltration, malware uploads, and anomalous blob/file operations. Includes malware scanning and sensitive data threat detection.
- **Defender for Azure SQL** — Identifies SQL injection attacks, anomalous database access, brute-force attempts, and suspicious database activities. Includes vulnerability assessment to find misconfigurations.
- **Defender for Cosmos DB** — Detects potential SQL injection, known bad actors, suspicious access patterns, and potential exploitation of compromised identities to access databases.
- **Defender for SQL on VMs** — Extends SQL protection to SQL Server instances running on Azure Virtual Machines with the same threat detection and vulnerability assessment capabilities.
- **Defender for Open-Source Relational Databases** — Protects Azure Database for PostgreSQL, MySQL, and MariaDB with anomaly detection and threat intelligence.

Without these plans enabled:
- **No threat detection** for data-layer attacks such as SQL injection, credential stuffing, or data exfiltration.
- **No vulnerability assessment** to identify misconfigurations in database security settings.
- **No anomaly detection** for unusual data access patterns that may indicate compromised credentials.
- **Delayed incident response** due to lack of automated security alerts for data services.

**Remediation action**

To enable Defender for Cloud plans for data services:

1. Navigate to the [Azure portal Defender for Cloud pricing blade](https://portal.azure.com/#blade/Microsoft_Azure_Security/SecurityMenuBlade/pricingTier).
2. For each subscription, enable the following plans by setting them to **On** (Standard tier):
   - **Storage Accounts**
   - **SQL Servers**
   - **Cosmos DB**
   - **SQL Server on VMs**
   - **Open-Source Relational Databases**
3. Click **Save** for each subscription.

Using the Azure CLI:

```bash
# Enable Defender for Storage
az security pricing create --name StorageAccounts --tier Standard

# Enable Defender for Azure SQL
az security pricing create --name SqlServers --tier Standard

# Enable Defender for Cosmos DB
az security pricing create --name CosmosDbs --tier Standard

# Enable Defender for SQL on VMs
az security pricing create --name SqlServerVirtualMachines --tier Standard
```

Using Azure PowerShell:

```powershell
# Enable Defender plans for data services
Set-AzSecurityPricing -Name 'StorageAccounts' -PricingTier 'Standard'
Set-AzSecurityPricing -Name 'SqlServers' -PricingTier 'Standard'
Set-AzSecurityPricing -Name 'CosmosDbs' -PricingTier 'Standard'
Set-AzSecurityPricing -Name 'SqlServerVirtualMachines' -PricingTier 'Standard'
```

For more information, refer to the following Microsoft Learn documentation:

- [Microsoft Defender for Cloud overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-cloud-introduction)
- [Defender for Storage overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction)
- [Defender for Azure SQL overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-sql-introduction)
- [Defender for Cosmos DB overview](https://learn.microsoft.com/en-us/azure/defender-for-cloud/concept-defender-for-cosmos)
- [Enable Defender for Cloud plans](https://learn.microsoft.com/en-us/azure/defender-for-cloud/enable-enhanced-security)

<!--- Results --->
%TestResult%
