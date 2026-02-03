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

function Add-ZtTestResultDetail {
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

		[ValidateSet('NotConnectedAzure', 'NotConnectedExchange', 'NotDotGovDomain', 'NotLicensedEntraIDP1', 'NotConnectedSecurityCompliance',
		    'NotLicensedEntraIDP2', 'NotLicensedEntraIDGovernance', 'NotLicensedEntraWorkloadID', 'NotSupported', 'UnderConstruction',
			'NotLicensedIntune', 'NoAzureAccess'
		)]
		[string] $SkippedBecause,

		[ValidateSet('Catastrophic', 'High', 'Medium', 'Low')]
		[string] $UserImpact,

		[ValidateSet('High', 'Medium', 'Low')]
		[string] $Risk,

		[ValidateSet('High', 'Medium', 'Low')]
		[string] $ImplementationCost,

		[ValidateSet('Identity', 'Devices', 'Data')]
		[string[]] $AppliesTo, #TODO Update this to specific product (Entra, Intune, etc)

		[ValidateSet('Credential', 'TenantPolicy', 'ExternalCollaboration', 'Application',
			'User', 'PrivilegedIdentity', 'ConditionalAccess', 'Authentication', 'AccessControl', 'Identity', 'Devices'
		)]
		[string[]] $Tag,

		# Optional. Custom status to return instead of the default status.
		[Parameter(Mandatory = $false)]
		[ValidateSet('Investigate')]
		[string] $CustomStatus
	)

	#region Resolve Test Item
	$testMeta = Get-ZtTest -Current
	# If test is executed outside of the module (e.g. solo test during dev), make sure the Test resolution still works anyway
	if (-not $testMeta -and $TestId) {
		$testMeta = Get-ZtTest -Tests $TestId
	}
	# Case: Completely new test, that the module cannot resolve yet
	if (-not $testMeta) {
		$testMeta = Get-ZtTestMetadata -Command (Get-PSCallStack)[1].InvocationInfo.MyCommand
	}
	#endregion Resolve Test Item

	$actualTestId = $TestId
	if (-not $actualTestId) {
		$actualTestId = $testMeta.TestId
	}

	$hasGraphResults = $GraphObjects -and $GraphObjectType

	if ($SkippedBecause) {
		$SkippedReason = Get-ZtSkippedReason -SkippedBecause $SkippedBecause

		if (-not $Result) {
			$Result = "Skipped. $SkippedReason"
		}
	}

	if (-not $Description) {
		# Check if a markdown file exists for the cmdlet and parse the content
		$markdownPath = Join-Path -Path $script:ModuleRoot -ChildPath "tests/Test-Assessment.$actualTestId.md"
		if (Test-Path $markdownPath) {
			# Read the content and split it into description and result with "<!--- Results --->" as the separator
			$content = Get-Content $markdownPath -Raw
			$splitContent = $content -split "<!--- Results --->"
			$mdDescription = $splitContent[0]
			$mdResult = $splitContent[1]

			if ($Result) {
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

	$docsTitle = $Title # Default to the title provided in the parameter

	if ($testMeta.Title) {
		$docsTitle = $testMeta.Title
	}
	if ($testMeta.Category) {
		$category = $testMeta.Category
	}
	if ($testMeta.RiskLevel) {
		$Risk = $testMeta.RiskLevel
	}
	if ($testMeta.ImplementationCost) {
		$ImplementationCost = $testMeta.ImplementationCost
	}
	if ($testMeta.UserImpact) {
		$UserImpact = $testMeta.UserImpact
	}

	$testInfo = @{
		TestId                 = $actualTestId
		TestTitle              = $docsTitle
		TestStatus             = Get-ZtTestStatus -Status $Status -SkippedBecause $SkippedBecause -CustomStatus $CustomStatus
		TestCategory           = $category
		TestTags               = $Tag
		TestAppliesTo          = $AppliesTo
		TestImpact             = $UserImpact
		TestRisk               = $Risk
		TestImplementationCost = $ImplementationCost
		TestSfiPillar          = $testMeta.SfiPillar
		TestPillar             = $testMeta.Pillar
		TestMinimumLicense     = $testMeta.MinimumLicense
		TestDescription        = $Description
		TestResult             = $Result
		TestSkipped            = $SkippedBecause
		SkippedReason          = $SkippedReason
	}

	Write-ZtProgress -Activity "Running tests" -Status $docsTitle
	Write-PSFMessage "Adding test result detail for $docsTitle" -Tag Test
	Write-PSFMessage "Result: $Result" -Level Debug -Tag Test

	if ($script:__ZtSession -and $script:__ZtSession.TestResultDetail) {
		if ($actualTestId) {
			# Only set if we are running in the context of a current Test
			$script:__ZtSession.TestResultDetail.Value[$actualTestId] = $testInfo
		}
	}
}
