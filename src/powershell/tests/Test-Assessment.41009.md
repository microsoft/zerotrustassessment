Dormant accounts (accounts that have not authenticated for an extended period — Microsoft Defender for Identity's posture assessment uses 180 days by default) that remain members of sensitive groups (Domain Admins, Enterprise Admins, Account Operators, Server Operators, Backup Operators, and any customer-tagged Tier-0 group) are high-value, low-attention targets: their owners are not actively monitoring sign-ins for anomalous activity, password rotations are unlikely, and any pre-existing credential leak (paste sites, third-party breach corpora, old endpoint backups) remains exploitable. A threat actor who obtains such a credential through credential stuffing or breach-data lookup authenticates as a Domain Admin or equivalent without triggering the behavioral baselines that protect active privileged users; from there they can replicate the directory's secrets, forge long-lived authentication artifacts, and pivot to full forest compromise — all paths that begin with one stale, over-privileged identity. Removing dormant principals from sensitive groups — surfaced by MDI's "Remove dormant accounts from sensitive groups" posture assessment — eliminates the latent privilege without disabling the underlying account, and is a prerequisite for any meaningful Tier-0 admin-tier-isolation strategy.

**Remediation action**

- [Remove dormant accounts from sensitive groups](https://learn.microsoft.com/en-us/defender-for-identity/security-posture-assessments/accounts)
- [Microsoft Defender for Identity security posture assessments](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment)
- [Protected accounts and groups in Active Directory](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-c--protected-accounts-and-groups-in-active-directory)

<!--- Results --->
%TestResult%
