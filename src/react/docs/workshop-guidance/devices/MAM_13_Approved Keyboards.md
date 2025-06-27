# Approved Keyboards (Android Only)

**Implementation Effort:** Low – IT administrators only need to configure the approved keyboard list within the App Protection Policies for Android in Microsoft Intune.

**User Impact:** Medium – A subset of Android users may be required to switch from their preferred keyboard to an approved one when using managed apps, which may affect typing experience or productivity.

## Overview

The **“Approved Keyboards”** setting in Microsoft Intune App Protection Policies (APP) for Android allows organizations to restrict which keyboards can be used within managed apps. This control helps prevent data leakage through untrusted or third-party input methods.

When this setting is enabled:
- Only keyboards explicitly listed as approved (by package ID) can be used within managed apps.
- If a user attempts to use an unapproved keyboard, they will be prompted to switch to an approved one.
- At least one keyboard must be approved for the policy to be saved.

### Commonly Approved Keyboards:
- **Microsoft SwiftKey Keyboard** (`com.touchtype.swiftkey`)
- **Gboard – Google Keyboard** (`com.google.android.inputmethod.latin`)
- **Samsung Keyboard** (varies by device; may require manual approval)

This setting supports the Zero Trust principle of **assume breach** by ensuring that sensitive data entered into managed apps is not intercepted or logged by untrusted keyboards. If not configured, users could unknowingly use keyboards that capture keystrokes or transmit data to third-party services.

## Reference

- [Android app protection policy settings – Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)
