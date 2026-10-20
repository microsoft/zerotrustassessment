Controlled folder access is a Microsoft Defender Antivirus protection that checks apps against a trusted list before allowing changes to protected folders. Microsoft describes it as a way to protect valuable data from malicious apps and threats such as ransomware, with default protected locations and administrator-defined additions. This matters because threat actors who reach execution often try to encrypt or destroy user and business files during the impact stage. If controlled folder access is disabled or only auditing, untrusted processes can still write to protected locations, so a ransomware event can complete before response teams intervene. The control is not a full backup strategy, and it can require allow rules for trusted line-of-business apps that write to user folders. It is still an important last endpoint barrier because it blocks unauthorized write activity where high-value files are commonly stored. This check uses the pinned MDATP Secure Score control `scid_2021` to evaluate the tenant-level Microsoft signal.

**Remediation action**

- [Protect important folders with controlled folder access](https://learn.microsoft.com/en-us/defender-endpoint/controlled-folder-access-overview)
- [Configure controlled folder access](https://learn.microsoft.com/en-us/defender-endpoint/controlled-folder-access-configure)
- [Monitor controlled folder access activity](https://learn.microsoft.com/en-us/defender-endpoint/controlled-folder-access-monitor)

<!--- Results --->
%TestResult%
