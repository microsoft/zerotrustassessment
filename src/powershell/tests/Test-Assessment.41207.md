Analytics rules are the detection engine of Microsoft Sentinel. Scheduled rules run KQL queries on a schedule (typically every 5 minutes to 1 hour); Near-Real-Time (NRT) rules evaluate the last minute of data on every event arrival; Microsoft Security rules forward Microsoft Defender alerts as Sentinel incidents; Fusion rules use Microsoft machine learning to correlate low-fidelity signals across data sources into high-fidelity, multi-stage incidents; Threat Intelligence rules match indicators from the threat-intel store against ingested telemetry; UEBA rules surface anomalous user/entity behavior; ML Behavior Analytics rules surface anomalous SSH and RDP login patterns. Without active analytics rules, the workspace ingests data but generates zero incidents — every threat actor TTP that could be detected passes without alerting. Microsoft publishes hundreds of analytics rule templates; production deployments enable a curated subset matched to the connector inventory and tune them over time. The check confirms at least one analytics rule is enabled and the workspace has more than zero rules across the documented kinds.

**Remediation action**

- [Detect threats out-of-the-box with Microsoft Sentinel analytics rules](https://learn.microsoft.com/azure/sentinel/detect-threats-built-in)
- [Create custom analytics rules to detect threats](https://learn.microsoft.com/azure/sentinel/detect-threats-custom)
- [Microsoft Sentinel content hub](https://learn.microsoft.com/azure/sentinel/sentinel-solutions-deploy)

<!--- Results --->
%TestResult%
