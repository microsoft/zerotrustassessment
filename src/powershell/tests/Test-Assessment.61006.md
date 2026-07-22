The AI control plane surface includes Microsoft 365, Microsoft Power Platform, Microsoft SharePoint, and every layer of the Microsoft Security stack. Microsoft Entra ID is the identity control plane for this entire surface, and its administrative scopes manage agent identities, Microsoft 365 Copilot admin settings, Conditional Access for AI, Copilot Studio environments, AI grounding sources, AI posture signals, and AI detection and response. If there's no human assigned to an administrative role that manages these AI capabilities, then there's no accountable operator for that slice of the AI surface. This gap could mean:

- Agent identities aren't monitored or reviewed
- Admin settings drift
- AI-specific detections have no owner to investigate or adjust
- Network control policies for AI aren't adjusted as the AI estate evolves
- AI-related escalations have no designated responder

Threat actors exploit this gap by targeting the AI control plane directly. They rely on the gap between a role existing in the directory and someone actually monitoring it. Confirming that every AI admin role has at least one assigned principal is the minimum organizational posture for AI administration. This check evaluates Microsoft Entra directory role assignments only. A role appearing as unassigned means no Microsoft Entra principal is assigned to the corresponding directory role, so workload-native administrators might still exist outside Microsoft Entra and are outside this assessment. AI administration of other platforms, such as Microsoft Purview role groups or Microsoft Defender custom roles, must be reviewed separately.

**Remediation action**

- [Assign a Microsoft Entra ID role via the admin center](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create a PIM-eligible assignment for a Microsoft Entra ID role](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-add-role-to-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

