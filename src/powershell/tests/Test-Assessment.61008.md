Custom security attributes are the primary mechanism for Conditional Access to distinguish between agent identities at scale, and they must be assigned to agent identities as part of the identity lifecycle. Without custom security attributes, Conditional Access policies can only target all agent identities, individual agent identities by object ID, or agent identities grouped by blueprint — none of which scale as the agent fleet grows. Attributes unlock the most powerful targeting pattern: filtering agents by department, approval status, sensitivity tier, or any organization-defined classification. For example, an attribute set called AgentAttributes with an AgentApprovalStatus attribute (values such as New, In_Review, HR_Approved, Finance_Approved, IT_Approved) enables attribute-based Conditional Access policies that match agents to resources based on their classification.

When agent identities lack custom security attributes, the organization cannot reliably enforce Conditional Access policies and risks having gaps. This means that a newly provisioned or unclassified agent identity receives the same access controls as a fully vetted one, because there is no metadata to differentiate them. A threat actor who compromises or registers a rogue agent identity gains access to resources without being subject to classification-based policy enforcement. The absence of lifecycle tagging also degrades governance visibility — security teams cannot query, audit, or report on agent classification posture because there is nothing to query against. Assigning custom security attributes closes this gap by ensuring every agent identity carries machine-readable classification metadata that Conditional Access, and audit queries can consume.

**Remediation action**

1. [Add or deactivate custom security attributes in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/fundamentals/custom-security-attributes-add?tabs=ms-powershell)
2. [Assign custom security attributes to an application](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/custom-security-attributes-apps?pivots=portal)
3. [Manage custom security attribute assignments using Microsoft Graph](https://learn.microsoft.com/en-us/graph/custom-security-attributes-examples?tabs=http)
4. [Conditional Access for Agent ID (Preview)](https://learn.microsoft.com/en-us/entra/identity/conditional-access/agent-id)
5. [Filter for applications in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-filter-for-applications)

<!--- Results --->
%TestResult%
