# Create a Custom Activity Policy to Get Alerts About Suspicious Usage Patterns

**Implementation Effort:** Low  
Creating a basic custom activity policy in MDA is a targeted administrative task that can be completed quickly using the built-in policy templates and filters.

**User Impact:** Low  
These policies run silently in the background and only involve administrators; end users are not affected unless a specific enforcement action is triggered.

---

## Overview

In Microsoft Defender for Cloud Apps, custom activity policies allow security teams to detect and respond to unusual or risky user behavior across cloud services. These policies can be configured to monitor specific activities—such as multiple failed logins, access from risky IPs, or mass downloads—and generate alerts or take automated actions like suspending a user session. The setup process is straightforward using the policy wizard, and policies can be fine-tuned over time.

This supports the **"Assume breach"** principle of Zero Trust by enabling proactive detection of suspicious behavior, helping to contain threats early. If not implemented, organizations may miss early warning signs of account compromise or insider threats, increasing the risk of data loss or misuse.

---

## Reference

- [Create activity policies - Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/user-activity-policies)
- [Common threat protection policies](https://learn.microsoft.com/en-us/defender-cloud-apps/policies-threat-protection)


