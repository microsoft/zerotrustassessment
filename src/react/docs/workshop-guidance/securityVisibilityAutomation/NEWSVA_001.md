# Design and plan Microsoft Defender for Identity deployment
**Implementation Effort:** Medium

**User Impact:** Medium

## Overview

**General Prerequisites**
* **Licensing.** Enterprise Mobility + Security E5/A5, ‎Microsoft 365‎ E5/A5/G5, ‎Microsoft 365‎ E5/A5/G5 Security, or ‎Defender for Identity‎ standalone.
* **Credentials.** A ‎Microsoft Entra ID‎ tenant with at least one global administrator or security administrator.
* **Firewall requirements.** We recommend using a proxy server instead of allowing direct outbound connectivity to the internet through TCP port 443 and allowing sensors to access through that proxy only your dedicated ‎Defender for Identity‎ cloud service.
* **We recommend that you open all [required ports](https://learn.microsoft.com/defender-for-identity/deploy/prerequisites#required-ports)**
* **Server requirements**
  * Windows‎ Server 2016 or later. For optimal performance, set the power option of the device running a ‎Defender for Identity‎ sensor to high performance.
  * .NET Framework 4.7 or later.
  * Minimum of 2 cores and 6 GB of RAM installed on the domain controller.
  * Minimum of 6 GB disk space is required (10 GB is recommended).
* **Windows‎ events.** Domain controller, ‎AD FS‎, or ‎AD CS‎ events should be turned on to gain the maximum level of protection from the product. For the list of ‎Windows‎ events, see [Configure ‎Windows‎ Event collection.](https://learn.microsoft.com/defender-for-identity/configure-windows-event-collection)
* **Create a Directory Service account (DSA).** Defender uses DSAs to connect to on-premises directories and perform tasks like reading information and resetting passwords. See [‎Microsoft Defender for Identity‎ Directory Service account recommendations](https://learn.microsoft.com/defender-for-identity/directory-service-accounts) to learn more.
* **Configure remote calls to Security Account Manager (SAM).** Lateral movement path detection in Defender relies on queries that identify local admins on specific machines. These queries are performed with the Security Account Manager Remote (SAM-R) protocol, using the DSA you configured. See [Configure SAM-R to enable lateral movement path detection in ‎Microsoft Defender for Identity‎] (https://learn.microsoft.com/defender-for-identity/remote-calls-sam) to learn more.
* **Plan capacity.** Use the [sizing tool](https://github.com/microsoft/ATA-AATP-Sizing-Tool) to plan capacity.
* **Network name resolution.** For best results, we recommend using all of the methods. If this isn't possible, you should use the DNS lookup method and at least one of the other methods. To learn more, see [What is Network Name Resolution?] (https://learn.microsoft.com/defender-for-identity/nnr-policy#prerequisites)
* **Test your prerequisites.** We recommend running the [Test-MdiReadiness.ps1](https://learn.microsoft.com/defender-for-identity/deploy/prerequisites#test-your-prerequisites) script in ‎PowerShell‎. The script will query your domain, domain controllers, and Certificate Authority (CA) servers to report whether the ‎Defender for Identity‎ prerequisites are in place.

## Reference
* https://learn.microsoft.com/en-us/defender-for-identity/deploy/prerequisites
* https://learn.microsoft.com/en-us/defender-for-identity/deploy/capacity-planning
* https://admin.microsoft.com/Adminportal/Home?Q=ADG#/modernonboarding/microsoftdefenderforidentitysetupguide
