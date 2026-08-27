Microsoft Defender for Endpoint device control restricts the use of removable storage including USB mass storage, MTP devices, optical media, Bluetooth peripherals, and printers by enforcing read, write, and execute access policies at the device class level. When device control is not enforced, an adversary with physical access or a malicious insider can deliver payloads via USB, exfiltrate sensitive data to removable media, or stage execution from auto-running content without any policy intervening. The risk is not limited to targeted attacks: commodity malware has long used removable media as a propagation mechanism, and without enforcement the organization has no preventive control at the boundary between the managed endpoint and the physical world.

**Remediation action**

- [Microsoft Defender for Endpoint device control overview](https://learn.microsoft.com/en-us/defender-endpoint/device-control-overview)
- [Deploy and manage device control with Intune](https://learn.microsoft.com/en-us/defender-endpoint/device-control-deploy-manage-intune)
- [Device control policies](https://learn.microsoft.com/en-us/defender-endpoint/device-control-policies)
- [Device control reports](https://learn.microsoft.com/en-us/defender-endpoint/device-control-report)

<!--- Results --->

%TestResult%
