
# Identity and Device Pillars of the Zero Trust Workshop

## Identity Pillar

**Implementation Effort:** Medium – Requires consolidation of identity providers, migration of apps, and enforcement of MFA and Conditional Access policies.

**User Impact:** Low – Changes are managed by administrators and mostly affect backend identity systems.

### Overview
The identity pillar focuses on verifying user and entity identities using strong authentication, centralized identity management, and risk-based access controls. Microsoft recommends consolidating identity providers using Microsoft Entra ID, enforcing multifactor authentication (MFA), and applying Conditional Access policies to gate access based on user, device, and location signals. This ensures consistent policy enforcement and reduces the risk of identity-based attacks. If not implemented, organizations may face fragmented identity systems, poor visibility into identity risk, and increased exposure to phishing and credential theft. 

## Reference
- [Zero Trust Workshop Identity Pillar](https://microsoft.github.io/zerotrustassessment/docs/category/identity)

---

## Device Pillar

**Implementation Effort:** Medium – Requires device registration, compliance policy setup, and integration with Microsoft Intune and Defender for Endpoint.

**User Impact:** Low – Device policies are enforced by IT; users are not required to take action.

### Overview
The Device pillar ensures that only healthy, compliant, and trusted devices can access corporate resources. Microsoft recommends using Microsoft Intune for device management, enforcing compliance policies, and integrating with security controls for risk-based access decisions. Devices should be registered with Microsoft Entra ID and monitored continuously. Without this, organizations risk data leakage from unmanaged or compromised devices.

## Reference
- [Zero Trust Workshop Devices Pillar](https://microsoft.github.io/zerotrustassessment/docs/category/identity)
