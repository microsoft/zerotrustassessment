**Windows 365 Device Identities**

**Implementation Effort:** Medium\
Admins must choose and configure the appropriate device join type
(Microsoft Entra Join or Hybrid Join) during provisioning, which
requires planning and coordination with identity and network teams.

**User Impact:** Low\
Device identity configuration is handled by IT and does not require user
action unless specific authentication methods (e.g., Windows Hello) are
enforced.

**Overview**

Windows 365 device identities define how Cloud PCs are joined to
Microsoft Entra ID and how they are managed and authenticated. There are
two supported join types: **Microsoft Entra Join**, which connects the
Cloud PC directly to Entra ID, and **Microsoft Entra Hybrid Join**,
which joins the Cloud PC to an on-premises Active Directory and syncs it
to Entra ID. The join type determines how policies are applied (via
Intune or Group Policy), what identity types are supported (cloud-only
or hybrid), and whether features like Windows Hello for Business are
available.

Device identities are critical for enforcing Conditional Access,
enabling passwordless authentication, and managing devices through
Intune. If device identities are not properly configured, organizations
may face authentication failures, policy misapplication, or reduced
security posture.

This capability supports the Zero Trust principle of **\"Verify
explicitly\"** by ensuring that each Cloud PC is uniquely identified and
authenticated before access is granted.

**Reference**

- [Windows 365 identity and
  authentication](https://learn.microsoft.com/en-us/windows-365/enterprise/identity-authentication)

- [What is device identity in Microsoft Entra
  ID?](https://learn.microsoft.com/en-us/entra/identity/devices/overview)
