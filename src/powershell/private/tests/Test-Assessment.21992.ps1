<#
.SYNOPSIS

#>

function Test-Assessment-21992{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Application Certificates need to be rotated on a regular basis"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Calculate date 180 days ago
    $thresholdDate = (Get-Date).AddDays(-180)

    # Initialize the sp result variable
    $spresult = @()

    # Query enabled service principals
    $serviceprincipals = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals" -ApiVersion beta
    $enabledServicePrincipals = $serviceprincipals | Where-Object { $_.accountEnabled -eq $true }

    foreach($sp in $enabledServicePrincipals) {
        if ($sp.keyCredentials) {
            foreach ($keyCredential in $sp.keyCredentials) {
                $startDate = [datetime]::Parse($keyCredential.startDateTime)
                if ($startDate -lt $thresholdDate) {
                    $spresult += $sp
                    break
                }
            }
        }
    }

    # Initialize the app result variable
    $appresult = @()

     # Query all app registrations
     $appregistrations = Invoke-ZtGraphRequest -RelativeUri "applications" -ApiVersion beta

     foreach($app in $appregistrations) {
        if ($app.keyCredentials) {
            foreach ($keyCredential in $app.keyCredentials) {
                $startDate = [datetime]::Parse($keyCredential.startDateTime)
                if ($startDate -lt $thresholdDate) {
                    $appresult += $app
                    break
                }
            }
        }
    }

    $totalcount = $spresult.Count + $appresult.Count
    $passed = $totalcount -eq 0

    if ($passed) {
        $testResultMarkdown = "Applications in your tenant that have certificates have been issued within 180 days.`n`n"
    }
    else {
        $testResultMarkdown = "Found $($totalcount) applications in your tenant with certificates that have not been rotated within 180 days.`n`n%TestResult%"
    }


    if($totalcount -gt 0) {
        $mdInfo = "`n## Applications with certificates that have not been rotated within 180 days`n`n"
        $mdInfo += "| App ID | Display Name | Certificate Thumbprint | Certificate Start Date | Certificate Expiration Date | Multi-tenant | Owner Tenant ID |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        if($spresult.Count -gt 0) {
            foreach ($sp in $spresult) {
                if ($sp.signInAudience -eq "AzureADMultipleOrgs") {
                    $ismultitenant = "Yes"
                } else {
                    $ismultitenant = "No"
                }

                foreach ($keyCredential in $sp.keyCredentials) {
                    $mdInfo += "| $($sp.appId) | $($sp.displayName) | $($keyCredential.customKeyIdentifier) | $($keyCredential.startDateTime) | $($keyCredential.endDateTime) | $($ismultitenant) | $($sp.appOwnerOrganizationId) |`n"
                }
            }
        }

        if($appresult.Count -gt 0) {
            foreach ($app in $appresult) {
                if ($app.signInAudience -eq "AzureADMultipleOrgs") {
                    $ismultitenant = "Yes"
                } else {
                    $ismultitenant = "No"
                }

                foreach ($keyCredential in $app.keyCredentials) {
                    $mdInfo += "| $($app.appId) | $($app.displayName) | $($keyCredential.customKeyIdentifier) | $($keyCredential.startDateTime) | $($keyCredential.endDateTime) | $($ismultitenant) | $($app.publisherDomain) |`n"
                }
            }
        }

    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21992' -Title "Application Certificates need to be rotated on a regular basis" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
