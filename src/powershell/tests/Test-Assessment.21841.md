Threat actors increasingly rely on prompt bombing and real-time phishing proxies to coerce or trick users into approving fraudulent multifactor authentication (MFA) challenges. Without the Microsoft Authenticator app's **Report suspicious activity** capability enabled, an attacker can iterate until a fatigued user accepts. This type of attack can lead to privilege escalation, persistence, lateral movement into sensitive workloads, data exfiltration, or destructive actions.

When reporting is enabled for all users, any unexpected push or phone prompt can be actively flagged, immediately elevating the user to high user risk and generating a high-fidelity user risk detection (userReportedSuspiciousActivity) that risk-based Conditional Access policies or other response automation can use to block or require secure remediation. 

**Remediation action**

- [Enable the report suspicious activity setting in the Microsoft Authenticator app](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#report-suspicious-activity)
<!--- Results --->
%TestResult%

