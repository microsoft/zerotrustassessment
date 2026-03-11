<#
.SYNOPSIS
    Returns the description for why a test was skipped.
#>
function Get-ZtSkippedReason {
    [CmdletBinding()]
    param(
        # The reason for skipping
        [string] $SkippedBecause
    )

    switch ($SkippedBecause) {
        "NotConnectedAzure" { "Not connected to Azure." ; break}
        "NotConnectedExchange" { "Not connected to Exchange Online."; break}
        "NotConnectedSecurityCompliance" { "Not connected to Security & Compliance."; break}
        "NotDotGovDomain" { "This test is only for federal, executive branch, departments and agencies."; break}
        "NotLicensedEntraIDP1" { "This test is for tenants that are licensed for Entra ID P1. See [Entra ID licensing](https://learn.microsoft.com/entra/fundamentals/licensing)"; break}
        "NotLicensedEntraIDP2" { "This test is for tenants that are licensed for Entra ID P2. See [Entra ID licensing](https://learn.microsoft.com/entra/fundamentals/licensing)"; break}
        "NotLicensedEntraIDGovernance" { "This test is for tenants that are licensed for Entra ID Governance. See [Entra ID Governance licensing](https://learn.microsoft.com/entra/fundamentals/licensing#microsoft-entra-id-governance)"; break}
        "NotLicensedEntraWorkloadID" { "This test is for tenants that are licensed for Entra Workload ID. See [Entra Workload ID licensing](https://learn.microsoft.com/entra/workload-id/workload-identities-faqs)"; break}
        "NotLicensedIntune" { "This test is for tenants that are licensed for Microsoft Intune. See [Microsoft Intune licensing](https://learn.microsoft.com/intune/intune-service/fundamentals/licenses)"; break}
        "NotSupported" { "This test relies on capabilities not currently available (e.g., cmdlets that are not available on all platforms, Resolve-DnsName)"; break}
        "NoAzureAccess" { "The signed in user does not have access to the Azure subscription to perform this test."; break}
        "NotApplicable" { "This test is not applicable to the current environment."; break}
        "NotConnectedToService" { "This test requires connection to the service(s) `"{0}`" currently disconnected.  Please use _Connect-ZtAssessment_ to connect."; break}
        "NoCompatibleLicenseFound" { "This test requires one of the following licenses: (`"{0}`").  Please ensure your tenant has the appropriate licenses to run this test.  See [Licensing & Service Plans](https://learn.microsoft.com/en-gb/entra/identity/users/licensing-service-plan-reference)"; break}
        "TimeoutReached" { "This test was not completed because the report execution exceeded the expected time frame. This could be due to a large number of objects in the tenants. Please consider adding ``-Timeout '03:00:00:00'`` to ``Invoke-ZtAssessment``."; break}
        default { $SkippedBecause; break}
    }
}
