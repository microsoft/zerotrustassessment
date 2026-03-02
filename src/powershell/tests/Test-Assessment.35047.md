Recovery Services Vaults store backup data for Azure VMs, SQL databases, file shares, and on-premises workloads. Without immutability and soft-delete protections, backup data is vulnerable to deletion by ransomware, malicious insiders, or compromised administrator accounts — the exact scenarios where backups are most needed.

**Immutability** prevents backup data from being modified or deleted before a specified retention period expires. When immutability is enabled, even subscription owners and Microsoft support cannot delete backup data prematurely. When set to "Locked" state, immutability becomes irreversible and provides the highest level of protection.

**Soft-delete** retains deleted backup data for an additional retention period (default 14 days) after deletion, allowing recovery from accidental or malicious deletion. Without soft-delete, deleting a backup item permanently removes all recovery points immediately.

Without these protections:
- **Ransomware** operators routinely target backups for deletion before encrypting production data, eliminating the primary recovery mechanism.
- **Compromised admin accounts** can permanently delete backup data, leaving no path to recovery.
- **Accidental deletion** of backup policies or protected items results in immediate, irreversible loss of all recovery points.
- **Insider threats** can destroy backup data to cover tracks after data theft or sabotage.

**Remediation action**

To enable immutability and soft-delete on Recovery Services Vaults:

1. Navigate to the [Azure portal Recovery Services Vaults blade](https://portal.azure.com/#browse/Microsoft.RecoveryServices%2Fvaults).
2. Select each vault identified in the assessment results.
3. Go to **Properties** under **Settings**.
4. Under **Security Settings**, click **Update**.
5. Enable **Soft delete** for backup items.
6. Enable **Immutability** and set the appropriate retention period.
7. Click **Update** to save.

**Note**: Once immutability is set to "Locked" state, it cannot be reversed. Start with "Enabled" state and move to "Locked" after validating configuration.

Using the Azure CLI:

```bash
# Enable soft-delete (enabled by default on new vaults)
az backup vault backup-properties set --name <vault-name> --resource-group <resource-group> --soft-delete-feature-state Enable

# Enable immutability
az backup vault backup-properties set --name <vault-name> --resource-group <resource-group> --is-immutability-enabled true
```

Using Azure PowerShell:

```powershell
# Enable soft-delete and immutability
Set-AzRecoveryServicesVaultProperty -VaultId <vault-id> -SoftDeleteFeatureState Enable
Update-AzRecoveryServicesVault -ResourceGroupName <resource-group> -Name <vault-name> -ImmutabilityState Unlocked
```

For more information, refer to the following Microsoft Learn documentation:

- [Soft delete for Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-security-feature-cloud)
- [Immutable vaults for Azure Backup](https://learn.microsoft.com/en-us/azure/backup/backup-azure-immutable-vault-concept)
- [Security features for protecting hybrid backups](https://learn.microsoft.com/en-us/azure/backup/security-overview)
- [Best practices for Azure Backup](https://learn.microsoft.com/en-us/azure/backup/guidance-best-practices)

<!--- Results --->
%TestResult%
