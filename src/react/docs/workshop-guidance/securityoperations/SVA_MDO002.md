# Review Configuration Analyzer and/or ORCA recommendations in Microsoft Defender for Office 365

**Implementation Effort:** Low  
The Configuration Analyzer is built into the Microsoft Defender portal and requires only targeted administrative actions to review and adjust policy settings.

**User Impact:** Low  
Changes are made by administrators; end users are not directly affected or required to take action.

## Overview

The **Configuration Analyzer** in Microsoft Defender for Office 365 (MDO) provides a centralized dashboard to review and compare your current email security policies against Microsoft's recommended baselines—**Standard** and **Strict** protection profiles. It evaluates policies across **Exchange Online Protection (EOP)** and **Defender for Office 365**, including anti-spam, anti-malware, anti-phishing, Safe Links, and Safe Attachments policies. It also checks for non-policy configurations like **SPF/DKIM** and **Outlook external sender indicators**.

This tool helps security teams quickly identify misconfigurations or weaker-than-recommended settings, reducing the risk of phishing, spoofing, and malware attacks. If not reviewed and optimized, organizations may leave gaps in their email defenses, increasing the likelihood of successful attacks.

This capability supports the **"Assume Breach"** principle of Zero Trust by ensuring that all email security configurations are hardened to reduce the attack surface and improve detection and response readiness.


The ORCA module is a PowerShell-based tool that helps security administrators assess the configuration of email threat protection policies in Microsoft Defender for Office 365. It generates a report using the `Get-ORCAReport` cmdlet to evaluate anti-spam, anti-phishing, anti-malware, and other hygiene settings against Microsoft's recommended "Standard" and "Strict" baselines. These baselines are designed to reduce exposure to threats by enforcing stronger filtering and quarantine policies.

ORCA complements the Configuration Analyzer in the Defender portal, which provides a GUI-based comparison of current settings versus recommended ones. Admins can apply recommendations directly or export them for review. The analyzer also tracks configuration drift over time, helping teams maintain a strong security posture.

This capability supports the "Assume breach" principle of Zero Trust by proactively identifying gaps in protection and ensuring threat policies are optimized to minimize risk. Failure to implement ORCA recommendations may leave organizations vulnerable to phishing, malware, and spam due to misconfigured or outdated policies.


## Reference

- [Configuration analyzer for security policies - Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/configuration-analyzer-for-security-policies)  
- [Optimize and correct security policies with configuration analyzer](https://learn.microsoft.com/en-us/defender-office-365/step-by-step-guides/optimize-and-correct-security-policies-with-configuration-analyzer)
