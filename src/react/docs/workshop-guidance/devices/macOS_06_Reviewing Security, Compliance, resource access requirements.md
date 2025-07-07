# Reviewing Security, Compliance, and Resource Access Requirements

**Last Updated:** May 2025  
**Implementation Effort:** Medium – This task involves defining and applying compliance policies, configuring security baselines, and integrating with Conditional Access, which requires coordination across IT and security teams.  
**User Impact:** Medium – Users may be required to update their OS, change passwords, or adjust device settings to meet compliance requirements, and may temporarily lose access to resources if non-compliant.

## Introduction

Whether you're just beginning your macOS Intune journey or re-evaluating an existing deployment, understanding your organization’s **Intune compliance policies** and **resource access configurations** is foundational. This section helps macOS administrators align their Intune setup with Zero Trust principles by identifying what needs to be protected, how compliance is enforced, and how secure access to organizational resources is provisioned.

This guidance is tailored for macOS environments managed through **native Intune features only**.

## Why This Matters

- **Establishes the foundation** for Conditional Access and Zero Trust enforcement.
- **Ensures only compliant macOS devices** can access corporate resources like Wi-Fi, VPN, and internal services.
- **Reduces risk** by enforcing device health and configuration baselines.
- **Improves user experience** by automating secure access to resources without manual configuration.
- **Supports continuous evaluation** of device trust and access posture.

## How to Review These Areas Through a Zero Trust Lens

### 🔐 Security (Device Health & Configuration)

- Are all macOS devices required to meet a minimum security baseline (e.g., FileVault, password policy, OS version)?
- Are these baselines enforced using **Intune compliance policies**?
- Are non-compliant devices blocked from accessing corporate resources?

### ✅ Compliance (Intune Compliance Policies)

- Do your compliance policies reflect your current security posture and risk tolerance?
- Are policies scoped appropriately for different device types (corporate vs. BYOD)?
- Are compliance states feeding into Conditional Access policies to enforce access control?

### 🌐 Resource Access (Wi-Fi, VPN, Certificates)

- Are Wi-Fi and VPN profiles deployed using **certificate-based authentication**?
- Are certificates deployed using **SCEP or PKCS** profiles, and are they assigned before dependent profiles?
- Are access profiles segmented by user role, device ownership, or compliance state?
- Are you using **Conditional Access** to ensure only compliant macOS devices can access sensitive services?

This structured review ensures that your environment is not only configured correctly but also continuously evaluated and adaptable—core to the Zero Trust model.

## Key Considerations

### Compliance Policies for macOS

- Use Intune compliance policies to define minimum security baselines (e.g., FileVault enabled, password requirements, OS version).
- Devices that fail to meet these baselines are marked non-compliant and can be blocked from accessing resources via Conditional Access.

### Resource Access Configuration

- **Wi-Fi Profiles**: Configure SSID, security type (e.g., WPA2/WPA3 Enterprise), and authentication method. Use certificate-based authentication for secure, password-less access.
- **VPN Profiles**: Define VPN connection types (e.g., IKEv2), server addresses, and authentication methods. Certificates are recommended for authentication.
- **Certificates**:
  - Use **SCEP** or **PKCS** profiles to deploy user or device certificates.
  - Deploy **trusted root certificates** to establish trust for internal services.
  - Ensure certificate profiles are deployed before dependent Wi-Fi or VPN profiles.

### Profile Assignment

- Assign based on device ownership (corporate vs. BYOD), user group, or compliance state.
- Use dynamic groups to automate targeting based on device attributes.

### Dependency Management

- Resource access profiles often depend on certificates. Ensure certificate deployment is successful before assigning VPN/Wi-Fi profiles.
- Monitor deployment status in the Intune admin center to troubleshoot failures.

### Conditional Access Integration

- Combine compliance policies with Conditional Access to enforce access control.
- Example: Block access to Microsoft 365 unless the macOS device is compliant and has a valid certificate for VPN.

## Zero Trust Considerations

This section directly supports the following Zero Trust principles:

- **Verify Explicitly**: Access to Wi-Fi, VPN, and internal services is granted only after verifying device compliance and certificate trust.
- **Assume Breach**: By requiring compliant, certificate-authenticated devices, you reduce the risk of unauthorized access even if credentials are compromised.
- **Least Privilege**: Resource access profiles are scoped to specific users and devices based on business need and compliance status.

## Recommendations

- **Define and deploy compliance policies** for macOS that reflect your organization’s security baseline.
- **Use certificate-based authentication** for all Wi-Fi and VPN access to eliminate password risks.
- **Deploy certificates first**, then assign dependent VPN/Wi-Fi profiles to avoid provisioning issues.
- **Use dynamic groups** to automate profile targeting based on device ownership or compliance state.
- **Review compliance and access configurations quarterly** to ensure alignment with evolving security needs.
- **Use the Zero Trust review checklist** above to guide regular audits of your Intune macOS environment.

## References

- [Microsoft Intune Compliance Policies](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create)  
- [Configure VPN and Wi-Fi Profiles in Intune](https://learn.microsoft.com/en-us/intune/configuration/vpn-settings-configure)  
- [Certificates for macOS in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/certificates-configure)  
- [Conditional Access Overview](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/overview)
