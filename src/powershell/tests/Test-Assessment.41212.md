Hunting in Sentinel is the proactive, hypothesis-driven counterpart to rule-based detection: SOC analysts run KQL queries against ingested telemetry to find threat actor behavior that no analytics rule has yet been written to catch — emerging TTPs, novel persistence mechanisms, low-and-slow command-and-control, insider data staging, supply chain compromise, and post-compromise reconnaissance. Sentinel exposes hunting through three documented surfaces: saved hunting queries (Microsoft.SecurityInsights/huntingQueries legacy resource and the modern hunts API, Microsoft.SecurityInsights/hunts), bookmarks that pin investigation findings (Microsoft.SecurityInsights/bookmarks) for case-tracking and incident attachment, and Notebooks (Jupyter / Azure ML) for advanced investigation workflows. Without operationalized hunting, the SOC operates in a purely reactive posture and only finds what its current rule corpus is configured to find; investigations cannot be tracked or shared across analysts, and the institutional knowledge of "we have hunted this hypothesis and ruled it out" or "we have found this anomaly and need to keep investigating" is lost when the analyst's browser tab closes. The check confirms at least one saved hunting query or bookmark exists in the workspace, indicating hunting is being practiced rather than aspirational.

**Remediation action**

- [Hunt for threats with Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/hunting)
- [Use bookmarks to save interesting information while hunting](https://learn.microsoft.com/azure/sentinel/bookmarks)
- [Use Jupyter Notebook to hunt for security threats](https://learn.microsoft.com/azure/sentinel/notebooks)

<!--- Results --->
%TestResult%
