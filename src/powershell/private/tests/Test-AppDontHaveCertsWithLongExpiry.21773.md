Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.

#### Remediation

- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)
- [certificateBasedApplicationConfiguration](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration)
- [Create a the least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create) 

<!--- Results --->
%TestResult%
