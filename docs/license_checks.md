# License Checks

The `[ZtTest()]` attribute can be used to mark the licenses required for a test with the property `CompatibleLicense`. This property accepts an array of strings representing the licenses that are required for the test to be executed.

This `CompatibleLicense` property replaces `MinimumLicense`, and supports multiple licenses and combination.

## Behavior of license checks

Before executing the test, the checks will compare the required licenses with the current licenses to determine if the test can be executed or if it should be skipped.  

The license are referenced here "[Licensing & Service Plans](https://learn.microsoft.com/en-gb/entra/identity/users/licensing-service-plan-reference)".

## Licenses are Service Plan Names

The licenses specified in the `CompatibleLicense` property should correspond to the service plan names of the subscribed SKUs that are returned by the `Get-ZtCurrentLicense` function. These service plan names represent the specific licenses or subscriptions that the tenant has. You can retrieve the list of service plan names for the subscribed SKUs using the following command:

```PowerShell
(Invoke-ZtGraphRequest -RelativeUri "subscribedSkus").servicePlans.servicePlanName | Sort-Object -Unique
```

Or use the `Get-ZtCurrentLicense` function, which will, once connected, return the licenses subscribed by the tenant.

```powershell
Get-ZtCurrentLicense
```

## Defining required licenses for a test

Here's how the attribute looks like when defining the required licenses for a test:

```powershell
function Test-Assessment-xxxxx {
    [ZtTest(
        Category = 'Application Proxy',
        ImplementationCost = 'Medium',
        Service = ('Graph', 'Azure', 'AipService'),

        CompatibleLicense = ('AAD_PREMIUM_P2'),

        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = xxxxx,
        Title = 'Test Title',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    # Test implementation code here...
}
```

### Additive licenses

The `CompatibleLicense` property can specify one or more suitable licenses, and at least one of the licenses must be present in the current tenant for the test to run. For example, if a test specifies `CompatibleLicense = ('AAD_PREMIUM', 'AAD_PREMIUM_P2')`, then the test will be executed if the tenant has either `AAD_PREMIUM` or `AAD_PREMIUM_P2` license.

However, it is worth noting that licenses are additives, meaning that if a tenant has `AAD_PREMIUM_P2`, it also includes the license `AAD_PREMIUM`. Therefore, if a test requires `AAD_PREMIUM`, it will be executed for tenants with either `AAD_PREMIUM` or `AAD_PREMIUM_P2` licenses.

For tests that require `AAD_PREMIUM_P2`, there is no need to specify `AAD_PREMIUM` as well, since `AAD_PREMIUM_P2` already includes the license `AAD_PREMIUM`.

### Combination of licenses

In some cases, a test may require a combination of licenses to be present in the tenant. For example, if a test specifies `CompatibleLicense = ('AAD_PREMIUM&INTUNE_A')`, then the test will only be executed if the tenant has both `AAD_PREMIUM` **and** `INTUNE_A` licenses.

You can specify as many combinations of licenses as needed for a test. For example, `CompatibleLicense = ('AAD_PREMIUM&INTUNE_A', 'AAD_PREMIUM_P2')` means that the test will be executed if the tenant has either both `AAD_PREMIUM` and `INTUNE_A` licenses, or if it has the `AAD_PREMIUM_P2` license.

You can also combine more than two licenses in a combination, such as `CompatibleLicense = ('AAD_PREMIUM&INTUNE_A&OFFICE365_E5')`, which means that the test will only be executed if the tenant has all three licenses: `AAD_PREMIUM`, `INTUNE_A`, and `OFFICE365_E5`.

### Listing Available licenses

To list the available licenses once connected, you can use the following function:

```powershell
Get-ZtCurrentLicense
```

This function will return the list of licenses (service plans names) that the tenant is currently subscribed to, which can help you determine which tests will be executed based on the licenses you have.

This response is cached by default to optimize performance, but you can use the `-Force` parameter to refresh the cache and get the most up-to-date information about the tenant's licenses.

## Under the hood

From the PowerShell module standpoint, the available licenses are populated during the first call to `Get-ZtCurrentLicense`, and stored in the `$script:CurrentLicense` module-scoped variable, until a refresh is forced with the `-Force` parameter.

For development and testing purposes, you can also set the `$script:CurrentLicense` variable manually to simulate different license scenarios without needing to connect to a tenant or call the Microsoft Graph API:

```powershell
$ztaModule = Get-Module -Name "ZtAssessment"
&$ztaModule { $script:CurrentLicense = $script:CurrentLicense.Where{$_ -notin @('AAD_PREMIUM')} }
```

## Logic

When a test is executed, the checks will compare the required licenses specified in the `[ZtTest()]` attribute with the licenses listed in `$script:CurrentLicense`. If any required license is not present in `$script:CurrentLicense`, the test will be skipped, and a message will be displayed indicating which licenses are required and which licenses are currently available.

If the attribute does not specify any required licenses, the test will be executed regardless of the available licenses, potentially resulting in failed tests if the implementation relies on licenses that are not present in the tenant. Therefore, it is important to accurately specify the required licenses for each test to ensure that they are executed in the appropriate environments.
