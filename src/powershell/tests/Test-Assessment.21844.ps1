﻿<#
.SYNOPSIS
    Checks if the Azure Active Directory PowerShell Enterprise Application is blocked
#>

function Test-Assessment-21844{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Free'),
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

    $appName = 'Azure AD PowerShell'
    if (-not $servicePrincipal -or $servicePrincipal.Count -eq 0) {
        $passed = $false
        $summaryLines = @(
            'Summary',
            '',
            "- $appName (Enterprise App not found in tenant)",
            '- Sign in disabled: N/A',
            '',
            "$appName has not been blocked by the organization."
        )
    }
    else {
        $sp = $servicePrincipal[0]
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}' -f $sp.id, $sp.appId
        $servicePrincipalMarkdown = "[${appName}]($portalLink)"

        if ($sp.accountEnabled -eq $false) {
            $passed = $true
            $summaryLines = @(
                'Summary',
                '',
                "- $servicePrincipalMarkdown",
                '- Sign in disabled: Yes',
                '',
                "$appName is blocked in the tenant by turning off user sign in to the Azure Active Directory PowerShell Enterprise Application."
            )
        }
        elseif ($sp.appRoleAssignmentRequired -eq $true) {
            $passed = $false
            $investigateStatus = $true
            $summaryLines = @(
                'Summary',
                '',
                "- $servicePrincipalMarkdown",
                '- Sign in disabled: No',
                '- User assignment required: Yes',
                '',
                "App role assignment is required for $appName. Review assignments and confirm that the app is inaccessible to users."
            )
        }
        else {
            $passed = $false
            $summaryLines = @(
                'Summary',
                '',
                "- $servicePrincipalMarkdown",
                '- Sign in disabled: No',
                '',
                "$appName has not been blocked by the organization."
            )
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
