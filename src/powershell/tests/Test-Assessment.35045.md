Azure SQL Server supports two authentication methods: SQL authentication (username/password) and Microsoft Entra ID (formerly Azure AD) authentication. When SQL authentication is enabled alongside Entra ID, the server accepts shared passwords that bypass critical Zero Trust controls.

**SQL authentication** uses static username/password credentials that:
- Cannot enforce **multi-factor authentication (MFA)**.
- Are not subject to **Conditional Access policies** (location, device compliance, risk-based controls).
- Have no centralized **lifecycle management** — passwords don't expire automatically and access isn't revoked when employees leave.
- Are often **shared** between developers, applications, and scripts, making credential rotation difficult.
- Can be **brute-forced** if the server is accessible from the internet.

**Entra ID-only authentication** eliminates these risks by requiring all connections to authenticate through Microsoft Entra ID, which provides:
- Multi-factor authentication enforcement.
- Conditional Access policy evaluation.
- Centralized identity governance and access reviews.
- Managed identities for application-to-database connections (no credentials to manage).

Without Entra ID-only authentication:
- **Credential theft** of SQL passwords provides persistent database access that is difficult to detect.
- **No MFA protection** on database connections, even for administrative access.
- **Compliance gaps** with frameworks requiring strong authentication (NIST 800-53, PCI DSS, SOC 2).

**Remediation action**

To enable Entra ID-only authentication on Azure SQL Servers:

1. Navigate to the [Azure portal SQL Servers blade](https://portal.azure.com/#browse/Microsoft.Sql%2Fservers).
2. Select each SQL Server identified in the assessment results.
3. Go to **Microsoft Entra ID** under **Settings**.
4. Ensure a **Microsoft Entra admin** is configured.
5. Check **Support only Microsoft Entra authentication for this server**.
6. Click **Save**.

**Important**: Before enabling Entra ID-only authentication, ensure all applications and users are configured to authenticate using Entra ID credentials or managed identities.

Using the Azure CLI:

```bash
# Set the Entra ID admin
az sql server ad-admin create --resource-group <resource-group> --server-name <server-name> --display-name <admin-name> --object-id <admin-object-id>

# Enable Entra ID-only authentication
az sql server ad-only-auth enable --resource-group <resource-group> --name <server-name>
```

Using Azure PowerShell:

```powershell
# Enable Entra ID-only authentication
Enable-AzSqlServerActiveDirectoryOnlyAuthentication -ResourceGroupName <resource-group> -ServerName <server-name>
```

For more information, refer to the following Microsoft Learn documentation:

- [Microsoft Entra-only authentication with Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Configure Microsoft Entra authentication for Azure SQL](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure)
- [Use managed identities to access Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-azure-ad-user-assigned-managed-identity)
- [Azure SQL security best practices](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice)

<!--- Results --->
%TestResult%
