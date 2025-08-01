# Windows 365: Redirections

**Implementation Effort:** Medium – Admins must configure and deploy redirection policies using Intune or Group Policy, which requires coordination and testing across device types and user groups.

**User Impact:** Medium - Changes to redirection settings may affect how users access local devices (e.g., printers, USB drives, microphones) during Cloud PC sessions, requiring communication and support.

---

## Overview

Windows 365 redirections allow users to access local device
resources---such as printers, USB drives, webcams, audio devices, and
clipboards---within their Cloud PC sessions via Remote Desktop Protocol
(RDP). These redirections are enabled by default but can be restricted
to meet organizational security and compliance requirements. Admins can
manage redirection settings using Microsoft Intune (Settings Catalog) or
Group Policy Objects (GPOs), depending on the Cloud PC\'s domain join
type.

Redirection types include:

- Audio input/output

- Cameras

- Clipboard

- COM ports

- Drives (fixed, removable, network)

- Location

- Printers

- Smartcards

- USB drives

If redirection settings are not properly managed, organizations risk
data leakage (e.g., via clipboard or USB redirection) or reduced user
productivity (e.g., blocked printers or audio devices). This feature
supports the Zero Trust principle of **\"Use least privilege access\"**
by limiting device-level access to only what is necessary for the user's
role, reducing the attack surface.

Beginning in August, 2025 Clipboard, Drive, Printers, and USB
redirections are disabled by default.

## Reference

* [Manage RDP device redirections for Cloud
  PCs](https://learn.microsoft.com/en-us/windows-365/enterprise/manage-rdp-device-redirections)

* [Configure drive redirection over
  RDP](https://learn.microsoft.com/en-us/azure/virtual-desktop/redirection-configure-drives-storage)

* [Redirect local devices and folders in Windows
  App](https://learn.microsoft.com/en-us/windows-app/device-audio-folder-redirection-teams)
