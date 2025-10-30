Without activation alerts for Global Administrator role assignments, threat actors can perform role activation without detection, allowing them to establish persistence in the environment. When Global Administrator roles are activated without notification mechanisms, threat actors who have compromised accounts can escalate privileges, bypassing security monitoring. The absence of alerts creates a blind spot where threat actors can activate the most privileged role in the tenant and perform actions such as creating backdoor accounts, modifying security policies, or accessing sensitive data without immediate detection. This lack of visibility allows threat actors to maintain access and execute their objectives while appearing to use legitimate administrative functions, making it difficult for security teams to distinguish between authorized and unauthorized privilege escalation activities.

**Remediation action**

- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings)

<!--- Results --->
%TestResult%
