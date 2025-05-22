App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations. 

**Remediation action**

Enable the app instance property lock for all multitenant applications and specify the properties to lock. 
- [Configure app instance property lock for your applications](https://learn.microsoft.com/entra/identity-platform/howto-configure-app-instance-property-locks) 
<!--- Results --->
%TestResult%
