# Connected Services checks

The `[ZtTest()]` attribute can be used to mark the required services needed for a test.

## Behavior of connected services checks

Before executing the test, the checks will compare the required services with the connected services to determine if the test can be executed or if it should be skipped.  
The connected services are determined based on what `Connect-ZtAssessment` has connected to.

For example, if you have connected to Graph and Azure, then those services will be included in the connected services. If a test requires a service that is not in the connected services, then the test will be skipped, and the report will display that the test was not executed due to missing service connections.

## Defining required services for a test

Here's how the attribute looks like when defining the required services for a test:

```powershell
function Test-Assessment-xxxxx {
    [ZtTest(
        Category = 'Application Proxy',
        ImplementationCost = 'Medium',

        Service = ('Graph', 'Azure', 'AipService'),

        CompatibleLicense = ('AAD_PREMIUM'),
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

In this example the test requires the 'Graph', 'Azure', and 'AipService' services to be connected in order for the test to be executed. If any of these services are not connected, the test will be skipped, and the report will indicate that the test was not executed due to missing service connections.

The message should show which services are required and which services are currently connected to help the user understand why the test was skipped and what they can do to enable it.

## Connecting to services

To connect to the required services, you can use the `Connect-ZtAssessment` function, which allows you to specify which services you want to connect to. For example:

```powershell
Connect-ZtAssessment -Services 'Graph', 'Azure', 'AipService'
```

This command will connect to the Graph, Azure, and AipService services, which will allow any tests that require these services to be executed successfully.

## Under the hood

From the PowerShell module standpoint, the connected services are populated during the call to Connect-ZtAssessment, and stored in the `$script:ConnectedServices` module-scoped variable.

Each call to `Connect-ZtAssessment` will update the `$script:ConnectedServices` variable with the services specified in the `-Services` parameter if the connection does not raise an exception.

If the `-Services` parameter is not specified, it will default to connecting to all available services, which will be reflected in the `$script:ConnectedServices` variable.

## Logic

When a test is executed, the checks will compare the required services specified in the `[ZtTest()]` attribute with the services listed in `$script:ConnectedServices`. If any required service is not present in `$script:ConnectedServices`, the test will be skipped, and a message will be displayed indicating which services are required and which services are currently connected.

If the attribute does not specify any required services, the test will be executed regardless of the connected services.
