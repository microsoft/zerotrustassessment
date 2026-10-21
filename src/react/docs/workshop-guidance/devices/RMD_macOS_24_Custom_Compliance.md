# RMD-macOS-24 - Custom Compliance Policy for macOS

**Implementation Effort:** Medium – Requires authoring a macOS shell script to discover custom attributes and a JSON rule file defining compliant values.

**User Impact:** Medium – Noncompliant macOS devices are blocked from accessing organizational resources via Microsoft Entra Conditional Access until remediated.

## Overview

Introduced in **July 2026 (Service Release 2607)**, Microsoft Intune now supports **Custom Compliance settings for macOS**, bringing macOS to full parity with Windows and Linux custom compliance.

While built-in macOS compliance settings check standard attributes (FileVault, Firewall, Gatekeeper, OS version, and Defender risk score), **Custom Compliance** allows organizations to run a custom shell script via the Intune management agent for macOS and evaluate the returned JSON output against a custom JSON rules definition. This enables Zero Trust verification of:
- Third-party security agents (EDR, DLP, SASE/ZTNA daemons, certificate posture)
- Local macOS system hardening states (e.g., `sudo` configuration, SSH daemon status, TCC permissions, local AI agents)
- Custom hardware or file-integrity attributes

Results appear alongside standard compliance reporting in the Intune admin center and feed directly into **Microsoft Entra Conditional Access** device compliance evaluation.

## Key Configuration Steps

1. Write and test a macOS discovery shell script that outputs a flat JSON dictionary of key-value pairs to `stdout`.
2. Upload the discovery script in the Intune admin center under **Endpoint security > Device compliance > Scripts > Add > macOS**.
3. Create a JSON rules file defining the setting name, operator, data type, expected value, and remediation message for end users in Company Portal.
4. Create a **macOS Compliance Policy**, add the **Custom compliance** section, select your discovery script, and upload the JSON rules file.

## Reference

- [Use custom compliance settings in Microsoft Intune (Windows, Linux, and macOS)](https://learn.microsoft.com/en-us/intune/device-security/compliance/custom-settings)
