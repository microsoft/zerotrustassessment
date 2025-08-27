# Terms and Conditions

**Implementation Effort:** Low — Requires configuration policies and document upload, but does not require ongoing user management once deployed.  
**User Impact:** Low — All targeted users must review and accept the terms before accessing resources, which introduces a mandatory interaction for each user.

## Overview

Microsoft provides two options for presenting legal or compliance-related terms to users: **Intune Terms and Conditions** and **Entra Terms of Use**. While both can be used to inform users and obtain consent, **Entra Terms of Use** is the preferred method due to its broader applicability and integration with Conditional Access.

- **Intune Terms and Conditions** are limited to device enrollment scenarios and are primarily used during mobile device onboarding. They lack flexibility and visibility across other Microsoft 365 services.
- **Entra Terms of Use** allows organizations to present terms during sign-in, enforce reacceptance when terms are updated, and apply conditions based on user risk, device state, or location.

If not implemented, organizations risk non-compliance with regulatory requirements, lack of user accountability, and reduced visibility into user consent. Entra Terms of Use supports the **“Verify explicitly”** principle of Zero Trust by ensuring users acknowledge policies before accessing sensitive resources or enrolling their devices.

## Reference

- [Intune Terms and Conditions](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/terms-and-conditions-create)  
- [Microsoft Entra terms of use with Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/terms-of-use)
