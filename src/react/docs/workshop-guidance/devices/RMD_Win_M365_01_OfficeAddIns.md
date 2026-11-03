# Office Add-ins

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Office extensibility can improve user productivity, but it introduces a meaningful trust boundary on managed endpoints. Modern web-based Office Add-ins are generally easier to govern than legacy COM, VSTO, or macro-heavy customizations because they rely more on cloud identity, service permissions, and centralized deployment models.

A Zero Trust approach should favor modern add-ins wherever possible, inventory and justify legacy add-ins explicitly, and apply strong controls to macro and code-execution paths that remain necessary for business reasons.

## Implementation Guidance

1. Inventory the Office add-ins and macro-enabled solutions currently in use. Separate modern web add-ins from COM, VSTO, and VBA-dependent solutions so you know which items can be governed centrally and which require endpoint-level controls or retirement planning.
2. For modern add-ins, use Microsoft 365 administrative deployment and app-governance processes. Require publisher review, business ownership, and permission review before broad deployment. Limit deployment to the user groups that actually need each add-in.
3. For legacy add-ins and VBA scenarios that must remain, use Intune-managed Windows controls to reduce risk. This can include security baselines, Attack Surface Reduction rules, macro security settings, application control, and least-privilege local rights so legacy components do not run with unnecessary power.
4. Block or phase out unsupported, unsigned, or low-value legacy add-ins. A formal exception path should exist for business-critical cases, with security review and a retirement timeline where feasible.
5. Test Office client updates and add-in compatibility together. Productivity add-ins often fail during change windows if deployment owners are not included in patch or baseline validation.

## Reference

- **[Deploy Office Add-ins in the Microsoft 365 admin center - Microsoft 365 admin](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-deployment-of-add-ins)** — Shows how to deploy Office Add-ins to users from the Microsoft 365 admin center.
- **[Macros from the internet are blocked by default in Office  - Microsoft 365 Apps](https://learn.microsoft.com/en-us/microsoft-365-apps/security/internet-macros-blocked)** — Explains current Office macro security behavior and how internet-downloaded macros are blocked.
- **[ASR rules reference - Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference)** — Provides the reference details for Microsoft Defender attack surface reduction rules.
