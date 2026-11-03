# Windows 365: Conditional Access

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Conditional Access is the primary policy engine for controlling who can connect to Windows 365 Cloud PCs and under what conditions. A mature design evaluates user identity, sign-in risk, location, device state, and authentication strength before the connection is allowed.

Because Cloud PCs often provide access to sensitive corporate data, Conditional Access should be treated as a layered control: user protection policies, device trust requirements for administrators and privileged users, and session restrictions where business requirements permit less-trusted endpoints.

## Implementation Guidance

1. Inventory the Windows 365 access paths in your tenant before creating policy. Identify whether users connect through Windows 365 web experiences, Windows App or Remote Desktop clients, and whether you also need to account for related apps such as Windows Cloud Login. Verify the exact current enterprise application names in your tenant before documenting them broadly.
2. In the Microsoft Entra admin center, build a pilot Conditional Access policy for a test group. Start with baseline controls such as requiring multifactor authentication, blocking legacy or unsupported sign-in paths, and excluding emergency access accounts.
3. Add stronger controls for higher-risk populations. Require compliant devices or phishing-resistant authentication for administrators, developers, and users accessing regulated data. Where the business allows less-trusted endpoints, consider session controls or alternative access paths rather than granting unrestricted full access.
4. Use report-only mode first, then review Entra sign-in logs and Windows 365 access behavior. Validate successful connections from expected clients and confirm that blocked scenarios generate understandable results for users and support staff.
5. Document the policy interaction with Intune compliance and Windows 365 provisioning. A Cloud PC access decision should align with how devices are joined, how users authenticate, and what support workflow exists when a user is denied access.

## Reference

- **[Set Conditional Access policies for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/set-conditional-access-policies)** — Explains how to configure Microsoft Entra Conditional Access policies for Windows 365 Cloud PCs.
- **[Plan Your Microsoft Entra Conditional Access Deployment - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)** — Provides planning guidance for designing and rolling out Conditional Access policies.
- **[How to Require Device Compliance with Conditional Access - Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-device-compliance)** — Explains how to require compliant devices as a Conditional Access control.
