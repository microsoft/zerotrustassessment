# Review Enrollment Restrictions

**Last Updated:** May 2025  
**Implementation Effort:** Medium – Configuring enrollment restrictions requires reviewing platform support, ownership types, and enrollment limits. Admins must coordinate with ABM/ASM for corporate devices and ensure policies are scoped correctly to user groups.  
**User Impact:** Medium – Most users will not notice changes unless they attempt to enroll unsupported or excess devices. BYOD users may encounter new prompts or limits during enrollment. Clear communication helps reduce confusion and support requests.

## Introduction

Enrollment restrictions in Intune define which devices are allowed to enroll and under what conditions. For macOS environments, these restrictions help enforce organizational policies around device ownership, platform support, and enrollment limits. This section helps administrators evaluate their current enrollment restriction settings to ensure they align with Zero Trust principles and support a secure, intentional onboarding process.

This guidance applies to both new deployments and environments where macOS devices are already enrolled, with a focus on reviewing and refining restrictions to reduce risk and enforce trust boundaries.

## Why This Matters

- **Controls which devices can be onboarded** into your Intune environment.
- **Prevents unauthorized or unmanaged macOS devices** from enrolling.
- **Supports Zero Trust** by ensuring only known, supported, and policy-aligned devices are allowed.
- **Reduces attack surface** by limiting enrollment to approved platforms and ownership types.
- **Improves operational clarity** by enforcing consistent enrollment behavior across the organization.

## Key Considerations

### Platform Restrictions

- Ensure macOS is explicitly allowed in your **device platform restrictions**.
- Block platforms that are not supported or not in scope for your organization.
- For macOS, confirm that only supported OS versions are permitted to enroll.

### Device Ownership Restrictions

- Use **device type restrictions** to differentiate between **corporate** and **BYOD** macOS devices.
- Apply stricter controls to BYOD devices, such as limiting the number of enrollments per user or requiring user authentication during enrollment.
- For corporate devices, ensure enrollment is tied to **Automated Device Enrollment (ADE)** via ABM/ASM to enforce supervision and non-removable MDM.

### Enrollment Limits

- Set limits on the number of devices a user can enroll to prevent abuse or accidental over-enrollment.
- Review whether current limits reflect actual business needs and user roles.

### Group-Based Targeting

- Enrollment restrictions can be scoped to **Microsoft Entra groups** to apply different rules for different user populations.
- Use this to enforce tighter restrictions for high-risk roles or departments.

### Reviewing Existing Enrollments

- For environments with existing macOS enrollments, audit which devices were enrolled before restrictions were applied.
- Identify any unmanaged or non-compliant devices that may have bypassed current restrictions.
- Consider retiring and re-enrolling devices that do not meet current enrollment criteria.

## Zero Trust Considerations

- **Verify explicitly**: Enrollment restrictions ensure that only devices meeting defined criteria can join the environment.
- **Assume breach**: Blocking unsupported or unmanaged platforms reduces the risk of rogue device access.
- **Least privilege**: BYOD and corporate devices can be scoped to different enrollment experiences and access levels.
- **Continuous trust**: Enrollment restrictions help maintain a clean, policy-aligned device inventory over time.

## Recommendations

- **Review platform and device type restrictions** to ensure only supported macOS devices are allowed.
- **Differentiate BYOD and corporate enrollment paths** using ownership restrictions and ABM/ASM integration.
- **Set enrollment limits per user** to prevent overuse or abuse.
- **Use group-based targeting** to apply tailored restrictions for different user groups or risk profiles.
- **Audit existing enrollments** to identify and remediate devices that fall outside your current policy scope.
- **Revisit restrictions quarterly** to ensure they reflect evolving organizational needs and Zero Trust posture.

## References

- [Configure Enrollment Restrictions in Intune](https://learn.microsoft.com/en-us/mem/intune/enrollment/enrollment-restrictions-set)  
- [Device Platform Restrictions](https://learn.microsoft.com/en-us/mem/intune/enrollment/enrollment-restrictions-platform)  
- [Device Type Restrictions](https://learn.microsoft.com/en-us/mem/intune/enrollment/enrollment-restrictions-device-type)
