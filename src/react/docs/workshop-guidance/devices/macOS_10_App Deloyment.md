# App Deployments

**Last Updated:** May 2025  
**Implementation Effort:** Medium – Deploying apps to macOS devices in Intune requires planning, packaging (e.g., .pkg format), testing, and configuring deployment assignments and dependencies.  
**User Impact:** Medium – Users may need to restart devices, accept prompts, or adjust settings depending on the app type and deployment method.

## Introduction

Application deployment is a critical part of managing macOS devices in Intune. It ensures users have access to the tools they need while maintaining control over what software is installed and how it’s updated. Intune supports multiple app types for macOS, including Microsoft 365 apps, PKG installers, line-of-business (LOB) apps, and web links. From a Zero Trust perspective, app deployment is about **ensuring only trusted, approved software is delivered to compliant devices**—and that software inventory is visible and manageable.

This section helps macOS administrators evaluate their app deployment strategy and align it with Zero Trust principles—particularly around software integrity, access control, and user productivity.

## Why This Matters

- **Ensures only approved apps are installed** on managed devices.
- **Reduces attack surface** by limiting exposure to unmanaged or unvetted software.
- **Supports Zero Trust** by enforcing app-level access control and visibility.
- **Improves user experience** by automating app delivery and updates.
- **Enables auditability** of app inventory and deployment status.

## Key Considerations

### Microsoft 365 Apps for macOS

- Intune provides a built-in option to deploy Microsoft 365 apps (Word, Excel, Outlook, etc.) as a suite.
- You can configure which apps to include and whether to auto-update.

From a Zero Trust perspective: Ensures that productivity tools are deployed from a **trusted source**, with **centralized update control** and **license compliance**.

### PKG Apps

- PKG files are the standard macOS installer format and are fully supported by Intune.
- Most vendor-provided PKGs (e.g., Chrome, Edge) are already **code-signed** with a trusted Apple Developer ID.

From a Zero Trust perspective: Always **verify the source** of the PKG and ensure it is obtained directly from the vendor or a trusted internal source to maintain **software integrity**.

### Line-of-Business (LOB) Apps

- Custom or internal apps can be deployed as LOB apps using signed PKG files.
- These apps should be signed with a trusted Apple Developer ID.

From a Zero Trust perspective: LOB apps must be **vetted, signed, and distributed securely** to prevent supply chain risks.

### Web Links

- Intune can deploy web links as pseudo-apps that appear in Launchpad or the Dock.
- Useful for directing users to internal portals, SaaS apps, or support resources.

From a Zero Trust perspective: Web links provide **controlled access to web-based tools** without requiring local installation.

### Assignment and Targeting

- Use **required**, **available**, or **uninstall** assignments to control app lifecycle.
- Scope apps using **dynamic groups** or **filters** based on device ownership, compliance, or user role.

From a Zero Trust perspective: This supports **least privilege** by ensuring users only receive the apps they need.

### Monitoring and Remediation

- Use the **Intune admin center** to monitor app deployment status and troubleshoot failures.
- While Intune does not block unmanaged app installations on macOS, you can **audit installed apps** and use **device restrictions** to limit App Store access.

From a Zero Trust perspective: Visibility into app health supports **continuous trust** and **policy enforcement**.

## Zero Trust Considerations

- **Verify explicitly**: Apps deployed through Intune are trusted and auditable; others should be monitored.
- **Assume breach**: Preventing reliance on user-installed apps reduces the risk of malware or data leakage.
- **Least privilege**: Users receive only the apps they need, based on role and device compliance.
- **Continuous trust**: App deployment status is monitored and enforced continuously.
- **Defense in depth**: App control complements device compliance, Conditional Access, and endpoint protection.

## Recommendations

- **Use Microsoft 365 app deployment** for all corporate productivity tools.
- **Deploy PKG apps only after verifying source and signature** to ensure integrity.
- **Assign apps based on role, compliance, and device ownership** using filters and dynamic groups.
- **Monitor app deployment status** and remediate failures proactively.
- **Restrict App Store access** where appropriate using device restrictions.
- **Audit installed apps** regularly to identify unmanaged or risky software.

## References

- [Deploy Microsoft 365 Apps for macOS](https://learn.microsoft.com/en-us/mem/intune/apps/apps-add-office365)  
- [Add PKG Apps to Intune](https://learn.microsoft.com/en-us/mem/intune/apps/lob-apps-macos)  
- [Deploy Web Links as Apps](https://learn.microsoft.com/en-us/mem/intune/apps/web-apps)  
- [Monitor App Install Status](https://learn.microsoft.com/en-us/mem/intune/apps/apps-monitor)
