# Conditional Access Policies

**Last Updated:** May 2025  
**Implementation Effort:** Medium – IT teams must configure Intune compliance policies and Conditional Access rules in Microsoft Entra, which requires planning and testing but not ongoing manual effort.  
**User Impact:** Medium – Users might be required to register their device, install the Company Portal, or update security settings.

## Introduction

Conditional Access is a core enforcement mechanism in Microsoft Entra ID that allows organizations to control access to apps and resources based on real-time conditions. For macOS devices managed by Intune, Conditional Access ensures that only trusted, compliant, and identity-verified endpoints can access corporate data. This section helps administrators evaluate their Conditional Access strategy for macOS and align it with Zero Trust principles.

## Why This Matters

- **Enforces access control based on device compliance and user identity**.
- **Supports Zero Trust** by requiring continuous evaluation of trust signals.
- **Reduces risk** by blocking access from unmanaged or non-compliant devices.
- **Improves visibility** into access patterns and policy effectiveness.
- **Enables adaptive access** based on risk, location, or session context.

## Key Considerations

### Device Compliance Integration

- Conditional Access policies can require that macOS devices be marked as **compliant in Intune** before access is granted.
- This ensures that only devices meeting your FileVault, OS version, and password policies can access sensitive resources.

From a Zero Trust perspective: This enforces **explicit verification** of device posture before granting access.

### App-Based Targeting

- Conditional Access policies can be scoped to specific apps (e.g., Microsoft 365, Salesforce, ServiceNow).
- This allows you to apply stricter controls to high-risk or high-value applications.

From a Zero Trust perspective: This supports **least privilege** by tailoring access controls to the sensitivity of the resource.

### User and Group Scoping

- Policies can be applied to all users or scoped to specific groups, departments, or roles.
- Use this to apply more stringent controls to executives, finance, or privileged IT users.

From a Zero Trust perspective: This enables **risk-based access** and **role-aware enforcement**.

### Conditions and Controls

Common conditions include:

- **Device platform** (macOS)  
- **Location** (trusted vs. untrusted networks)  
- **Sign-in risk** (if using Microsoft Defender for Identity)  

Common controls include:

- **Require compliant device**  
- **Require MFA**  
- **Require app protection policy**  

From a Zero Trust perspective: These controls enforce **adaptive access** based on real-time context.

### macOS-Specific Considerations

- Ensure that devices are **Entra-joined** and enrolled in Intune to meet compliance requirements.
- Use **Platform SSO** and the **SSO app extension** to ensure seamless authentication and policy enforcement.
- Monitor for devices that are accessing resources but are not enrolled or compliant.

### Monitoring and Reporting

- Use the **Microsoft Entra admin center** to review sign-in logs, policy impact, and blocked access attempts.
- Analyze trends to refine policies and reduce false positives.

From a Zero Trust perspective: Monitoring supports **continuous trust evaluation** and **policy tuning**.

## Zero Trust Considerations

- **Verify explicitly**: Access is granted only after confirming user identity, device compliance, and session context.
- **Assume breach**: Conditional Access policies block access from unmanaged or risky endpoints.
- **Least privilege**: Access is scoped to the user, device, and app context.
- **Continuous trust**: Policies are evaluated at every sign-in, not just at enrollment.
- **Defense in depth**: Conditional Access works alongside compliance policies, SSO, and device restrictions to enforce layered security.

## Recommendations

- **Require compliant macOS devices** for access to all corporate resources.
- **Use MFA and device compliance** as baseline controls for all users.
- **Apply stricter policies** to high-risk apps and privileged user groups.
- **Use Platform SSO and SSO extensions** to ensure seamless policy enforcement.
- **Monitor sign-in logs** and refine policies based on real-world usage and risk.
- **Test policies in report-only mode** before enforcing them in production.

## References

- [Conditional Access Overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)  
- [Conditional Access for macOS Devices](https://learn.microsoft.com/en-us/mem/intune/protect/conditional-access-intune-common-ways-use)  
- [Monitor Conditional Access Policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/monitor-conditional-access)  
- [Platform SSO and Compliance Integration](https://learn.microsoft.com/en-us/entra/identity/devices/macos-psso)
