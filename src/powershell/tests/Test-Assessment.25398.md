When administrators use Microsoft Entra Private Access to reach domain controllers through Remote Desktop Protocol (RDP), they authenticate through Microsoft Entra ID before the Global Secure Access client tunnels their connection to the on-premises network. Domain controllers hold the cryptographic keys to the entire Active Directory forest. Compromising one domain controller offers a way to compromise every identity and resource in the organization.

Without phishing-resistant authentication:

- Threat actors can intercept credentials during phishing campaigns or adversary-in-the-middle attacks.
- Stolen session tokens can be replayed to establish RDP connections to domain controllers.
- Once connected, threat actors can execute DCSync attacks to harvest all password hashes in the domain.
- Attackers can create golden tickets for indefinite domain persistence.
- Group Policy Objects can be modified to deploy ransomware or backdoors across all domain-joined machines.

By requiring phishing-resistant authentication, organizations ensure that even if users are successfully phished, threat actors can't replay credentials because these methods require cryptographic proof of possession.

**Remediation action**

- [Deploy phishing-resistant authentication methods to domain controller administrators](https://learn.microsoft.com/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Require phishing-resistant authentication for administrators accessing domain controllers via RDP](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-domain-controllers?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

