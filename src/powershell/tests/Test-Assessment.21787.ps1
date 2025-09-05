<#
.SYNOPSIS

#>

function Test-Assessment-21787 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking permissions to create new tenants is limited to the Tenant Creator role"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0
    $passed = -not $result.defaultUserRolePermissions.allowedToCreateTenants

    if ($passed) {
        $testResultMarkdown = "Non-privileged users are restricted from creating tenants.`n`n"
    }
    else {
        $testResultMarkdown = "Non-privileged users are allowed to create tenants.`n`n"
    }

    $params = @{
        TestId              = '21787'
        Title               = 'Permissions to create new tenants is limited to the Tenant Creator role'
        UserImpact          = 'Medium'
        Risk                = 'High'
        ImplementationCost  = 'Medium'
        AppliesTo           = 'Identity'
        Tag                 = 'Identity'
        Status              = $passed
        Result              = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
