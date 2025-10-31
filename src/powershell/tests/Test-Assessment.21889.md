Organizations with extensive user-facing password surfaces expose multiple entry points for threat actors to launch credential-based attacks. Frequent user interactions with password prompts across applications, devices, and workflows increase the risk of exploitation. Threat actors often begin with credential stuffing—using compromised credentials from data breaches—followed by password spraying to test common passwords across multiple accounts. Once initial access is gained, they conduct credential discovery by examining browser password stores, cached credentials in memory, and credential managers to harvest additional authentication materials. These stolen credentials enable lateral movement, allowing attackers to access more systems and applications, often escalating privileges by targeting administrative accounts that still rely on password authentication. In the persistence phase, attackers may create backdoor accounts with password-based access or weaken defenses by altering password policies. To evade detection, they leverage legitimate authentication channels, blending in with normal user activity while maintaining persistent access to organizational resources. 

**Remediation action**

 * [Enable passwordless authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication)

 * [Deploy FIDO2 security keys](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2)

<!--- Results --->
%TestResult%
