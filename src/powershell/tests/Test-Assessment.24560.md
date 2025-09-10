If a Cloud LAPS (Local Administrator Password Solution) policy is not enforced, threat actors who gain access to endpoints can exploit static or weak local administrator passwords to escalate privileges, move laterally, and establish persistence. The attack chain typically begins with device compromise—via phishing, malware, or physical access—followed by attempts to harvest local admin credentials. Without Cloud LAPS, attackers can reuse compromised credentials across multiple devices, increasing the risk of privilege escalation and domain-wide compromise. Enforcing Cloud LAPS on all corporate Windows devices ensures unique, regularly rotated local admin passwords, disrupting the kill chain at the credential access and lateral movement stages, and significantly reducing the risk of widespread compromise.

**Remediation action**

- [How to create and assign Cloud LAPS policy:](https://learn.microsoft.com/en-us/mem/intune/protect/windows-laps-policy)

<!--- Results --->
%TestResult%
