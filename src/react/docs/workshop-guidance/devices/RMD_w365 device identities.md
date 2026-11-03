# Windows 365: Device Identities

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Every Windows 365 Cloud PC needs a device identity model that determines how it is joined, managed, and trusted. In practice, this usually means choosing between Microsoft Entra joined Cloud PCs and Microsoft Entra hybrid joined Cloud PCs. That decision affects networking prerequisites, policy delivery, authentication patterns, and operational complexity.

For most greenfield or cloud-first deployments, Microsoft Entra join is the simpler and preferred model. Hybrid join can still be required where applications or management patterns depend on traditional on-premises Active Directory integration, but it introduces additional dependencies that should be justified explicitly.

## Implementation Guidance

1. Decide the join model during Windows 365 design, not after provisioning. Review whether the target users and applications truly require on-premises Active Directory line-of-sight, legacy Group Policy dependence, or hybrid identity behaviors.
2. If Microsoft Entra join is sufficient, prefer it. It reduces dependency on on-premises connectivity, aligns naturally with Intune management, and simplifies Zero Trust policy design for cloud-first device identity.
3. If Microsoft Entra hybrid join is required, validate prerequisites before deployment: Azure network connectivity, reliable name resolution, line-of-sight to domain controllers where needed, and the broader identity synchronization architecture that supports your organization.
4. Create separate Windows 365 provisioning policies for different join types rather than mixing assumptions in one policy. This makes network, image, and application assignment cleaner and reduces troubleshooting complexity.
5. Test identity outcomes after provisioning. Confirm that the Cloud PC appears correctly in Microsoft Entra ID and Intune, receives the expected policies, and supports the authentication methods you intend to require, including passwordless options such as Windows Hello for Business where applicable.

## Reference

- **[Create provisioning policies for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)** — Explains how to create provisioning policies for Windows 365 Cloud PCs.
- **[Join your cloud-native endpoints to Microsoft Entra - Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/cloud-native-endpoints/entra-join-types)** — Explains Microsoft Entra join options relevant to cloud-native endpoint deployments.
- **[Configure Microsoft Entra hybrid join - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/how-to-hybrid-join)** — Provides the configuration guidance for Microsoft Entra hybrid join scenarios.
