# Windows 365: Regions

**Implementation Effort:** Low  
Selecting a region is typically a one-time configuration during provisioning and does not require ongoing administrative effort.

**User Impact:** Low  
Users are not directly affected by region selection unless performance or compliance issues arise, so no user action or notification is needed.

## Overview

Windows 365 uses Azure regions to host Cloud PCs, and the region is determined by the virtual network selected during provisioning. For Microsoft-hosted networks, region selection is automatic, but for customer-managed networks, admins must choose an Azure region that aligns with their network and compliance needs. Microsoft recommends using the **Automatic** option to ensure optimal availability and capacity. Region selection affects latency, data residency, and regulatory compliance. If the wrong region is selected, users may experience degraded performance or the organization may face compliance risks.

This capability supports the Zero Trust principle of **\"Assume breach\"** by enabling geographic segmentation and data residency controls, which help reduce the blast radius in case of a security incident.

## Reference

- [Windows 365 requirements](https://learn.microsoft.com/en-us/windows-365/enterprise/requirements)

- [Windows 365 architecture](https://learn.microsoft.com/en-us/windows-365/enterprise/architecture)
