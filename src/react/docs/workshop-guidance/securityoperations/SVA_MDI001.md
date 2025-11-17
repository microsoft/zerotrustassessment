 # Lay the Groundwork for Microsoft Defender for Identity

**Implementation Effort:** Medium — While the deployment requires planning and coordination across teams, it follows a well-documented process and can be phased in gradually.

**User Impact:** Medium — Although end users are not directly involved, security teams may need to notify certain users or departments if identity-related alerts or investigations arise during rollout.

## Overview

Microsoft Defender for Identity (MDI) is a cloud-native security solution that helps detect identity-based threats by analyzing signals from Active Directory environments. It identifies suspicious activities such as lateral movement, credential theft, and privilege escalation, and integrates with Microsoft Defender XDR for broader threat correlation.

Laying the groundwork includes:

- **Licensing**: You must have one of the following licenses:
  - Microsoft 365 E5, A5, G5, or F5 Security
  - Enterprise Mobility + Security E5 (EMS E5/A5)
  - A standalone Microsoft Defender for Identity license [1](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites)

- **Permissions**: You need a Microsoft Entra ID tenant with at least one user assigned the **Security Administrator** role to create and manage the MDI workspace [1](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites).

- **Directory Service Account**: At least one account with read access to all objects in the monitored domains is required. This account is used by MDI to query Active Directory for security signals [1](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites).

- **Connectivity**: The Defender for Identity service must be able to communicate with the cloud. You can enable this via:
  - A forward proxy (with specific URL allowlisting)
  - ExpressRoute with Microsoft peering
  - Firewall rules using Azure IP ranges and service tags [1](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites)

Without MDI, organizations may lack visibility into identity-based attack vectors, which are often exploited early in breach attempts. This deployment supports the Zero Trust principle of **"Assume Breach"** by continuously monitoring identity signals and surfacing anomalies that indicate compromise.

## Reference
- [Microsoft Defender for Identity prerequisites](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites)
- [Deploy Microsoft Defender for Identity](https://learn.microsoft.com/en-us/defender-for-identity/deploy/deploy-defender-identity)
- [Standalone sensor prerequisites](https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites-standalone)
