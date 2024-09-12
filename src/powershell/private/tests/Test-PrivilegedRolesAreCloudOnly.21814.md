If an on-premises account is compromised and the account is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate any on-premises user accounts.

If privileged cloud accounts are synchronized with on-premises accounts, an attacker who dumps credentials on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.

#### Remediation action

1. Perform the steps below for each [highly privileged role](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles).
2. Review the users listed that have an **OnPremisesImmutableId** and have **OnPremisesSyncEnabled** set.
3. Create a cloud only user account for that individual and remove their hybrid identity from privileged roles.

#### Related links

* [Secure access practices for administrators in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/security-planning)
* [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks)
* [Privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/privileged-roles-permissions?tabs=admin-center)

<!--- Results --->
%TestResult%
