Without enforcing macOS LAPS policies during Automated Device Enrollment (ADE), threat actors can exploit static or reused local administrator passwords to escalate privileges, move laterally, and establish persistence. Devices provisioned without randomized credentials are vulnerable to credential harvesting and reuse across multiple endpoints, increasing the risk of domain-wide compromise.

Enforcing macOS LAPS ensures that each device is provisioned with a unique, encrypted local administrator password managed by Intune. This disrupts the attack chain at the credential access and lateral movement stages, significantly reducing the risk of widespread compromise and aligning with Zero Trust principles of least privilege and credential hygiene.

**Remediation action**

Use Intune to configure macOS ADE profiles that provision a local admin account with a randomized and encrypted password, and that enables secure rotation:  
- [Configure macOS LAPS in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/enrollment/macos-laps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Rotate local admin password (macOS)](https://learn.microsoft.com/intune/intune-service/remote-actions/device-rotate-local-admin-password?pivots=macos&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

For more information, see:  
- [macOS ADE setup guide](https://learn.microsoft.com/intune/intune-service/enrollment/device-enrollment-program-enroll-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

