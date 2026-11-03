# Windows 365: Network Options

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Windows 365 networking design is one of the most important architectural choices in a Cloud PC deployment. Administrators must decide whether to use Microsoft-hosted networking for speed and simplicity or Azure network connection (ANC) for tighter integration with existing virtual networks and on-premises resources.

The right answer depends on application dependencies, identity model, inspection requirements, regional placement, and operational maturity. A Zero Trust workshop should emphasize choosing the simplest network model that still satisfies documented business and security needs.

## Implementation Guidance

1. Start with application and identity requirements. If users only need cloud services and Microsoft Entra joined Cloud PCs, Microsoft-hosted network is often the fastest and lowest-friction option. If workloads require customer-controlled routing or access to private network resources, ANC may be necessary.
2. For Microsoft-hosted networking, validate supported regions, identity assumptions, and any traffic inspection or egress requirements. Document what network controls move to Microsoft versus what remains the tenant’s responsibility.
3. For ANC, verify Azure virtual network design, IP space, DNS, line-of-sight to required services, and capacity planning before you create provisioning policies. ANC failures are a common cause of deployment delays.
4. Create separate provisioning policies for each network model so image, identity, and user assignments remain clear. Do not hide network complexity inside a single broad policy if different user groups have different dependencies.
5. Pilot both performance and supportability. Measure user experience, connection reliability, provisioning success, and the operational overhead of each model before standardizing on one approach.

## Reference

- **[Windows 365 planning guide](https://learn.microsoft.com/en-us/windows-365/enterprise/planning-guide)** — Provides planning guidance, including how to evaluate Windows 365 network options.
- **[Azure network connection overview](https://learn.microsoft.com/en-us/windows-365/enterprise/azure-network-connections)** — Explains Azure network connection concepts and management for Windows 365.
- **[Create provisioning policies for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)** — Explains how to create provisioning policies for Windows 365 Cloud PCs.
