# Conditional Access Policies

**Implementation Effort:** Medium
**User Impact:** Medium — users may be prompted for MFA, blocked from resources, or required to enroll depending on policy scope.

## Overview
Conditional Access is the main enforcement layer that turns macOS management and compliance signals into access decisions. For Mac scenarios, the most durable baseline is to require strong user authentication and a compliant, appropriately managed device for high-value resources, then add role-based or app-based controls where risk or data sensitivity warrants it.

## Implementation Guidance
1. Define the baseline access rule first: which apps require a compliant Mac, which apps can be accessed from unmanaged Macs with extra controls, and which roles require stronger authentication.
2. In the Microsoft Entra admin center, create Conditional Access policies in report-only mode first and scope them by users, apps, and macOS conditions.
3. Require MFA and, for sensitive apps, require the device to be marked as compliant. Avoid layering unnecessary conditions until the access flow is understood.
4. Use a pilot group to validate browser experience, native app experience, Company Portal prompts, and sign-in log details.
5. Only after report-only validation should the baseline policy move to On for production users.

## Reference
- **[Plan Your Microsoft Entra Conditional Access Deployment - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)** — Covers pilot, rollout, exclusions, and operational planning for Conditional Access.
- **[Microsoft Entra Conditional Access: Zero Trust Policy Engine - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)** — Explains Conditional Access grant controls, including requiring devices to be marked compliant.
- **[Sign-in logs in Microsoft Entra ID - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-ins)** — Explains how to review sign-in activity and investigate authentication events.
