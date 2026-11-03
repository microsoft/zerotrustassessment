# Compliance Policies

**Implementation Effort:** Medium
**User Impact:** Medium — users may lose access until they remediate encryption, password, or OS version issues.

## Overview
Compliance policies define what a trusted macOS device must look like before it can access protected resources. They should measure the organization's minimum security expectations and be paired with user-friendly remediation, reporting, and Conditional Access so noncompliant Macs are guided toward repair rather than left in an unclear blocked state.

## Implementation Guidance
1. Define the baseline conditions for trusted Macs and review each available built-in compliance setting against current Microsoft support documentation.
2. Create a dedicated macOS compliance policy in the Microsoft Intune admin center rather than reusing Windows or mobile assumptions.
3. Customize actions for noncompliance and user messaging so users understand what failed and what to do next.
4. Connect the policy to Conditional Access gradually: first test reporting and remediation, then enforce access blocks for targeted resources.
5. Use device compliance reports and help-desk feedback to tune thresholds, grace periods, and instructions.

## Reference
- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Describes compliance policy settings, supported actions, and platform coverage including macOS.
- **[Microsoft Entra Conditional Access: Zero Trust Policy Engine - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)** — Explains Conditional Access grant controls, including requiring devices to be marked compliant.
