<#
.SYNOPSIS
    Checks that MFA is enabled for all Consumer apps.
#>

function Test-UnprotectedEEIDApps {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking MFA for all Consumer Apps"
    Write-ZtProgress -Activity $activity

    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

    $mfaPolicies = $caps | Where-Object {`
            $_.grantControls.builtInControls -contains "mfa"}

    $protectedApps = $mfaPolicies.Conditions.Applications.IncludeApplications

    $userFLows = Get-MgIdentityAuthenticationEventFlow
    $consumerApps = $userFLows.conditions.Applications.IncludeApplications.AppId

    $unprotectedApps = Compare-Object -ReferenceObject $consumerApps -DifferenceObject $protectedApps -PassThru

    $passed = ($unprotectedApps | Measure-Object).Count -eq 0

    $totalUnprotectedApps = ($unprotectedApps | Measure-Object).Count

    if ($passed) {
        $testResultMarkdown = "Tenant is configured to require multi-factor authentication for all user flows protectecting consumer apps.`n`n%TestResult%"
    }
    elseif (!$passed) {
        $testResultMarkdown = "Tenant is not configured to require multi-factor authentication for all user flows protectecting consumer apps.`n`n"
        $testResultMarkdown += "Found $totalUnprotectedApps consumer apps that are not requiring multi-factor authentication.`n`n%TestResult%"
        $guidList = $unprotectedApps -join "','"
        $sql = @"
    SELECT * FROM SignIn WHERE appId IN ('$guidList')
"@

        $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
        $signInsPerUnprotectedApp = $results.appId | Group-Object | Sort-Object Count -Descending | Select-Object @{Name="AppId"; Expression={$_.Name}}, Count


        $appNames = @()  # Create an empty array to store results
        foreach ($appId in $unprotectedApps) {
            $app = Get-MgApplicationByAppId -AppId $appId
            if ($app) {
                $appNames += $app | Select-Object AppId, DisplayName
            }
        }

        $joinedTable = @()
        $allAppIds = ($appNames.AppId + $signInsPerUnprotectedApp.AppId) | Select-Object -Unique

        foreach ($appId in $allAppIds) {
            $app = $appNames | Where-Object { $_.AppId -eq $appId }
            $signIn = $signInsPerUnprotectedApp | Where-Object { $_.AppId -eq $appId }

            $joinedTable += [PSCustomObject]@{
                AppId       = $appId
                DisplayName = $app.DisplayName  # Use '?' to handle cases where there's no match
                SignIns     = $signIn.Count
            }
        }
        $sortedTable = $joinedTable | Sort-Object SignIns -Descending

        if ($totalUnprotectedApps.Count -gt 0) {
            $mdInfo = "`n## Consumer apps not protected with MFA`n`n"
            $mdInfo += " | Name | App Id| Sign In's (30d)|`n"
            $mdInfo += "| :--- | :--- | :--- |`n"
            $mdInfo += Build-table -Apps $sortedTable
        }
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo


    }

    Add-ZtTestResultDetail -TestId 'CIAM0001' -Title '[EEID] Consumer facing apps are protected with MFA'`
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag User, Credential `
        -Status $passed -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $unprotectedApps
}

function Build-table($Apps) {
    $mdInfo = ""
    foreach ($item in $Apps) {
        $mdInfo += "| $($item.DisplayName) | $($item.AppId) | $($item.SignIns)|  `n"
    }
    return $mdInfo
}
