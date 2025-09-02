# Windows 365: Network Options

**Implementation Effort:** Medium  
IT admins must choose between
Microsoft-hosted or customer-managed networking, with setup and policy
configuration required for either option.

**User Impact:** Low  
Network configuration is transparent to end
users; no user action or communication is required.

# Overview

Windows 365 offers two main network deployment options:
**Microsoft-hosted network** and **Azure Network Connection (ANC)**.

- The Microsoft-hosted option is a fully managed SaaS model where Microsoft handles all networking infrastructure, ideal for organizations seeking simplicity and rapid deployment. It supports Microsoft Entra join and requires no Azure subscription or networking expertise.

- The ANC option allows organizations to use their own Azure virtual networks, offering more control and integration with on-premises infrastructure, and supports both Microsoft Entra join and hybrid join.

Choosing the right network model is critical for performance, security, and compliance. Misconfiguration or improper planning---especially with ANC---can lead to connectivity issues, policy misalignment, or exposure to threats. This capability supports the Zero Trust principle of **Assume breach**, as Microsoft-hosted networks are built with end-to-end security controls, and ANC allows for granular policy enforcement and segmentation.

## Reference

- [Windows 365 deployment options](https://learn.microsoft.com/en-us/windows-365/enterprise/deployment-options)
- [Network requirements for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/requirements-network)
- [Windows 365 architecture](https://learn.microsoft.com/en-us/windows-365/enterprise/architecture)
