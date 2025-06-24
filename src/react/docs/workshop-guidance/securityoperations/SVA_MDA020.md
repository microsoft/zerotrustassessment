# Deploy the Defender for Cloud Apps Log Collector on Your Firewalls and Other Proxies

**Implementation Effort:** Medium – This deployment requires IT teams to configure network devices (firewalls, proxies) and set up a log collector server, which involves coordination and testing.

**User Impact:** Low – This is a backend deployment; end users are not affected or required to take any action.

## Overview

Deploying the Microsoft Defender for Cloud Apps log collector on your firewalls and proxies enables your organization to discover and analyze cloud app usage across your network. The log collector gathers traffic logs from network devices via Syslog or FTP and forwards them to Defender for Cloud Apps. This data is used to identify shadow IT, assess risk, and enforce policies.

This deployment is essential for organizations aiming to gain visibility into unsanctioned cloud services and user behavior. Without it, you risk blind spots in your cloud security posture, potentially allowing risky or non-compliant apps to be used undetected.

This activity supports the **Zero Trust principle of "Assume breach"** by ensuring continuous monitoring and visibility into cloud app usage, which helps detect anomalies and reduce exposure to threats.

## Reference


- [Advanced log collector management](https://learn.microsoft.com/en-us/defender-cloud-apps/log-collector-advanced-management)


