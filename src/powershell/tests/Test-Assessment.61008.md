Custom security attributes are the primary mechanism for Conditional Access to distinguish between agent identities at scale. Without them, Conditional Access policies can only target all agent identities, individual agents by object ID, or agents grouped by blueprint. As your agent fleet grows, these mechanisms can't scale. Custom security attributes unlock the ability to filter agents by department, approval status, sensitivity tier, or any organization-defined classification. For example, an attribute set called `AgentAttributes` with an `AgentApprovalStatus` attribute (values such as `New`, `In_Review`, `HR_Approved`, `Finance_Approved`, `IT_Approved`) enables attribute-based Conditional Access policies that match agents to resources based on their classification.

When agent identities lack custom security attributes, the organization can't reliably enforce attribute-based Conditional Access policies. A newly provisioned or unclassified agent identity receives the same access controls as a fully vetted agent identity because there is no metadata to differentiate them. A threat actor who compromises or registers a rogue agent identity gains access without being subject to classification-based policy enforcement. Assigning custom security attributes closes this gap by ensuring every agent identity carries machine-readable classification metadata that Conditional Access and audit queries can consume.

Policies that target all agent identities without attribute filters may still provide baseline protection, but they can't distinguish between approved and unapproved agents. Implementing attribute-based controls requires:

- Defining an attribute taxonomy
- Coordinating with application owners
- Establishing an operational process to tag new agents as they're provisioned

**Remediation action**

- [Conditional Access for agent identities](https://learn.microsoft.com/entra/identity/conditional-access/agent-id?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Add or deactivate custom security attributes in Microsoft Entra ID](https://learn.microsoft.com/entra/fundamentals/custom-security-attributes-add?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Assign custom security attributes to an application](https://learn.microsoft.com/entra/identity/enterprise-apps/custom-security-attributes-apps?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Manage custom security attribute assignments using Microsoft Graph](https://learn.microsoft.com/graph/custom-security-attributes-examples?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Filter for applications in Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/concept-filter-for-applications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

