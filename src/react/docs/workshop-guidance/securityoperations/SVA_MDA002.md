# Discover Cloud Apps

**Implementation Effort:** Medium – Requires integration with network infrastructure (e.g., firewalls, proxies, Defender for Endpoint) and setup of log collection or API automation.  
**User Impact:** Low – This is an IT/admin-driven activity; end users are not directly impacted or required to take action.

## Overview

**Cloud App Discovery** in Microsoft Defender for Cloud Apps helps organizations identify and assess the use of cloud applications across their environment. It works by analyzing traffic logs from firewalls, proxies, or Defender for Endpoint, comparing them against a catalog of over 31,000 cloud apps. Each app is scored based on 90+ risk factors, providing visibility into Shadow IT and potential security risks. Reports can be generated as one-time snapshots or continuously through automated log collection or API integration. This capability supports Zero Trust by enforcing the principle of **"Assume Breach"**, as it helps detect unauthorized or risky app usage that may bypass traditional controls. Without deploying this, organizations risk blind spots in cloud usage, leading to data leakage or compliance violations.

## Reference

- [Cloud app discovery overview – Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/set-up-cloud-discovery)  
- [View discovered apps on the Cloud discovery dashboard](https://learn.microsoft.com/en-us/defender-cloud-apps/discovered-apps)  
- [Govern discovered apps](https://learn.microsoft.com/en-us/defender-cloud-apps/governance-discovery)

