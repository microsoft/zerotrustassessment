Container labels extend sensitivity classification beyond individual files to entire collaboration workspaces including Microsoft Teams, Microsoft 365 Groups, and SharePoint sites. These labels control container-level settings such as external sharing policies, guest access permissions, device access restrictions, and privacy (public vs private). Without container labels, organizations cannot enforce consistent security policies at the workspace level, allowing users to create Teams with external guest access enabled even when handling confidential information. This gap creates data exfiltration risks where properly labeled documents exist within improperly secured collaboration spaces. Container labels ensure that workspace security posture matches the sensitivity of content stored within, preventing scenarios where "Highly Confidential" documents reside in Teams that permit external sharing. Organizations using Microsoft Teams or Microsoft 365 Groups for collaboration require container labels to maintain governance over workspace creation and access controls.

**Remediation action**
- Navigate to Microsoft Purview portal → Information protection → Labels
- Create a new label or edit existing label
- Under "Define the scope for this label", enable "Groups & sites".
- Configure container protection settings:
   - Privacy (Public/Private)
   - External user access
   - External sharing
   - Unmanaged device access
   - Conditional Access policy
- Publish label through label policy.
- [Use sensitivity labels with Microsoft Teams, Microsoft 365 Groups, and SharePoint sites](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-teams-groups-sites)
<!--- Results --->
%TestResult%
