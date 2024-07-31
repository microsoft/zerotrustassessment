Admin users are cloud native identities and not synced from on-premise or federated 

In Microsoft Entra ID, users who have privileged roles, such as administrators, are the root of trust to build and manage the rest of the environment.Use cloud-only accounts for Microsoft Entra ID and Microsoft 365 privileged roles.

Microsoft recommends that you ensure that synchronized objects hold no privileges beyond a user in Microsoft 365. Ensure these objects have no direct or nested assignment in trusted cloud roles or groups.

#### Remediation action

1. Perform the steps below for each [highly privileged role](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles).
2. Review the users listed that have an **OnPremisesImmutableId** and have **OnPremisesSyncEnabled** set.
3. Create a cloud only user account for that individual and remove their hybrid identity from privileged roles.

#### Related links

* [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks)
* [Privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/privileged-roles-permissions?tabs=admin-center)

<!--- Results --->
%TestResult%
