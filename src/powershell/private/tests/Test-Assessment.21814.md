If an on-premises account is compromised and is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate other on-premises user accounts.

If privileged cloud accounts are synchronized with on-premises accounts, an attacker who acquires credentials for on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.

**Remediation action**

- [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specific-security-recommendations)

For each role with high privileges (assigned permanently or eligible through Microsoft Entra Privileged Identity Management), you should do the following actions:

- Review the users that have onPremisesImmutableId and onPremisesSyncEnabled set. See [Microsoft Graph API user resource type](https://learn.microsoft.com/graph/api/resources/user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Create cloud-only user accounts for those individuals and remove their hybrid identity from privileged roles.
<!--- Results --->
%TestResult%

