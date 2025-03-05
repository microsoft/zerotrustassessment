An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer leveraging phishing, credential stuffing, or exploiting weak passwords. In parallel, they may also target unpatched vulnerabilities in infrastructure servers, using remote code execution exploits, Kerberoasting, or pass-the-hash attacks to escalate privileges. Misconfigured RDP, VPNs, or jump servers provide additional entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.

**Remediation action**

[Migrate from federation to cloud authentication in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication)
<!--- Results --->
%TestResult%
