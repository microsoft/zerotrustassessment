The default configuration allows any user in the tenant to register new apps and service principles. This can provide an avenue for threat actors to build malicious apps and phish users into signing to the app. 
Users may also create apps for production workloads in corporate tenants without oversight from the organization’s cyber security team.

#### Remediation action

1. In **Entra**, under **Identity** and **Users**, select **[User settings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)**.
2. For **Users can register applications**, select **No**.
3. Click **Save**.

#### Related links

* [Entra admin center - User settings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)

<!--- Results --->
%TestResult%
