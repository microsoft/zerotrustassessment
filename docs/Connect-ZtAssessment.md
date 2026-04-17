# Using App-Only Authentication with Zero Trust Assessment

This guide explains how to run the Zero Trust Assessment without any user sign-in prompts by using **app-only Certificate-Based Authentication (CBA)**. This is the recommended approach for automated or scheduled assessment runs.

---

## Overview

By default, `Connect-ZtAssessment` signs in as a user (delegated authentication). When you supply `-ClientId`, `-TenantId`, and `-Certificate` together, it switches to **app-only mode** — the assessment runs as an application identity with no interactive prompts. All three parameters are required and must target a specific tenant.

### Supported services

| Service | App-Only CBA |
|---|---|
| Microsoft Graph | ✅ |
| Azure | ✅ |
| Exchange Online | ✅ |
| Security & Compliance | ✅ |
| SharePoint Online | ✅ |
| Azure Information Protection | ❌ |

**Azure Information Protection (AIP)** does not support app-only authentication. When `-Certificate` is supplied, AIP tests are skipped automatically and a warning is shown. This is expected behavior.

---

## Prerequisites

### App registration

Create an Entra app registration and note the **Application (client) ID** and **Directory (tenant) ID**.

### Required API permissions

Grant the following **Application** permissions (not Delegated) and click **Grant admin consent**:

| API | Permission |
|---|---|
| Microsoft Graph | `AuditLog.Read.All` |
| Microsoft Graph | `CrossTenantInformation.ReadBasic.All` |
| Microsoft Graph | `CustomSecAttributeAssignment.Read.All` |
| Microsoft Graph | `DeviceManagementApps.Read.All` |
| Microsoft Graph | `DeviceManagementConfiguration.Read.All` |
| Microsoft Graph | `DeviceManagementManagedDevices.Read.All` |
| Microsoft Graph | `DeviceManagementRBAC.Read.All` |
| Microsoft Graph | `DeviceManagementServiceConfig.Read.All` |
| Microsoft Graph | `Directory.Read.All` |
| Microsoft Graph | `DirectoryRecommendations.Read.All` |
| Microsoft Graph | `EntitlementManagement.Read.All` |
| Microsoft Graph | `IdentityRiskEvent.Read.All` |
| Microsoft Graph | `IdentityRiskyServicePrincipal.Read.All` |
| Microsoft Graph | `IdentityRiskyUser.Read.All` |
| Microsoft Graph | `NetworkAccess.Read.All` |
| Microsoft Graph | `Policy.Read.All` |
| Microsoft Graph | `Policy.Read.ConditionalAccess` |
| Microsoft Graph | `Policy.Read.PermissionGrant` |
| Microsoft Graph | `PrivilegedAccess.Read.AzureAD` |
| Microsoft Graph | `Reports.Read.All` |
| Microsoft Graph | `RoleManagement.Read.All` |
| Microsoft Graph | `UserAuthenticationMethod.Read.All` |
| Office 365 Exchange Online | `Exchange.ManageAsApp` |
| SharePoint | `Sites.FullControl.All` |

### Required directory roles

Assign the following Entra directory roles to the app's service principal:

| Role | Required for |
|---|---|
| Exchange Administrator | Exchange Online |
| Compliance Administrator | Security & Compliance |
| SharePoint Administrator | SharePoint Online |
| Global Reader | Microsoft Graph read access |

### Certificate

Upload a certificate (public key) to the app registration under **Certificates & secrets → Certificates**. The certificate with its private key must be installed in the local certificate store on the machine running the assessment.

---

## Connect

```powershell
$clientId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'  # Application (client) ID
$tenantId = 'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy'  # Directory (tenant) ID

Connect-ZtAssessment -ClientId $clientId -TenantId $tenantId -Certificate 'CN=ZeroTrustAssessment' -Service All
```

The `-Certificate` parameter accepts:
- A **subject name string** (e.g. `'CN=ZeroTrustAssessment'`) — picks the latest valid matching certificate from your store
- A **thumbprint string**
- An **`X509Certificate2` object**

### Expected output

```
🔑 Authentication to Graph, Azure, AipService, ExchangeOnline, SecurityCompliance, SharePointOnline.
During the next steps, you may be prompted to authenticate separately for several services.

Connecting to Microsoft Graph
   ✅ Connected

Connecting to Azure
   ✅ Connected

Connecting to Azure Information Protection
   ⚠️ AipService does not support app-only (certificate) authentication.
      AIP tests will be skipped.

Connecting to Exchange Online
   ✅ Connected

Connecting to Microsoft Security & Compliance PowerShell
   ✅ Connected

Connecting to SharePoint Online
   ✅ Connected
```

---

## Connect to specific services only

If you don't need all services, specify only the ones you want:

```powershell
Connect-ZtAssessment -ClientId $clientId -TenantId $tenantId -Certificate 'CN=ZeroTrustAssessment' `
    -Service Graph, ExchangeOnline, SecurityCompliance
```
