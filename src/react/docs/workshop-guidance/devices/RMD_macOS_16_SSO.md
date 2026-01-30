# Single Sign-On (SSO)

**Last Updated:** Jan 2026  
**Implementation Effort:** Medium – Requires Intune profile configuration and deployment, but no ongoing user or infrastructure changes.  
**User Impact:** Low – Users benefit from seamless sign-in without needing to take action.

---
## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/blJ9O5jT0UM?si=phmvfKG01fpqn9lT" title="YouTube video player" frameborder="0" allow="accelerometer; fullscreen; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Introduction

Single Sign-On (SSO) enables macOS users to authenticate once and gain seamless access to corporate apps and services without repeated credential prompts. In Intune-managed macOS environments, Microsoft supports multiple SSO mechanisms, including the **Enterprise SSO plug-in**, **Platform SSO**, and **Kerberos SSO**. These technologies reduce friction, improve security, and support Zero Trust by enforcing strong, identity-based access controls.

This section helps administrators understand and evaluate the available SSO options for macOS and how to align them with Zero Trust principles.

---

## Why This Matters

- **Reduces password fatigue** and improves user experience.  
- **Supports passwordless and phishing-resistant authentication**.  
- **Enables Conditional Access enforcement** across apps and browsers.  
- **Strengthens identity assurance** by binding authentication to the device.  
- **Supports Zero Trust** by ensuring that access is based on verified identity and device trust.  

---

## Key Considerations

### Platform SSO (Microsoft Entra ID)

- Introduced in macOS 13+ and enhanced in macOS 14.6+.
- Allows users to sign in to their Mac using **Microsoft Entra ID credentials**, **Touch ID**, or **smart cards**.
- Recommended: **Secure Enclave-backed authentication**, which provisions a hardware-bound cryptographic key for phishing-resistant, passwordless authentication.
- Does not sync Entra ID password with the local account.
- Acts as broker for **Conditional Access**, **device compliance**, and **Workplace Join (WPJ)** certificate-based authentication.

> From a Zero Trust perspective:  
> Platform SSO with Secure Enclave ensures **phishing-resistant, hardware-bound authentication**, and guarantees that access is granted only to **verified users on compliant devices**.

[Learn more](https://learn.microsoft.com/en-us/entra/identity/devices/macos-psso)

---

### SSO App Extension (Enterprise SSO Plug-in)

- Enables SSO to Microsoft Entra ID-protected apps and websites using the native macOS authentication framework.
- Supports **Safari**, **Edge**, and **Chrome** (with the Microsoft SSO extension).
- Deployable via Intune using a configuration profile or settings catalog.

> From a Zero Trust perspective:  
> The SSO app extension ensures **consistent identity enforcement** across apps and browsers, reducing the risk of credential reuse or bypass.

[Learn more](https://learn.microsoft.com/en-us/intune/intune-service/configuration/use-enterprise-sso-plug-in-macos-with-intune)

---

### Kerberos SSO (via Platform SSO)

- Supports access to **on-premises Active Directory resources**.
- Useful for hybrid environments.
- Requires configuration of a **Kerberos SSO MDM profile** and deployment of **Microsoft Entra Kerberos** for cloud-based Kerberos trust.

> From a Zero Trust perspective:  
> Kerberos SSO enables **secure, token-based access** to legacy resources without exposing passwords, supporting **least privilege** and **identity assurance**.

[Learn more](https://learn.microsoft.com/en-us/entra/identity/devices/device-join-macos-platform-single-sign-on-kerberos-configuration)

---

## Browser Support and Deployment

- **Safari** supports SSO natively.  
- **Chrome** and **Edge** require the **Microsoft Enterprise SSO extension**, deployable via Intune using a managed preference (.plist).  
- Ensure the extension is force-installed and configured for seamless authentication.

---

## Device and OS Requirements

- Platform SSO requires:
  - macOS 13.0 or later (macOS 14.6+ for Kerberos SSO)
  - Intune Company Portal version 5.2404.0 or later
  - Microsoft Entra ID (formerly Azure AD)
- Devices must be **Entra-joined** and enrolled in Intune to enable full SSO capabilities.

---

## Zero Trust Considerations

- **Verify explicitly**: Access is granted only after verifying both user identity and device trust.  
- **Assume breach**: Passwordless and certificate-based SSO reduces the risk of phishing and credential theft.  
- **Least privilege**: SSO tokens are scoped and time-bound, reducing the risk of long-lived access.  
- **Continuous trust**: SSO integrates with Conditional Access and compliance policies to continuously evaluate trust.  
- **Defense in depth**: SSO complements other identity and device controls, ensuring layered protection across the authentication stack.  

---

## Recommendations
- **Deploy Platform SSO** with Secure Enclave for all supported macOS devices.  
- **Use the SSO app extension** to enforce consistent identity across browsers and apps.  
- **Configure Kerberos SSO** if users require access to on-premises Active Directory resources.  
- **Ensure browser support** by deploying the Microsoft SSO extension for Chrome and Edge.  
- **Use phishing-resistant credentials** (e.g., Touch ID, smart cards) where possible.  
- **Monitor SSO usage and failures** to detect anomalies and improve user experience.  

---

## References

- [Configure Platform SSO for macOS](https://learn.microsoft.com/en-us/intune/intune-service/configuration/platform-sso-macos)  
- [Configure Kerberos SSO with Platform SSO](https://learn.microsoft.com/en-us/entra/identity/devices/device-join-macos-platform-single-sign-on-kerberos-configuration)  
- [Configure Enterprise SSO App Extension](https://learn.microsoft.com/en-us/intune/intune-service/configuration/use-enterprise-sso-plug-in-macos-with-intune)
