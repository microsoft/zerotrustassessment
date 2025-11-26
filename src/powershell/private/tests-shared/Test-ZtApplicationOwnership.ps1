function Test-ZtApplicationOwnership {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database,

        [Parameter(Mandatory = $true)]
        [string]
		$TestId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('High', 'Medium', 'Low', 'Unranked')]
        [string[]]
		$PrivilegeLevel,

        [Parameter(Mandatory = $true)]
        [string]
		$PassMessage,

        [Parameter(Mandatory = $true)]
        [string]
		$FailMessage,

        [Parameter(Mandatory = $true)]
        [string]
		$ReportTitle,

        [string]
		$Activity = 'Checking enterprise application ownership'
    )

	#region Helper Functions
	function Get-ZtiOwnershipReport {
		[CmdletBinding()]
		param(
			[Parameter()]
			[array]$Applications,

			[Parameter(Mandatory = $true)]
			[string]$TestId,

			[Parameter(Mandatory = $true)]
			[string]$PassMessage,

			[Parameter(Mandatory = $true)]
			[string]$FailMessage,

			[Parameter(Mandatory = $true)]
			[string]$ReportTitle
		)

		# If no apps found with insufficient owners, test passes
		if ($Applications.Count -eq 0) {
			return @{
				TestId = $TestId
				Status = $true
				Result = $PassMessage
			}
		}

		# Build table header
		$tableHeader =  "| App name | Multi-tenant | Permission  | Classification | Owner count |`n"
		$tableHeader += "| :-------- | :------------ | :---------- | :------------- | :----------- |`n"

		$tableRows = ''

		foreach ($app in $Applications) {
			$isMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'

			# Collect all unique permissions for display
			$allPermissions = @()
			if ($app.DelegatePermissions) { $allPermissions += $app.DelegatePermissions }
			if ($app.AppPermissions) { $allPermissions += $app.AppPermissions }

			$permList = if ($allPermissions.Count -gt 0) {
				($allPermissions | Select-Object -Unique | Sort-Object) -join ', '
			} else {
				'None'
			}

			# Use the overall app Risk (already calculated by Get-GraphRisk)
			$classification = $app.Risk ?? 'Unranked'

			# Build clickable Entra portal link
			$entraLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/$($app.id)"
			$safeDisplayName = Get-SafeMarkdown -Text $app.displayName
			$appLink = "[$safeDisplayName]($entraLink)"

			$tableRows += "| $appLink | $isMultiTenant | $permList | $classification | $($app.OwnerCount) |`n"
		}

		$reportTable = $tableHeader + $tableRows

		# Test fails if we have apps with insufficient owners
		$testResultMarkdown = "$FailMessage`n`n"
		$testResultMarkdown += "## $ReportTitle`n`n"
		$testResultMarkdown += $reportTable

		return @{
			TestId = $TestId
			Status = $false
			Result = $testResultMarkdown
		}
	}
	#endregion Helper Functions

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    Write-ZtProgress -Activity $Activity -Status 'Getting applications with insufficient owners'

    # Get applications based on privilege level
    $filteredApps = Get-ApplicationsWithInsufficientOwners -Database $Database -PrivilegeLevel $PrivilegeLevel

    # Build report and get parameters for Add-ZtTestResultDetail
    Write-ZtProgress -Activity $Activity -Status 'Building report for applications with insufficient owners'

    $params = Get-ZtiOwnershipReport `
        -Applications $filteredApps `
        -TestId $TestId `
        -PassMessage $PassMessage `
        -FailMessage $FailMessage `
        -ReportTitle $ReportTitle

    Add-ZtTestResultDetail @params
}
