# Office Add-ins

## Overview

Office add-ins can boost productivity, but not all add-ins are equal when it comes to security.

## Modern Office Add-ins

**Office Add-ins** are lightweight web-based extensions built using HTML, JavaScript, and web technologies that enhance the functionality of Microsoft 365 apps like Outlook, Word, Excel, and PowerPoint. These add-ins run in the context of the host Office application and can interact with the document or email content while integrating with external services (such as CRMs or line-of-business systems).

- Built using HTML, JavaScript, and other web technologies.
- Run in a secure, sandboxed environment in the cloud.
- Centrally managed through the Microsoft 365 admin center.
- Align well with Zero Trust principles:
  - **Verify explicitly**: Identity-based access control.
  - **Least privilege**: Limited access to system resources.
  - **Assume breach**: Sandboxed execution reduces attack surface.

## Legacy Add-ins (VBA Macros, COM, VSTO)

**Legacy Add-ins** refer to older, COM-based or VSTO (Visual Studio Tools for Office) extensions that integrate deeply with Office desktop applications. These are typically installed directly onto the Windows device and can offer advanced integration capabilities not available to modern web-based add-ins. However, they also introduce greater security and compatibility risks due to their dependency on local system resources and elevated privileges.

- Execute code directly on the user’s machine.
- Have elevated access to local system resources.
- Pose higher security risks, including:
  - Malware injection
  - Unauthorized access
  - Difficult-to-detect persistence
- Harder to monitor, manage, and secure at scale.

## Why This Matters

Modern Office Add-ins are safer and easier to manage in a Zero Trust environment. Legacy models increase risk and require additional controls like macro blocking, endpoint protection, and conditional access.

## Recommendation

- Favor modern Office Add-ins for new development.
- Begin transitioning away from VBA macros, COM, and VSTO add-ins.
- Use Microsoft 365 admin tools and Intune to manage deployment and enforce security policies.

## Reference

- [Office Add-ins Overview](https://learn.microsoft.com/en-us/office/dev/add-ins/overview/office-add-ins)
- [Manage add-ins in the Microsoft 365 admin center](https://learn.microsoft.com/en-us/microsoft-365/admin/manage/manage-addins-in-the-admin-center)
- [Macro Security Settings and Policies](https://learn.microsoft.com/en-us/deployoffice/security/internet-macros-blocked)