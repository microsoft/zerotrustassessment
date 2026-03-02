Azure Key Vault provides centralized management of cryptographic keys, certificates, and secrets. Soft-delete and purge protection are critical recovery safeguards that prevent permanent loss of vault contents due to accidental or malicious deletion.

**Soft-delete** ensures that deleted vaults and their contents (keys, secrets, certificates) are retained in a recoverable state for a configurable retention period (7–90 days). Without soft-delete, deletion is immediate and irreversible.

**Purge protection** adds an additional layer by preventing even privileged users from permanently purging (force-deleting) a soft-deleted vault before the retention period expires. This is essential for protecting against insider threats and compromised admin accounts.

Without these safeguards:
- Accidental deletion of a Key Vault results in **permanent loss** of all keys, secrets, and certificates.
- Applications relying on the vault for encryption, TLS certificates, or connection strings experience **immediate outages**.
- Recovery may be **impossible**, requiring re-creation of all cryptographic material and reconfiguration of dependent services.
- A compromised administrator account could **permanently destroy** critical security material.

Note: As of February 2025, Azure enforces soft-delete by default on all new Key Vaults. However, older vaults created before this enforcement may still have soft-delete disabled, and purge protection must always be explicitly enabled.

**Remediation action**

To enable soft-delete and purge protection on existing Key Vaults:

1. Navigate to the [Azure portal Key Vaults blade](https://portal.azure.com/#browse/Microsoft.KeyVault%2Fvaults).
2. Select each Key Vault and go to **Properties**.
3. Verify that **Soft-delete** is enabled.
4. Enable **Purge protection** if it is not already active.

Alternatively, use the Azure CLI:

```bash
az keyvault update --name <vault-name> --enable-soft-delete true --enable-purge-protection true
```

Or Azure PowerShell:

```powershell
Update-AzKeyVault -VaultName <vault-name> -EnableSoftDelete $true -EnablePurgeProtection $true
```

For more information, refer to the following Microsoft Learn documentation:

- [Azure Key Vault soft-delete overview](https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview)
- [Azure Key Vault security features](https://learn.microsoft.com/en-us/azure/key-vault/general/security-features)
- [Best practices for using Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)
- [Azure Key Vault recovery management with soft-delete and purge protection](https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery)

<!--- Results --->
%TestResult%
