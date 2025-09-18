Without a properly configured and assigned Local Users and Groups policy in Intune, threat actors can exploit unmanaged or misconfigured local accounts on Windows devices. This can lead to unauthorized privilege escalation, persistence, and lateral movement within the environment. If local administrator accounts are not controlled, attackers may create hidden accounts or elevate privileges, bypassing compliance and security controls. This increases the risk of data exfiltration, ransomware deployment, and regulatory non-compliance. Ensuring that Local Users and Groups policies are enforced across all managed devices is critical to maintaining a secure and compliant device fleet.

**Remediation action**

Create and assign Local Users and Groups policy in Intune: 
- [Policy CSP - LocalUsersAndGroups](https://learn.microsoft.com/windows/client-management/mdm/policy-csp-localusersandgroups) 

<!--- Results --->
%TestResult%


  