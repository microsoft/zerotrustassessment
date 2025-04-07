Certificates, if not rotated regularly, can give an extended window for threat actors to attempt to extract and exploit those certificates, leading to unauthorized access. Credentials, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application. 

**Remediation action**
- [Define certificate based application configuration](https://learn.microsoft.com/en-us/graph/api/resources/certificatebasedapplicationconfiguration?view=graph-rest-beta)
- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/custom-create)

- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) 
- [Learn more about app managment policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)
<!--- Results --->
%TestResult%

