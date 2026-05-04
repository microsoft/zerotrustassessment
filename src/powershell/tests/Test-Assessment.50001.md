Microsoft Defender for Cloud provides two complementary views of your cloud security posture: **Secure Score recommendations** (which roll into your overall posture score and are evaluated against every resource) and **Microsoft Cloud Security Benchmark (MCSB) compliance assessments** (which map findings to specific control domains such as Network Security, Identity Management, Privileged Access, Data Protection, Logging & Threat Detection, and Endpoint Security). This test combines both views into a single unified set of results — every recommendation from either source appears exactly once:

- **Recommendations in both sources** show secure score resource state as the authoritative pass/fail signal, with each resource row enriched by its mapped MCSB control ID(s) and control name(s). The category combines the secure score control name with the MCSB domain(s).
- **Recommendations only in the secure score** are shown with secure score data alone (no MCSB columns), exactly as in the standalone secure score test.
- **Recommendations only in MCSB** (including Microsoft-managed assessments) are shown with MCSB data, pass/fail derived from the MCSB resource state, exactly as in the standalone MCSB test.

Addressing these recommendations reduces your attack surface, raises your secure score, and demonstrates alignment with frameworks such as CIS, NIST SP 800-53, PCI-DSS, and ISO 27001.

**References**

- [Secure score in Microsoft Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/secure-score-security-controls) - How secure score controls are calculated
- [Microsoft Cloud Security Benchmark introduction](https://learn.microsoft.com/security/benchmark/azure/introduction) - Overview of the MCSB control domains and versioning
- [Review security recommendations](https://learn.microsoft.com/azure/defender-for-cloud/review-security-recommendations) - How to view and act on recommendations in the Azure portal
- [Regulatory compliance in Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/regulatory-compliance-dashboard) - Viewing MCSB compliance status
- [Remediate recommendations in Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/implement-security-recommendations) - Step-by-step remediation guidance

<!--- Results --->
%TestResult%
