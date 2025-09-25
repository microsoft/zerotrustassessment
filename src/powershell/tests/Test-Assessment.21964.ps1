<#
.SYNOPSIS

#>

function Test-Assessment-21964{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21964,
    	Title = 'Enable protected actions to secure Conditional Access policy creation and changes',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Enable protected actions to secure Conditional Access policy creation and changes"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Protected actions for Conditional Access policy operations
    $protectedActions = @(
        "microsoft.directory-conditionalAccessPolicies-basic-update-patch",
        "microsoft.directory-conditionalAccessPolicies-create-post",
        "microsoft.directory-conditionalAccessPolicies-delete-delete",
        "microsoft.directory-resourceNamespaces-resourceActions-authenticationContext-update-post"
    )

    # Get protected action settings for each action
    $protectedActionResults = @()
    foreach ($action in $protectedActions) {
        Write-ZtProgress -Activity $activity -Status "Checking protected action: $action"

        $actionResult = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/resourceNamespaces/microsoft.directory/resourceActions/$action" -ApiVersion beta -Select "authenticationContextId,isAuthenticationContextSettable,name"
        $protectedActionResults += $actionResult
    }

    # Check if all protected actions have authentication context configured
    $unprotectedActions = $protectedActionResults | Where-Object { [string]::IsNullOrEmpty($_.authenticationContextId) }
    $query1 = $unprotectedActions.Count -eq 0

    if ($query1) {
        $testResultMarkdown = "All protected actions for Conditional Access policy operations have authentication context configured ✅"
    }
    else {
        $unprotectedCount = $unprotectedActions.Count
        $testResultMarkdown = "Found $unprotectedCount protected actions without authentication context configured ❌`n`n"
        $testResultMarkdown += "## Unprotected Actions`n`n"
        $testResultMarkdown += "| Action | Name | Authentication Context Settable |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        foreach ($action in $unprotectedActions) {
            $settable = if ($action.isAuthenticationContextSettable) { "✅ Yes" } else { "❌ No" }
            $testResultMarkdown += "| $($action.name) | $($action.name) | $settable |`n"
        }
    }

    $result = $passed


    Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
