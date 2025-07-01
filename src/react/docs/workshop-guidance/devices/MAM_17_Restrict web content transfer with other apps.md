# Restrict Web Content Transfer with Other Apps

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the App Protection Policies for iOS/iPadOS and Android in Microsoft Intune.

**User Impact:** Medium – A subset of users may experience changes in how web links open from managed apps, especially if they are redirected to a specific browser like Microsoft Edge.

## Overview

The **“Restrict web content transfer with other apps”** setting in Microsoft Intune App Protection Policies (APP) controls how HTTP/HTTPS links are handled when opened from policy-managed apps. This setting is designed to prevent corporate data from being exposed through unmanaged or personal browsers.

### Available Options:
- **Any app** – Allows web links to open in any browser installed on the device.
- **Microsoft Edge** – Restricts web content to open only in Microsoft Edge, which is a policy-managed browser [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios).

This setting is particularly useful in BYOD scenarios where users may have multiple browsers installed. By forcing links to open in Microsoft Edge, organizations can ensure that web sessions are protected by app protection policies, Conditional Access, and single sign-on (SSO).

This setting supports the Zero Trust principle of **assume breach** by ensuring that sensitive web content is only accessed through trusted, policy-managed browsers. If not configured, users could open corporate links in unmanaged browsers, increasing the risk of data leakage or session hijacking.

## Reference

- [iOS/iPadOS app protection policy settings – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios)  
- [Troubleshoot data transfer and Intune app protection policies](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/troubleshoot-data-transfer)  
- [Common issues with Intune APP data transfer](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-protection-policies/data-transfer-scenarios)
