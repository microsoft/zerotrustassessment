Azure Storage Accounts handle critical data including blobs, files, queues, and tables. Enforcing TLS 1.2 as the minimum transport protocol and requiring HTTPS-only traffic are essential encryption-in-transit controls that protect data from interception and tampering.

**TLS 1.0 and 1.1** have known vulnerabilities including BEAST, POODLE, and other cryptographic weaknesses. These older protocols can be exploited to decrypt traffic through downgrade attacks. Microsoft recommends TLS 1.2 as the minimum version for all Azure services.

**HTTP traffic** transmits data in plaintext, allowing any network intermediary to read or modify the contents. Storage account access keys, SAS tokens, and data payloads sent over HTTP are fully exposed.

Without these controls:
- Attackers on the network path can **intercept storage account credentials** (access keys or SAS tokens) transmitted in plaintext.
- **Data in transit** (uploads, downloads, API calls) can be read or modified by man-in-the-middle attackers.
- **Downgrade attacks** can force connections to use weaker TLS versions with known exploits.
- Regulatory frameworks (PCI DSS, HIPAA, SOC 2) require encryption in transit — non-compliance can result in audit failures.

**Remediation action**

To enforce TLS 1.2 and HTTPS-only on Storage Accounts:

1. Navigate to the [Azure portal Storage Accounts blade](https://portal.azure.com/#browse/Microsoft.Storage%2FStorageAccounts).
2. Select each Storage Account identified in the assessment results.
3. Go to **Configuration** under **Settings**.
4. Set **Minimum TLS version** to **Version 1.2**.
5. Set **Secure transfer required** to **Enabled**.
6. Click **Save**.

Using the Azure CLI:

```bash
az storage account update --name <account-name> --resource-group <resource-group> --min-tls-version TLS1_2 --https-only true
```

Using Azure PowerShell:

```powershell
Set-AzStorageAccount -ResourceGroupName <resource-group> -Name <account-name> -MinimumTlsVersion TLS1_2 -EnableHttpsTrafficOnly $true
```

For more information, refer to the following Microsoft Learn documentation:

- [Enforce a minimum required version of TLS for requests to a storage account](https://learn.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version)
- [Require secure transfer to ensure secure connections](https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer)
- [Azure Storage security guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)

<!--- Results --->
%TestResult%
