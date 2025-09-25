<#
.SYNOPSIS
    Checks if the Azure Active Directory PowerShell Enterprise Application is blocked
#>

function Test-Assessment-21844{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21844,
    	Title = 'Block legacy Azure AD PowerShell module',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Block legacy Azure AD PowerShell module'
    Write-ZtProgress -Activity $activity -Status 'Querying Azure AD PowerShell service principal'

    # Azure AD PowerShell App ID
    $azureADPowerShellAppId = '1b730954-1685-4b74-9bfd-dac224a7b894'

    # Query for the Azure AD PowerShell service principal
    $servicePrincipal = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -ApiVersion 'v1.0' -Filter "appId eq '$azureADPowerShellAppId'" -Select "id,appId,displayName,servicePrincipalType,accountEnabled,appOwnerOrganizationId,appRoleAssignmentRequired"

    Write-ZtProgress -Activity $activity -Status 'Evaluating service principal configuration'

    if (-not $servicePrincipal -or $servicePrincipal.Count -eq 0) {
        # Service principal doesn't exist - this means the app has never been consented to
        $passed = $true
        $testResultMarkdown = 'Azure AD PowerShell Enterprise Application does not exist in the tenant, indicating it has never been consented to or used.'
        $detailsMarkdown = "| Property | Value |`n| :--- | :--- |`n| Service Principal Exists | No |`n| Status | Not consented to in tenant |"
    }
    else {
        $sp = $servicePrincipal[0]  # Get the first (and should be only) result

        if ($sp.accountEnabled -eq $false) {
            # Service principal exists but is disabled - PASS
            $passed = $true
            $testResultMarkdown = 'Azure AD PowerShell is blocked in the tenant by turning off user sign in to the Azure Active Directory PowerShell Enterprise Application.'
        }
        elseif ($sp.appRoleAssignmentRequired -eq $true) {
            # Service principal exists, enabled, but requires role assignment - INVESTIGATE
            $passed = $false
            $testResultMarkdown = "**Investigation Required**: App role assignment is required for Azure AD PowerShell. Review assignments and confirm that the app is inaccessible to users."
        }
        else {
            # Service principal exists and is enabled without role assignment requirement - FAIL
            $passed = $false
            $testResultMarkdown = 'Azure AD PowerShell has not been blocked by the organization.'
        }

        # Build details table
        $detailsMarkdown = @"
| Property | Value |
| :--- | :--- |
| Service Principal Object ID | $($sp.id) |
| Service Principal App ID | $($sp.appId) |
| Display Name | $(Get-SafeMarkdown($sp.displayName)) |
| Account Enabled | $($sp.accountEnabled) |
| App Role Assignment Required | $($sp.appRoleAssignmentRequired) |
"@
    }

    # Append details to the result markdown
    $testResultMarkdown += "`n`n## Details`n`n$detailsMarkdown"

    $params = @{
        TestId             = '21844'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
