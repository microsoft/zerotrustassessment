<#
.SYNOPSIS

#>

function Test-Assessment-21787{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Permissions to create new tenants is limited to the Tenant Creator role"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0
    $passed = -not $result.defaultUserRolePermissions.allowedToCreateTenants

    if ($passed) {
        $testResultMarkdown = "Non-privileged users are restricted from creating tenants.`n`n"
    }
    else {
        $testResultMarkdown = "Non-privileged users are allowed to create tenants. The defaultUserPermissions.allowedToCreateTenants property is set to true.`n`n"
    }

    Add-ZtTestResultDetail -TestId '21787' -Title "Permissions to create new tenants is limited to the Tenant Creator role" `
        -UserImpact Low -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
