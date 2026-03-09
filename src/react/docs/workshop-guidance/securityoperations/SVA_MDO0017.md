# Phishing Triage Agent in Microsoft Defender

**Implementation Effort:** Medium — Setup requires provisioning Security Copilot capacity, configuring Defender for Office 365 Plan 2, assigning permissions, and enabling plugins. It’s a project-driven task but doesn’t require ongoing infrastructure changes.

**User Impact:** High — All users who Report Message as Phishing using the outlook setting emails in Outlook trigger the agent, and their submissions are analyzed and acted upon, making this a high-touch feature across the organization.

## Overview

The Phishing Triage Agent is an AI-driven capability in Microsoft Defender XDR that automates the classification and handling of user-reported phishing emails. Instead of requiring SOC analysts to manually review every suspicious email, the agent uses large language models (LLMs) and contextual security signals to determine whether a reported message is malicious or benign.
The agent provides transparent reasoning for its decisions, including plain-language explanations and visual reasoning paths, and continuously improves through analyst feedback. It integrates deeply with Defender for Office 365 Plan 2, Defender XDR, and Microsoft Threat Intelligence, ensuring end-to-end protection.
Without deployment, SOC teams must manually investigate every reported email, slowing response times and increasing the risk of missed threats. This capability supports the Zero Trust principle of **Assume breach** by enabling faster detection and response, minimizing exposure to phishing attacks..

## Reference

- [Phishing Triage Agent in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/phishing-triage-agent)  
- [Activate URBAC settings](https://learn.microsoft.com/en-us/defender-xdr/phishing-triage-agent#activate-urbac-settings)
- [Enable user reported phishing](https://learn.microsoft.com/en-us/defender-office-365/submissions-user-reported-messages-custom-mailbox?view=o365-worldwide#use-the-microsoft-365-defender-portal-to-configure-the-user-submissions-mailbox-for-email)

