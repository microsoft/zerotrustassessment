# Review Configuration Analyzer in Microsoft Defender for Office 365

**Implementation Effort:** Low  
The Configuration Analyzer is built into the Microsoft Defender portal and requires only targeted administrative actions to review and adjust policy settings.

**User Impact:** Low  
Changes are made by administrators; end users are not directly affected or required to take action.

## Overview

The **Configuration Analyzer** in Microsoft Defender for Office 365 (MDO) provides a centralized dashboard to review and compare your current email security policies against Microsoft's recommended baselines—**Standard** and **Strict** protection profiles. It evaluates policies across **Exchange Online Protection (EOP)** and **Defender for Office 365**, including anti-spam, anti-malware, anti-phishing, Safe Links, and Safe Attachments policies. It also checks for non-policy configurations like **SPF/DKIM** and **Outlook external sender indicators**.

This tool helps security teams quickly identify misconfigurations or weaker-than-recommended settings, reducing the risk of phishing, spoofing, and malware attacks. If not reviewed and optimized, organizations may leave gaps in their email defenses, increasing the likelihood of successful attacks.

This capability supports the **"Assume Breach"** principle of Zero Trust by ensuring that all email security configurations are hardened to reduce the attack surface and improve detection and response readiness.

## Reference

- [Configuration analyzer for security policies - Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/configuration-analyzer-for-security-policies)  
- [Optimize and correct security policies with configuration analyzer](https://learn.microsoft.com/en-us/defender-office-365/step-by-step-guides/optimize-and-correct-security-policies-with-configuration-analyzer)

