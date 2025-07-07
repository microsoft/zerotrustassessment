# Resource Access (Certificates, VPN, Network Config)

**Last Updated:** May 2025  
**Implementation Effort:** Medium – IT must create and assign VPN profiles, manage certificate deployment, and ensure compatibility with third-party VPNs.  
**User Impact:** Low – Profiles are silently deployed to managed devices; no user interaction is typically required.

---

## Introduction

Resource access profiles in Intune allow administrators to configure secure access to corporate resources such as Wi-Fi networks, VPNs, and internal services using certificate-based authentication. For macOS, these profiles are essential for enforcing secure, password-less access and ensuring that only compliant, trusted devices can connect to sensitive infrastructure.

This section helps macOS administrators evaluate their current resource access configurations and align them with Zero Trust principles—particularly around access control, device trust, and secure authentication.

---

## Why This Matters

- Enables secure, certificate-based access to corporate networks and services.
- Reduces reliance on passwords, which are more susceptible to phishing and reuse.
- Supports Zero Trust by ensuring access is conditional on device compliance and identity.
- Improves user experience by automating network and VPN configuration.
- Prevents misconfiguration by centrally managing access profiles.

---

## Key Considerations

### Wi-Fi Profiles

- Configure SSID, security type (e.g., WPA2/WPA3 Enterprise), and authentication method.
- Use certificate-based authentication (via SCEP or PKCS) to eliminate password prompts and reduce the risk of credential theft.

> From a Zero Trust perspective:  
> This ensures that only trusted, compliant devices with valid certificates can connect to corporate networks, enforcing **explicit verification** and **device trust** at the network edge.

---

### VPN Profiles

- Define VPN connection types (e.g., IKEv2), server addresses, and authentication methods.
- Use certificates for authentication where possible to avoid shared secrets or weak credentials.

> From a Zero Trust perspective:  
> VPN access should be conditional and identity-aware. Certificate-based VPN profiles help enforce **least privilege** and **secure access** to internal resources, especially for remote users.

---

### Certificate Deployment

- Use SCEP or PKCS profiles to deploy user or device certificates.
- Deploy trusted root certificates to validate internal services and establish secure trust chains.

> From a Zero Trust perspective:  
> Certificates are foundational to **strong authentication** and **continuous trust evaluation**.

---

### Profile Assignment Strategy

- Use dynamic groups or filters to assign access profiles based on device ownership, compliance state, or user role.
- Avoid assigning resource access profiles to unmanaged or non-compliant devices.

> From a Zero Trust perspective:  
> This supports **least privilege access** by ensuring that only the right users and devices receive access to sensitive network configurations.

---

### Monitoring and Troubleshooting

- Use the Intune admin center to monitor profile deployment status.
- Validate that certificates are issued and profiles are applied before users attempt to connect.

> From a Zero Trust perspective:  
> Visibility into access provisioning is critical for **continuous trust**. Monitoring ensures that misconfigured or non-compliant devices are identified and remediated before they can access protected resources.

---

### BYOD Considerations

- For BYOD macOS devices, consider limiting access to internal resources unless certificate-based authentication is in place.
- Avoid deploying VPN or Wi-Fi profiles to personal devices unless explicitly required and secured.

> From a Zero Trust perspective:  
> BYOD devices are inherently less trusted. Limiting their access unless they meet strict authentication and compliance requirements supports **risk-based access control** and **assumes breach** by default.

---

## Zero Trust Considerations

- **Verify explicitly**: Access to Wi-Fi, VPN, and internal services is granted only after verifying device compliance and certificate trust.  
- **Assume breach**: Certificate-based authentication reduces the risk of credential theft and lateral movement.  
- **Least privilege**: Resource access profiles are scoped to specific users and devices based on business need and compliance status.  
- **Continuous trust**: Access is conditional on the device maintaining compliance and holding valid certificates.  

---

## Recommendations

- Use certificate-based authentication for all Wi-Fi and VPN access to eliminate password risks.  
- Deploy certificates first, then assign dependent VPN/Wi-Fi profiles to avoid provisioning issues.  
- Assign access profiles only to compliant, corporate-managed macOS devices.  
- Use filters or dynamic groups to scope access based on device role or ownership.  
- Monitor deployment status and validate certificate issuance before enabling access.  
- Limit access for BYOD devices unless strong authentication and compliance enforcement are in place.  

---

## References

- [Configure Certificates for macOS in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure://learn.microsoft.com/en-us/mem/intune/configfigure Wi-Fi Profiles for macOS](https://learn.microsoft.com/en-us/ms-macos  
- [Use SCEP and PKCS Certificates in Intune](https://learn.microsoft.com/en-us/mem/intune/protect