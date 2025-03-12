An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer through attacks like phishing, credential stuffing, or exploiting weak passwords. They might also target unpatched vulnerabilities in infrastructure, use remote code execution exploits, Kerberoasting, or pass-the-hash attacks to escalate privileges. Misconfigured remote access tools like RDP, VPN, or jump servers provide other entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user, and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.

**Remediation action**

- [Migrate from federation to cloud authentication](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

