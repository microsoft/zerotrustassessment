# APNS Certificates

**Implementation Effort:** Low
**User Impact:** Low — users are not directly involved, but expiration causes major backend management disruption.

## Overview
The Apple Push Notification service certificate is the trust anchor that lets Microsoft Intune communicate with enrolled macOS devices. If it expires or is renewed with the wrong Apple account, policy deployment, app installs, remote actions, and compliance evaluation can fail or require disruptive remediation.

## Implementation Guidance
1. Use a dedicated, organization-owned Apple account for the Apple Push Certificates Portal and document ownership so renewal never depends on a departing employee.
2. In the Microsoft Intune admin center, go to Devices > macOS > macOS enrollment > Apple MDM Push certificate and confirm the current expiration date and renewal owner.
3. Download the certificate signing request from Intune, renew in the Apple portal by using the same Apple account, and upload the renewed certificate back to Intune before expiration.
4. Create calendar reminders and an operational ticket 30 to 60 days before expiration and treat renewal as a tracked change.
5. After renewal, validate device communication by checking recent check-ins and a test profile deployment.

## Reference
- **[Get an Apple MDM Push certificate for Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/create-mdm-push-certificate)** — Explains how to create, upload, and renew the Apple MDM push certificate used by Intune.
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Describes supported macOS enrollment methods, prerequisites, and ownership scenarios in Intune.
