**Windows 365 Provisioning Options**

**Implementation Effort:** Medium -- Admins must define provisioning
policies, including network, image, and user group assignments, but the
process is largely automated after setup.

**User Impact:** Low -- Provisioning is invisible to users; they receive
access to their Cloud PC without needing to take any action.

**Overview**

Windows 365 provisioning is the automated process that creates and
configures Cloud PCs for licensed users. Admins define **provisioning
policies** in the Microsoft Intune admin center, specifying the network
type (Microsoft-hosted or Azure Network Connection), the OS image
(gallery or custom), and the Microsoft Entra user groups to assign. Once
a user is licensed and matches the policy criteria, Windows 365
automatically provisions a Cloud PC for them. This process is one-time
per user-license pair and includes setting up the virtual machine,
applying the image, and configuring access.

If provisioning policies are misconfigured---such as incorrect network
settings, invalid images, or missing group assignments---Cloud PCs may
fail to deploy, delaying user access and increasing IT overhead. This
capability supports the Zero Trust principle of **Verify explicitly**,
as provisioning ensures that only licensed, authorized users receive
access to Cloud PCs with predefined configurations and security
baselines.

**Reference**

- [Provisioning in Windows
  365](https://learn.microsoft.com/en-us/windows-365/enterprise/provisioning)

- [Create provisioning policies for Windows
  365](https://learn.microsoft.com/en-us/windows-365/enterprise/create-provisioning-policy)

- [Windows 365 deployment
  options](https://learn.microsoft.com/en-us/windows-365/enterprise/deployment-options)
