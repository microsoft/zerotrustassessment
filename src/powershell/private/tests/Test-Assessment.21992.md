If certificates aren't rotated regularly, they can give threat actors an extended window to extract and exploit them, leading to unauthorized access. When credentials like these are exposed, attackers can blend their malicious activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the application's privileges.

Query all of your service principals and application registrations that have certificate credentials. Make sure the certificate start date is less than 180 days.

**Remediation action**

- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) 
- [Learn more about app management policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)
<!--- Results --->
%TestResult%

