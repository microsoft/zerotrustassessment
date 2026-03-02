Azure Storage Accounts can contain highly sensitive data including application data, backups, logs, and documents. If public blob access is enabled or network rules are permissive, this data may be accessible to anyone on the internet without authentication.

**Public blob access** allows anonymous users to read data from blob containers that have their access level set to "Blob" or "Container". Even if no containers are currently public, leaving this setting enabled at the account level creates risk — a single misconfigured container can expose all its contents.

**Network default action set to Allow** means the storage account accepts connections from any IP address on the internet. Combined with valid access keys or SAS tokens, this allows data access from anywhere. A Zero Trust approach requires network access to be denied by default and explicitly allowed only for trusted networks, services, or private endpoints.

Without these controls:
- **Data breaches** from publicly accessible blob containers (a common source of cloud data leaks).
- **Credential-based attacks** where stolen access keys or SAS tokens can be used from any location.
- **Lateral movement** where an attacker who compromises one resource can access storage from anywhere.
- **Compliance violations** with frameworks requiring network-level access controls (PCI DSS, HIPAA, NIST 800-53).

**Remediation action**

To disable public blob access and restrict network access:

1. Navigate to the [Azure portal Storage Accounts blade](https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts).
2. Select each Storage Account identified in the assessment results.
3. Go to **Configuration** under **Settings** and set **Allow Blob anonymous access** to **Disabled**.
4. Go to **Networking** under **Security + networking**.
5. Set **Public network access** to **Enabled from selected virtual networks and IP addresses** or **Disabled**.
6. If using selected networks, add the required virtual networks and IP address ranges.
7. Consider enabling **Private endpoints** for secure access from virtual networks.

Using the Azure CLI:

```bash
# Disable public blob access
az storage account update --name <account-name> --resource-group <resource-group> --allow-blob-public-access false

# Set network default action to Deny
az storage account update --name <account-name> --resource-group <resource-group> --default-action Deny
```

Using Azure PowerShell:

```powershell
# Disable public blob access and set network default to Deny
Set-AzStorageAccount -ResourceGroupName <resource-group> -Name <account-name> -AllowBlobPublicAccess $false
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName <resource-group> -Name <account-name> -DefaultAction Deny
```

For more information, refer to the following Microsoft Learn documentation:

- [Remediate anonymous public read access to blob data](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent)
- [Configure Azure Storage firewalls and virtual networks](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security)
- [Use private endpoints for Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Azure Storage security guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)

<!--- Results --->
%TestResult%
