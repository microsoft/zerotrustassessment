# RMD-MAM-33 - Apple Intelligence & Android AI Data Controls

**Implementation Effort:** Low – Configured through Intune App Protection Policies (MAM) and Settings Catalog (DDM for iOS/macOS and Android Enterprise).

**User Impact:** Medium – Restricts unapproved on-device AI summarization, generative tools, screenshots, and cross-app AI agent actions on organizational data.

## Overview

Modern mobile and desktop operating systems include deeply integrated on-device and cloud-connected AI assistants (such as **Apple Intelligence** on iOS/iPadOS/macOS and **Google Gemini / Circle to Search / App Functions** on Android). Without explicit MDM and MAM controls, organizational data inside managed apps can be captured via screen context, summarized by external AI workspaces, or manipulated by on-device AI agents.

Key 2025–2026 Intune controls for governing mobile and endpoint AI include:
- **iOS/iPadOS App Protection Policy (MAM) Standalone AI Controls:** Standalone MAM Data Protection settings to selectively block or allow **Genmoji**, **Writing Tools**, and **Screen Capture** (including screen recording and mirroring, with user alert popups on iOS SDK 20.3.0+).
- **Apple Declarative Device Management (DDM) Intelligence Settings (2603 / 2605):** In the Intune Settings Catalog for iOS/iPadOS and macOS (replacing deprecated legacy MDM restrictions in OS 26.4+), admins can granularly govern:
  - **External Intelligence Settings:** *Allow Sign In* and *Allowed Workspace IDs*
  - **Intelligence Settings:** *Allow Writing Tools*, *Allow Genmoji*, *Allow Image Playground / Image Wand*, *Allow Visual Intelligence Summary*, *Mail Smart Replies & Summary*, *Notes Transcription & Summary*, *Safari Summary*, and *Force On-Device Only Dictation/Translation*.
- **Android Enterprise AI & Agent Controls (2510 / 2606):**
  - **Block assist content sharing with privileged apps:** Blocks screenshots and app context from being sent to assistant apps (blocking **Circle to Search**).
  - **Block apps from exposing app functions (2606):** Prevents managed apps on COBO, COSU, and COPE work profiles from exposing programmatic actions (*app functions*) that on-device assistants or AI agents can invoke inside the app.

## Reference

- [Manage AI on Android with Intune – A Guide for IT Admins](https://learn.microsoft.com/en-us/intune/solutions/ai/manage-ai-android)
- [iOS/iPadOS app protection policy settings – Data protection](https://learn.microsoft.com/en-us/intune/app-management/protection/ref-settings-ios#data-protection)
- [Android Enterprise device settings in the Intune settings catalog](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/ref-android-settings)
