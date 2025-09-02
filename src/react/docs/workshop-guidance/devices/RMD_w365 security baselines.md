# Windows 365: Security Baselines

**Implementation Effort:** Medium  
Deploying security baselines requires IT and security teams to review, customize, and assign policy profiles via Intune, with periodic updates and testing.

**User Impact:** Low  
Security baselines are applied silently to Cloud PCs; users are not required to take action or be notified unless specific settings impact usability.

## Overview

Windows 365 Security Baselines are preconfigured sets of security policies designed to enforce best practices across Cloud PCs. These baselines cover Windows 10/11, Microsoft Edge, and Microsoft Defender for Endpoint, and are managed through Microsoft Intune. Each baseline version (e.g., 24H1) includes default configurations that can be customized to meet organizational needs. Admins can assign these baselines to device groups, ensuring consistent security posture across the Cloud PC fleet.

Security baselines help reduce risk by enforcing settings like credential protection, firewall rules, and browser hardening. They also support versioning, allowing organizations to adopt new recommendations over time. If not deployed, Cloud PCs may remain misconfigured or exposed to known threats due to inconsistent or outdated security settings.

This capability supports the Zero Trust principle of **\"Use least privilege access\"** by enforcing strict, role-appropriate configurations and reducing the attack surface.

## Reference

- [Windows 365 Cloud PC security baseline settings reference](https://learn.microsoft.com/en-us/intune/intune-service/protect/security-baseline-settings-windows-365)
- [Security baselines guide](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)
