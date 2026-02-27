# Remote Help

**Last Updated:** May 2025  
**Implementation Effort:** Medium – Setting up Remote Help for macOS requires deploying the helper app, configuring Intune RBAC roles, and optionally integrating Conditional Access and compliance policies.  
**User Impact:** Medium – Users receiving help (sharers) may need to install the Remote Help app or use the web app, and they must actively participate in support sessions.

## Introduction

Remote Help is a secure, cloud-based support tool integrated with Intune that allows IT administrators to remotely assist users on managed devices. As of 2024, Remote Help is supported on **macOS 12.6 and later**, enabling secure screen sharing and remote control for Intune-enrolled macOS devices. From a Zero Trust perspective, Remote Help reinforces **identity verification**, **least privilege**, and **auditable support workflows**.

This section helps macOS administrators understand how to enable, configure, and use Remote Help in a Zero Trust-aligned support model.

## Why This Matters

- **Enables secure remote support** for macOS users without requiring third-party tools.
- **Supports Zero Trust** by verifying user and device identity before session initiation.
- **Improves IT efficiency** by reducing time to resolution.
- **Enhances user experience** by providing real-time assistance.
- **Ensures auditability** of support sessions and actions.

## Key Considerations

### Platform and Enrollment Requirements

Remote Help for macOS requires:

- macOS 12.6 or later  
- Intune enrollment  
- Company Portal app installed  

From a Zero Trust perspective: Ensures that **only managed, compliant devices** are eligible for remote support.

### Identity Verification

- Both the helper and the user must sign in with Microsoft Entra ID.
- Sessions are authenticated and authorized through Intune and Entra ID.

From a Zero Trust perspective: This enforces **explicit verification** of both parties before any remote access is granted.

### Permissions and Role Control

- Remote Help permissions are managed via **RBAC roles** in Intune.
- You can control who can initiate sessions, view screens, or request full control.

From a Zero Trust perspective: This supports **least privilege** by ensuring only authorized personnel can provide support.

### Session Capabilities

IT admins can:

- View the user’s screen  
- Request control (user must approve)  
- Chat with the user during the session  

Users can revoke access at any time.

From a Zero Trust perspective: Sessions are **user-consented, time-bound, and revocable**, aligning with **just-in-time access** principles.

### Auditing and Compliance

- All Remote Help sessions are logged in the **Intune admin center**.
- Logs include session metadata such as participants, duration, and actions taken.

From a Zero Trust perspective: This provides **auditable support workflows** and **post-incident traceability**.

### Licensing

- Remote Help for macOS requires a **Remote Help add-on license**.
- Ensure that both helpers and users are properly licensed.

## Zero Trust Considerations

- **Verify explicitly**: Both the helper and the user must authenticate with Entra ID before a session begins.
- **Assume breach**: Sessions are limited to managed, compliant devices and require user consent.
- **Least privilege**: Access is role-based and scoped to the minimum required for support.
- **Continuous trust**: Sessions are logged, monitored, and revocable in real time.
- **Defense in depth**: Remote Help complements device compliance, RBAC, and Conditional Access.

## Recommendations

- **Enable Remote Help** for macOS in environments where secure support is required.
- **Assign RBAC roles** to limit who can initiate and control sessions.
- **Ensure Company Portal is installed** and devices are enrolled in Intune.
- **Educate users** on how to recognize and approve legitimate support sessions.
- **Monitor session logs** regularly to detect anomalies or misuse.
- **Review licensing** to ensure all participants are covered.

## References

- [Remote Help for macOS Overview](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/whats-new)  
- [Configure Remote Help in Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remote-help)  
- [Remote Help Licensing](https://learn.microsoft.com/en-us/mem/intune/fundamentals/remote-help)
