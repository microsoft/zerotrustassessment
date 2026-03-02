Azure Storage encryption at rest protects data by automatically encrypting it before persisting to disk and decrypting it upon retrieval. While Azure enables encryption by default for new Storage Accounts, it is critical to verify that all accounts — including older or migrated accounts — have encryption enabled. Without encryption at rest:

- **Data breach exposure** — If physical storage media is compromised or improperly decommissioned, unencrypted data can be read directly.
- **Compliance violations** — PCI DSS, HIPAA, GDPR, and SOC 2 all mandate encryption of data at rest for sensitive workloads.
- **Regulatory penalties** — Organizations handling personal data without encryption at rest may face significant fines under data protection regulations.
- **Incomplete data lifecycle protection** — Even with encryption in transit (TLS/HTTPS), data stored without encryption remains vulnerable at the storage layer.

This check complements the TLS/HTTPS transit encryption check by ensuring data is protected at both layers — in transit and at rest.

**Remediation action**

To verify and enable encryption at rest for Storage Accounts:

1. Navigate to the [Azure portal Storage Accounts blade](https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts).
2. Select each Storage Account identified in the assessment results.
3. Go to **Security + networking** → **Encryption**.
4. Verify that **encryption type** is set (Microsoft-managed keys or customer-managed keys).
5. For enhanced security, consider using **customer-managed keys** stored in Azure Key Vault.

To verify encryption status using the Azure CLI:

```bash
az storage account show --name <storage-account> --resource-group <resource-group> --query "encryption.services.blob.enabled"
```

To configure customer-managed keys for enhanced encryption:

```bash
az storage account update \
    --name <storage-account> \
    --resource-group <resource-group> \
    --encryption-key-source Microsoft.Keyvault \
    --encryption-key-vault <key-vault-uri> \
    --encryption-key-name <key-name>
```

For more information, refer to the following Microsoft Learn documentation:

- [Azure Storage encryption for data at rest](https://learn.microsoft.com/en-us/azure/storage/common/storage-service-encryption)
- [Customer-managed keys for Azure Storage encryption](https://learn.microsoft.com/en-us/azure/storage/common/customer-managed-keys-overview)
- [Azure Storage security guide](https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations)
- [Azure data encryption best practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/data-encryption-best-practices)

<!--- Results --->
%TestResult%
