When security key attestation isn't enforced, threat actors can exploit weak or compromised authentication hardware to establish persistent presence within organizational environments. Without attestation validation, malicious actors can register unauthorized or counterfeit FIDO2 security keys that bypass hardware-backed security controls, enabling them to perform credential stuffing attacks using fabricated authenticators that mimic legitimate security keys. This initial access lets threat actors escalate privileges by using the trusted nature of hardware authentication methods, then move laterally through the environment by registering more compromised security keys on high-privilege accounts. The lack of attestation enforcement creates a pathway for threat actors to establish command and control through persistent hardware-based authentication methods, ultimately leading to data exfiltration or system compromise while maintaining the appearance of legitimate hardware-secured authentication throughout the attack chain. 

**Remediation action**

- [Enable attestation enforcement through the Authentication methods policy configuration](https://learn.microsoft.com/entra/identity/authentication/how-to-enable-passkey-fido2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-passkey-fido2-authentication-method).
- [Configure approved list of security keys by Authenticator Attestation Globally Unique Identifier (AAGUID)](https://learn.microsoft.com/entra/identity/authentication/concept-fido2-hardware-vendor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

