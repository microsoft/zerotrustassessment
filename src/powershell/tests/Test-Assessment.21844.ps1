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

    $investigateStatus = $false

    if (-not $servicePrincipal -or $servicePrincipal.Count -eq 0) {
        $passed = $false
        $summaryLines = @(
            '**Summary**',
            '',
            '- Azure AD PowerShell (Enterprise App not found in tenant)',
            '- Sign in disabled: N/A'
        )
    }
    else {
        $sp = $servicePrincipal[0]
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}' -f $sp.id, $sp.appId
        $servicePrincipalMarkdown = "[Azure AD PowerShell]($portalLink)"

        $summaryLines = @('**Summary**', '', "- $servicePrincipalMarkdown")
        if ($sp.accountEnabled -eq $false) {
            $passed = $true
            $summaryLines += '- Sign in disabled: Yes'
        }
        elseif ($sp.appRoleAssignmentRequired -eq $true) {
            $passed = $false
            $investigateStatus = $true
            $summaryLines += '- Sign in disabled: No'
            $summaryLines += '- User assignment required: Yes'
        }
        else {
            $passed = $false
            $summaryLines += '- Sign in disabled: No'
        }
    }
    $testResultMarkdown = $summaryLines -join "`n"

    $params = @{
        TestId             = '21844'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    # Add investigate status if needed
    if ($investigateStatus -eq $true) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
