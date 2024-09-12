External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use them as valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.

Allowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create additional external accounts, thereby multiplying their access points and making it harder to detect the intrusion.

#### Remediation action

1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.
2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.
3. Click **Save**.

#### Related links

- [Enable B2B external collaboration settings](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure)
- [AuthorizationPolicy](https://learn.microsoft.com/graph/api/resources/authorizationpolicy?view=graph-rest-1.0)

<!--- Results --->
%TestResult%
