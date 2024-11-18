Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application. 

**Remediation action**

- Define certificate based application configuration  https://devblogs.microsoft.com/identity/app-management-policy/ 
- Define trusted certificate authorities for aps and serivce principals in the teantnt https://learn.microsoft.com/en-us/graph/api/resources/certificatebasedapplicationconfiguration
- Define application management polcieis https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy
- Create a the least-privileged custom role to rotate application credentials : https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create 
<!--- Results --->
%TestResult%

