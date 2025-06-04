# Create File Policies with Microsoft Defender for Cloud Apps

**Implementation Effort:** Medium  
Creating file policies requires IT and Security Operations teams to define policy logic, select appropriate templates or build custom rules, and test and monitor policy effectiveness across cloud environments.

**User Impact:** Medium  
These policies may trigger alerts, quarantines, or access restrictions that affect subsets of users who share or access files in ways that violate policy—especially those collaborating externally or handling sensitive data.

---

## Overview

File policies in **Microsoft Defender for Cloud Apps (MDA)** allow organizations to monitor and control file activity across cloud services like Microsoft 365, Google Workspace, and others. These policies can detect sensitive content, enforce data loss prevention (DLP), and automate governance actions such as quarantine, user notifications, or applying sensitivity labels. Policies are built using a combination of **content inspection**, **contextual filters** (e.g., sharing level, user role), and **automated actions**.

Admins can assign **severity levels** (e.g., Medium) and **categories** to align with organizational risk management strategies. For example, a medium-severity policy might alert on files shared externally that contain sensitive keywords or source code, without immediately blocking access.

This capability supports the **Zero Trust principle of "Assume Breach"** by continuously scanning cloud environments for risky file behaviors and enforcing remediation actions to reduce exposure.

**Risks if not implemented:**  
Without file policies, sensitive or regulated data may be shared externally or remain unmonitored in cloud storage, increasing the risk of data leaks, compliance violations, and reputational damage.

---

## Reference

- [File policies - Microsoft Defender for Cloud Apps | Microsoft Learn](https://learn.microsoft.com/en-us/defender-cloud-apps/data-protection-policies)  
- [Commonly used information protection policies](https://learn.microsoft.com/en-us/defender-cloud-apps/policies-information-protection)  
- [Control cloud apps with policies](https://learn.microsoft.com/en-us/defender-cloud-apps/control-cloud-apps-with-policies)

