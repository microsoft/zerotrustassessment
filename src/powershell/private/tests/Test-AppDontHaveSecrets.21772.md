Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management makes client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.

**Remediation action**

- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets).
   - Use managed identities for Azure resources
   - Deploy Conditional Access policies for workload identities
   - Implement secret scanning
   - Deploy application authentication policies to enforce secure authentication practices
   - Create a least-privileged custom role to rotate application credentials
   - Ensure you have a process to triage and monitor applications
<!--- Results --->
%TestResult%





