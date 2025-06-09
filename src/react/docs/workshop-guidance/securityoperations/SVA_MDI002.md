# Install Microsoft Defender for Identity (MDI) Sensors on All Domain Controllers

**Implementation Effort:** High  
Installing MDI sensors requires coordination across all domain controllers, including read-only ones, and may involve proxy configuration, certificate validation, and integration with Microsoft Defender for Identity cloud services.

**User Impact:** Medium  
While end users are not directly impacted, IT and security teams must coordinate across multiple systems, and some alerts or investigations may involve notifying specific users or teams.

---

## Overview

Installing Microsoft Defender for Identity (MDI) sensors on all domain controllers is a foundational step in protecting your Active Directory environment from identity-based threats. MDI sensors monitor domain controller traffic to detect suspicious activities such as lateral movement, credential theft, and reconnaissance. The sensors can be installed directly on domain controllers or as standalone sensors on dedicated servers.

The installation process includes prerequisites like .NET Framework 4.7+, trusted root certificates, and connectivity to Defender for Identity cloud endpoints. Sensors can be deployed using a UI-based wizard or silently via command line, depending on your environment. Microsoft recommends installing sensors on **all domain controllers**, including read-only domain controllers (RODCs), to ensure full visibility.

Failing to deploy MDI sensors leaves your identity infrastructure blind to many advanced persistent threats and insider attacks. This deployment supports the **Zero Trust principle of "Assume Breach"** by enabling continuous monitoring and detection of anomalous behavior within your identity systems.

---

## Reference

- [Install a sensor - Microsoft Defender for Identity](https://learn.microsoft.com/en-us/defender-for-identity/deploy/install-sensor)  
- [Quick installation guide - Microsoft Defender for Identity](https://learn.microsoft.com/en-us/defender-for-identity/deploy/quick-installation-guide)  
- [Configure sensor settings](https://learn.microsoft.com/en-us/defender-for-identity/deploy/configure-sensor-settings)

