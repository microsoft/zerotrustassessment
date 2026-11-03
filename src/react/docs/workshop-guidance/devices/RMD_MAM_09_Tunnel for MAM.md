# Tunnel for MAM

**Implementation Effort:** High

**User Impact:** Medium

## Overview
Microsoft Tunnel for Mobile Application Management extends private-resource access to supported managed apps on unenrolled devices. Instead of routing the whole device through VPN, it provides per-app access for apps that are integrated with the required Intune and authentication components.

This is a strong Zero Trust pattern for BYOD scenarios where the organization needs access to private web apps or APIs without requiring full device enrollment. It reduces exposure by limiting network access to approved apps and by keeping the control at the work-identity and app layer.

## Implementation Guidance
1. Confirm prerequisites first: Microsoft Tunnel gateway infrastructure, supported client apps or line-of-business apps with the required SDK integration, Microsoft Entra app registrations where needed, and any platform-specific dependencies documented by Microsoft.
2. In the Intune admin center, deploy or review the **Microsoft Tunnel Gateway** configuration and the relevant tunnel site and server health before designing the MAM experience.
3. Create the required app protection policy and any app configuration policies for the apps that will use Tunnel for MAM. Also configure Conditional Access so only the intended apps and users can reach the private resources.
4. If Microsoft Edge or a line-of-business mobile app is the private-resource entry point, test that app specifically with the target platform, sign-in method, and policy set. Tunnel for MAM is scenario-driven and should not be documented as a generic VPN toggle.
5. Pilot with a small BYOD population, validate per-app connectivity to the private resource, verify user prompts, and capture troubleshooting guidance before broad rollout.
6. Document operational ownership: who maintains the tunnel infrastructure, who updates supported app configuration, and how outages or certificate problems are escalated.

## Reference
- **[Microsoft Tunnel for Mobile Application Management - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-tunnel/mam)** — Explains how to use Microsoft Tunnel with unenrolled devices protected by MAM.
- **[Microsoft Tunnel for Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-tunnel/overview)** — Provides the product overview, architecture, and deployment concepts for Microsoft Tunnel.
- **[Use app-based Conditional Access policies with Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/conditional-access-integration/app-based-policies)** — Explains how app-based Conditional Access works with Intune app protection policies.
