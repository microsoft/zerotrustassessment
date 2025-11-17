# Enable exploit protection

**Implementation Effort:** High: Implementing exploit protection requires setting up monitoring for application crashes and hangs, enabling full user mode dump collection, and ensuring compatibility with existing applications. This involves ongoing resource commitment and careful deployment practices to avoid productivity outages

**User Impact:** Medium: A subset of non-privileged users may need to take action or be notified of changes. Notifications from the Action Center may be displayed when a mitigation is found on the device

## Overview
Exploit protection helps protect against malware that uses exploits to infect devices and spread. It includes various mitigations that can be applied to the operating system or individual applications, enhancing the security posture of the organization. This feature is part of Microsoft Defender for Endpoint and fits into the Zero Trust framework by ensuring that devices are protected against vulnerabilities and exploits, thereby reducing the attack surface.

## Reference
[Enable exploit protection](https://learn.microsoft.com/en-us/defender-endpoint/enable-exploit-protection)
