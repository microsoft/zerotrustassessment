<#!
.SYNOPSIS
Checks that all enterprise applications have owners assigned and lists permission names with classifications.
#>

function Test-Assessment-24518 {

    [ZtTest(
        Category = 'Application management',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 24518,
        Title = 'Enterprise applications have owners',
        UserImpact = 'Low'
    )]

    [CmdletBinding()]
    param(
        $Database
    )

    Test-ApplicationOwnership `
        -Database $Database `
        -TestId '24518' `
        -PrivilegeLevel 'ExcludeHigh' `
        -PassMessage 'All enterprise applications have at least two owners.' `
        -FailMessage 'Not all enterprise applications have at least two owners.' `
        -ReportTitle 'Enterprise Application Ownership' `
        -Activity 'Checking enterprise application ownership'
}
