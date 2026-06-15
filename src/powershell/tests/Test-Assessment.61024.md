The Defender XDR data connector forwards the unified Defender incident stream to Microsoft Sentinel. For AI workloads, this includes correlated incidents that span identity, cloud posture, and AI threat protection — signals that Defender XDR has already assembled into a single incident. Without this connector, those incidents exist only in the Defender portal, unavailable to Sentinel analytics rules or automated playbooks. This check verifies the connector is enabled and receiving data on at least one Sentinel-onboarded workspace.

When the Defender XDR connector is not enabled, the unified Defender incident stream never reaches Sentinel. Threat actors who operate through a compromised agent identity generate correlated signals across Defender for Identity, Defender for Cloud, and Defender for Cloud Apps simultaneously — but without this connector those signals remain isolated in the Defender XDR portal, unavailable to Sentinel analytics rules or automated playbooks. Without this connector, the organization cannot act on the correlated AI security incident that Defender XDR has already assembled, instead receiving three independent sub-signals that may each be dismissed as routine.

**Remediation action**

- [Connect Microsoft Defender XDR to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-microsoft-365-defender)
- [Defender XDR alerts in Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/microsoft-365-defender-sentinel-integration)

<!--- Results --->
%TestResult%
