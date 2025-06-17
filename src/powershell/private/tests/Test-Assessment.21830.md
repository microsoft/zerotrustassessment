Without restricting privileged role activations to dedicated Privileged Access Workstations (PAWs), threat actors can exploit compromised endpoint devices to perform privilege escalation attacks from unmanaged or non-compliant workstations. When administrators activate privileged roles from standard productivity workstations, these devices often contain attack vectors such as unrestricted web browsing, email clients vulnerable to phishing, and locally installed applications with potential vulnerabilities. Threat actors who gain initial access through malware, browser exploits, or social engineering can then leverage the locally cached privileged credentials or hijack existing authenticated sessions to escalate their privileges. Since privileged role activations grant extensive administrative rights across Microsoft Entra ID and connected services, attackers can establish persistent access by creating additional administrative accounts, modifying security policies, accessing sensitive data across all organizational resources, and deploying additional malware or backdoors throughout the environment. This lateral movement from a compromised endpoint to privileged cloud resources represents a critical attack path that bypasses many traditional security controls, as the privileged access appears legitimate when originating from an authenticated administrator's session.

Please note that passing this test means there is a conditional policy configured in the tenant which is a required control to enable a privileged access workstation program, but it is not the only one. Additional technical controls include attribute lifecycle, Intune, MDE, device provisioning, supply chain, etc.  

**Remediation action**

Follow the steps to implement a PAW program as documented here:

* [Deploying a privileged access solution - Privileged access](https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-deployment)
* [Configure device filters in Conditional Access to restrict privileged access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices)
* [Deploy privileged access workstations](https://learn.microsoft.com/en-us/security/privileged-access-workstations/privileged-access-deployment)

<!--- Results --->
%TestResult%
