# Review 3rd Party Compliance API Connectors (PDM/PCM)

**Last Updated:** May 2025  
**Implementation Effort:** Medium – This setup requires coordination between Microsoft Intune, Microsoft Entra ID, and the third-party compliance partner, including configuration, licensing, and device enrollment.  
**User Impact:** Low – End users are not directly involved; compliance data is collected and processed in the background by the partner and Intune.

## Introduction

Intune supports integration with third-party compliance solutions through **Partner Device Management (PDM)** and **Partner Compliance Management (PCM)**. These integrations are designed for macOS devices that are **not enrolled in Intune**, but are instead managed by a third-party MDM or security platform. PDM/PCM allows organizations to bring external compliance signals into Intune, enabling **Conditional Access enforcement** based on third-party device posture.

This section helps administrators evaluate their current use of PDM/PCM integrations and ensure alignment with Zero Trust principles—especially in mixed-management environments.

## Why This Matters

- **Enables Conditional Access** for macOS devices managed outside of Intune.
- **Extends device compliance signals** beyond native Intune capabilities.
- **Supports Zero Trust** by incorporating real-time, external trust signals.
- **Improves visibility** into device health and risk across platforms.
- **Ensures future readiness** by aligning with Microsoft’s supported integration model.

## Key Considerations

### Integration Models

#### Partner Compliance Management (PCM)

- The **current and recommended model** for integrating third-party compliance solutions with Intune.
- Partners publish compliance data to Intune using Microsoft Graph APIs.
- Devices appear in Intune with compliance state and metadata, which can be used in Conditional Access policies.
- Enables enforcement of access controls based on third-party security posture—even if the device is not enrolled in Intune.

#### Legacy Compliance API (Deprecated)

- Older integrations used a now-deprecated compliance API model.
- Microsoft is phasing out this model in favor of PCM.
- If you're still using the legacy model, begin planning your migration to avoid disruption.

### Applicability to macOS

- This integration is only relevant if you have **macOS devices managed by a third-party solution**, not Intune.
- Common use cases include:
  - Devices managed by another MDM (e.g., Jamf)
  - Devices monitored by a third-party security agent (e.g., EDR, antivirus)
- Ensure the third-party solution supports macOS and is integrated using the modern PCM API.

### Compliance State Mapping

- Third-party compliance data is mapped into Intune’s compliance engine.
- Devices are marked as compliant or non-compliant based on partner-defined criteria.
- This compliance state can be used in Conditional Access policies to allow or block access to corporate resources.

### Visibility and Reporting

- Integrated devices appear in the Intune admin center with compliance status and partner attribution.
- Use reporting to monitor compliance trends and identify gaps in third-party coverage.

### Migration Planning

- If you're using the legacy compliance connector, begin planning your migration to the modern PCM model.
- Engage with your third-party vendor to confirm support for the new API and validate macOS compatibility.

## Zero Trust Considerations

- **Verify explicitly**: PDM/PCM integrations provide additional signals to evaluate device trust in real time.
- **Assume breach**: External telemetry helps detect compromised or misconfigured devices that may bypass native checks.
- **Least privilege**: Devices that fail third-party compliance checks can be dynamically blocked from accessing sensitive resources.
- **Continuous trust**: Compliance state is updated regularly, ensuring that access decisions reflect the current device posture—even for devices not enrolled in Intune.

## Recommendations

- **Use Partner Compliance Management** for all new third-party integrations.
- **Audit existing compliance connectors** to identify any legacy API usage.
- **Engage with vendors** to confirm support for the modern API and macOS compatibility.
- **Incorporate third-party compliance state** into Conditional Access policies for high-value resources.
- **Monitor compliance reporting** to ensure third-party signals are flowing correctly and being enforced.
- **Plan migration** away from deprecated APIs to maintain support and alignment with Microsoft’s roadmap.
- **Only implement this integration** if you have macOS devices managed outside of Intune and require Conditional Access enforcement.

## References
- [Partner Compliance Management Overview](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-partners)  
- [Microsoft Graph API for Compliance Integration](https://learn.microsoft.com/en-us/graph/api/resources/intune-shared-partnerdeviceconfiguration?view=graph-rest-beta)  
- [Deprecated Features in Intune and Configuration Manager](https://learn.microsoft.com/en-us/intune/configmgr/core/plan-design/changes/deprecated/removed-and-deprecated-cmfeatures)
