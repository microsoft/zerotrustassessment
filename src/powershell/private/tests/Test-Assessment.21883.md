Configuring workload identity based on risk policy in Microsoft Entra ID is a critical security measure that ensures only trusted and verified workloads can access sensitive resources. Without these policies, threat actors can compromise workload identities with minimal detection to perform further attacks. The lack of conditional controls for risk detections, such as anomalous activity, allows malicious operations like token forgery, sensitive resource access, and disruption of workloads to proceed unchecked. The lack of automated containment mechanisms increases dwell time and impacts the confidentiality, integrity, and availability of critical services.

**Remediation action**

Create a risk-based Conditional Access policy for workload identities.

[Create a risk-based Conditional Access policy](/entra/identity/conditional-access/workload-identity#create-a-risk-based-conditional-access-policy)

<!--- Results --->
%TestResult%
