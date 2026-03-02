Azure Backup provides data protection by creating recovery points for virtual machines, databases, file shares, and other workloads. However, having Recovery Services Vaults configured without any enrolled protected items means no workloads are actually being backed up. This creates a false sense of security where backup infrastructure exists but provides no protection.

Without active backup enrollment:

- **Ransomware vulnerability** — Encrypted or deleted data cannot be recovered if no backup copies exist.
- **Accidental data loss** — Human errors (accidental deletion, misconfiguration) have no recovery path without backups.
- **Infrastructure failure** — Hardware failures, regional outages, or corruption events can cause permanent data loss.
- **Compliance gaps** — Regulatory frameworks (SOC 2, HIPAA, PCI DSS) require documented backup procedures with verifiable protected items.
- **Business continuity failure** — Without backup coverage, Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO) cannot be met.

This check complements the vault configuration check (immutability and soft-delete) by verifying that workloads are actually enrolled in backup — configuration without enrollment provides no protection.

**Remediation action**

To enroll workloads in Azure Backup:

1. Navigate to the [Azure portal Recovery Services Vaults blade](https://portal.azure.com/#browse/Microsoft.RecoveryServices%2Fvaults).
2. Select the Recovery Services Vault.
3. Go to **Protected items** → **Backup items**.
4. Click **+ Backup** to configure a new backup.
5. Select the **workload type** (Azure Virtual Machine, SQL in Azure VM, Azure File Share, etc.).
6. Choose a **backup policy** (or create a custom one with appropriate RPO).
7. Select the **resources** to protect and enable backup.

To enable backup for a VM using the Azure CLI:

```bash
az backup protection enable-for-vm \
    --resource-group <resource-group> \
    --vault-name <vault-name> \
    --vm <vm-name> \
    --policy-name DefaultPolicy
```

To enable backup for an Azure File Share:

```bash
az backup protection enable-for-azurefileshare \
    --resource-group <resource-group> \
    --vault-name <vault-name> \
    --storage-account <storage-account-name> \
    --azure-file-share <share-name> \
    --policy-name DefaultPolicy
```

For more information, refer to the following Microsoft Learn documentation:

- [Azure Backup overview](https://learn.microsoft.com/en-us/azure/backup/backup-overview)
- [Back up Azure VMs](https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-first-look-arm)
- [Back up Azure file shares](https://learn.microsoft.com/en-us/azure/backup/backup-afs)
- [Azure Backup best practices](https://learn.microsoft.com/en-us/azure/backup/guidance-best-practices)

<!--- Results --->
%TestResult%
