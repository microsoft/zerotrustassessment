
<#
.SYNOPSIS

#>

function Test-Assessment-21770 {
	[ZtTest(
		Category = 'Access control',
		ImplementationCost = 'Low',
		MinimumLicense = ('P1'),
		Pillar = 'Identity',
		RiskLevel = 'Medium',
		SfiPillar = 'Protect engineering systems',
		TenantType = ('Workforce','External'),
		TestId = 21770,
		Title = 'Inactive applications don’’t have highly privileged Microsoft Graph API permissions',
		UserImpact = 'High'
	)]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    # Get all applications with permissions using common function
    $results = Get-ApplicationsWithPermissions -Database $Database

    # Filter to only show High and Unranked risk apps (exclude Medium and Low)
    $results = $results | Where-Object { $_.Risk -in @('High', 'Unranked') }

    $inactiveRiskyApps = @()
    $otherApps = @()

    foreach($item in $results) {
        if([string]::IsNullOrEmpty($item.lastSignInDateTime) -and $item.IsRisky) {
            $inactiveRiskyApps += $item
        }
        else {
            $otherApps += $item
        }
    }

    $passed = $inactiveRiskyApps.Count -eq 0

    if ($passed) {
        $testResultMarkdown += "No inactive applications with high privileges`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Inactive Application(s) with high privileges were found`n`n%TestResult%"
    }

    $mdInfo = "`n## Apps with privileged Graph permissions`n`n"
    $mdInfo += "| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"
    $mdInfo += Get-AppList -Apps $inactiveRiskyApps -Icon "❌"
    $mdInfo += Get-AppList -Apps $otherApps -Icon "✅"


    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId = '21770'
        Title = 'Inactive applications don''t have highly privileged permissions'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
