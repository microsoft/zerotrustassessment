# Windows 365: Provisioning Options

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Provisioning policies are the control plane for Windows 365 Cloud PC deployment. They define how the Cloud PC is built: network model, join type, image, region, and which user groups receive that configuration. A clear provisioning strategy is essential because a policy mistake can block large numbers of users from receiving a Cloud PC.

For Zero Trust, provisioning is the stage where administrators decide what a “trusted default Cloud PC” looks like. Join model, image choice, and network architecture should reflect the organization’s least-privilege and verified-access design.

## Implementation Guidance

1. Before creating a provisioning policy, validate prerequisites: licensing, supported identity model, network readiness, image availability, and group design. Most Windows 365 provisioning issues are dependency problems rather than policy-click errors.
2. In the Microsoft Intune admin center, create separate provisioning policies for materially different scenarios, such as Microsoft Entra joined versus hybrid joined Cloud PCs or Microsoft-hosted network versus ANC. Clear separation makes troubleshooting and change management far easier.
3. Assign the intended image, region or network, and target user groups carefully. Avoid reusing a generic policy for every workload if different business units have different application or identity requirements.
4. Use small pilot groups first. Confirm successful provisioning, user sign-in, Cloud PC naming, Intune enrollment, update behavior, and application availability before expanding assignment to larger populations.
5. Monitor provisioning status actively after rollout. Build an operational checklist for failed provisioning, including ANC health, image readiness, licensing, and group membership validation.

## Reference

- **[Create provisioning policies for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)** — Explains how to create provisioning policies for Windows 365 Cloud PCs.
- **[Troubleshoot provisioning errors - Windows 365](https://learn.microsoft.com/en-us/troubleshoot/windows-365/provisioning-errors)** — Provides troubleshooting guidance for Windows 365 Cloud PC provisioning failures.
- **[Windows 365 requirements](https://learn.microsoft.com/en-us/windows-365/enterprise/requirements)** — Lists the technical, licensing, and configuration prerequisites for Windows 365.
