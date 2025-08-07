<#
.SYNOPSIS
    Add detailed information about a check so that it can be displayed in the report.

.DESCRIPTION
    This function is used to add detailed information about a test so that it can be displayed in the test results report.

    The description and result support markdown format.

    If the calling script/cmdlet has a markdown file with the same name as the script/cmdlet,
    it will be used to populate the description and result fields.

    The markdown file can include a seperator `<!--- Results --->` to split the description and result sections.
    This allows for the overview and detailed information to be displayed separately in the Test results.

.EXAMPLE
    Add-ZtTestResultDetail -Description 'Description' -Result 'Result'

    This example adds detailed information about a test with a brief description and the result of the test.

    ```powershell
        $policiesWithoutEmergency = $policies | Where-Object { $CheckId -notin $_.conditions.users.excludeUsers -and $CheckId -notin $_.conditions.users.excludeGroups }

        Add-ZtTestResultDetail -GraphObjects $policiesWithoutEmergency -GraphObjectType ConditionalAccess
    ```

    This example shows how to use the Add-ZtTestResultDetail function to add rich markdown content to the test results with deep links to the admin portal.

#>

Function Add-ZtTestResultDetail {
    [CmdletBinding()]
    param(
        # Brief description of what this test is checking.
        # Markdown is supported.
        [Parameter(Mandatory = $false)]
        [string] $Description,

        # The status of the test. True for passed, False for failed.
        [bool] $Status,

        # Detailed information of the test result to provide additional context to the user.
        # This can be a summary of the items that caused the test to fail (e.g. list of user names, conditional access policies, etc.).
        # Markdown is supported.
        # If the test result contains a placeholder %TestResult%, it will be replaced with the values from the $GraphResult
        [Parameter(Mandatory = $false)]
        [string] $Result,

        # Collection of Graph objects to display in the test results report.
        # This will be inserted into the contents of Result parameter if the result contains a placeholder %TestResult%.
        [Object[]] $GraphObjects,

        # The type of graph object, this will be used to show the right deeplink to the test results report.
        [ValidateSet('AuthenticationMethod', 'AuthorizationPolicy', 'ConditionalAccess', 'ConsentPolicy',
            'Devices', 'DiagnosticSettings', 'Domains', 'Groups', 'IdentityProtection', 'Users', 'UserRole',
            'External collaboration'
        )]
        [string] $GraphObjectType,

        # The unique id of the test.
        [Parameter(Mandatory = $false)]
        [string] $TestId,

        # The short title of the test.
        [Parameter(Mandatory = $false)]
        [string] $Title,

        # [ValidateSet('NotConnectedAzure', 'NotConnectedExchange', 'NotDotGovDomain', 'NotLicensedEntraIDP1', 'NotConnectedSecurityCompliance',
        #     'NotLicensedEntraIDP2', 'NotLicensedEntraIDGovernance', 'NotLicensedEntraWorkloadID', "LicensedEntraIDPremium", 'NotSupported'
        # )]
        [string] $SkippedBecause,

        [ValidateSet('Catastrophic', 'High', 'Medium', 'Low')]
        [string] $UserImpact,

        [ValidateSet('High', 'Medium', 'Low')]
        [string] $Risk,

        [ValidateSet('High', 'Medium', 'Low')]
        [string] $ImplementationCost,

        [ValidateSet('Identity', 'Devices', 'Data')]
        [string[]] $AppliesTo,

        [ValidateSet('Credential', 'TenantPolicy', 'ExternalCollaboration', 'Application',
            'User', 'PrivilegedIdentity', 'ConditionalAccess', 'Authentication', 'AccessControl', 'Identity', 'Devices'
            )]
        [string[]] $Tag,

        # Optional. Custom status to return instead of the default status.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Investigate')]
        [string] $CustomStatus
    )

    $hasGraphResults = $GraphObjects -and $GraphObjectType

    if ($SkippedBecause) {
        $SkippedReason = Get-ZtSkippedReason $SkippedBecause

        if ([string]::IsNullOrEmpty($Result)) {
            $Result = "Skipped. $SkippedReason"
        }
    }

    if ([string]::IsNullOrEmpty($Description)) {
        # Check if a markdown file exists for the cmdlet and parse the content
        $cmdletPath = $MyInvocation.PSCommandPath
        $markdownPath = $cmdletPath -replace '.ps1', '.md'
        if (Test-Path $markdownPath) {
            # Read the content and split it into description and result with "<!--- Results --->" as the separator
            $content = Get-Content $markdownPath -Raw
            $splitContent = $content -split "<!--- Results --->"
            $mdDescription = $splitContent[0]
            $mdResult = $splitContent[1]

            if (![string]::IsNullOrEmpty($Result)) {
                # If a result was provided in the parameter insert it into the markdown content
                if ($mdResult -match "%TestResult%") {
                    $mdResult = $mdResult -replace "%TestResult%", $Result
                }
                else {
                    $mdResult = $Result
                }
            }

            $Description = $mdDescription
            $Result = $mdResult
        }
    }

    if ($hasGraphResults) {
        $graphResultMarkdown = Get-GraphObjectMarkdown -GraphObjects $GraphObjects -GraphObjectType $GraphObjectType
        $Result = $Result -replace "%TestResult%", $graphResultMarkdown
    }

    # Check if the docs team have provided a title for the test and use it if available
    $testMeta = $__ZtSession.TestMeta[$TestId]
    $docsTitle = $Title # Default to the title provided in the parameter

    if ($null -ne $testMeta -and ![string]::IsNullOrEmpty($testMeta.Title)) {
        Write-PSFMessage "Using title from docs" -Level Debug -Tag Test
        $docsTitle = $testMeta.Title
        if(![string]::IsNullOrEmpty($testMeta.Category)) {
            $category = $testMeta.Category
        }
        if(![string]::IsNullOrEmpty($testMeta.RiskLevel)) {
            $Risk = $testMeta.RiskLevel
        }
        if(![string]::IsNullOrEmpty($testMeta.ImplementationCost)) {
            $ImplementationCost = $testMeta.ImplementationCost
        }
        if(![string]::IsNullOrEmpty($testMeta.UserImpact)) {
            $UserImpact = $testMeta.UserImpact
        }
    }

    $testInfo = @{
        TestId                 = $TestId
        TestTitle              = $docsTitle
        TestStatus             = Get-ZtTestStatus -Status $Status -SkippedBecause $SkippedBecause -CustomStatus $CustomStatus
        TestCategory           = $category
        TestTags               = $Tag
        TestAppliesTo          = $AppliesTo
        TestImpact             = $UserImpact
        TestRisk               = $Risk
        TestImplementationCost = $ImplementationCost
        TestSfiPillar           = $testMeta.SfiPillar
        TestDescription        = $Description
        TestResult             = $Result
        TestSkipped            = $SkippedBecause
        SkippedReason          = $SkippedReason
    }

    Write-ZtProgress -Activity "Running tests" -Status $Title
    Write-PSFMessage "Adding test result detail for $Title" -Tag Test
    Write-PSFMessage "Result: $Result" -Level Debug -Tag Test

    if ($__ZtSession -and $__ZtSession.TestResultDetail) {
        if (![string]::IsNullOrEmpty($TestId)) {
            # Only set if we are running in the context of Maester
            $__ZtSession.TestResultDetail[$TestId] = $testInfo
        }
    }
}
