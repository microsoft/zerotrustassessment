When Quick Access lacks user assignments, the service prevents connections to FQDNs and IP addresses configured in the application segments, disrupting access to resources like file shares, internal web applications, databases, and other on-premises resources that users require for business operations. The operational impact escalates when organizations deploy Quick Access to remote access to critical internal systems, as the lack of assignments creates gaps in business continuity where authorized users cannot reach resources through the Global Secure Access client, forcing them to seek alternative access methods that may bypass security controls such as conditional access policies and multifactor authentication. The disruption creates opportunities for threat actors to manipulate the remediation process by convincing administrators to implement temporary workarounds that disable security controls, or by exploiting the confusion during service restoration to gain initial access through alternative channels that lack monitoring and logging capabilities present in properly configured Private Access deployments. 

**Remediation action**

- [Assign users and groups to Quick Access applications](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-quick-access)

<!--- Results --->
%TestResult%
