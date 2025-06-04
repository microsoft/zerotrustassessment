# Require step-up authentication (authentication context) upon risky action

**Implementation Effort:** Medium: This effort score is chosen because it involves creating and managing Conditional Access policies and session policies, which require ongoing time and resource commitment from IT and Security Operations teams.

**User Impact:** High: This ranking is chosen because a subset of non-privileged users may need to take action or be notified of changes, particularly when accessing sensitive information or performing risky actions.

## Overview
This feature allows IT administrators to enforce step-up authentication when users perform sensitive actions during a session, such as accessing proprietary information from an unmanaged device. It fits into the Zero Trust framework by ensuring that access policies are dynamically reassessed based on the context of the user's actions, thereby enhancing security.

## Reference
[Require step-up authentication (authentication context) upon risky action](https://learn.microsoft.com/en-us/defender-cloud-apps/tutorial-step-up-authentication)
