
<#
.SYNOPSIS
    Add Device compliance policies.
#>

function Add-ZTDeviceCompliancePolicies {

    $activity = "Getting Device compliance policies"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $compliancePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies' -QueryParameters @{ '$expand' = 'assignments,scheduledActionsForRule($expand=scheduledActionConfigurations)' } -ApiVersion 'beta'

    # Create the table data structure
    $tableData = @()
    foreach ($policy in $compliancePolicies) {

        $tableData += [PSCustomObject]@{
            Platform = ''
            PolicyName = $policy.displayName
            DefenderForEndPoint = ''
            MinOsVersion = ''
            MaxOsVersion = ''
            RequirePswd = ''
            MinPswdLength = ''
            PasswordType = ''
            PswdExpiryDays = ''
            CountOfPreviousPswdToBlock = ''
            MaxInactivityMin = ''
            RequireEncryption = ''
            RootedJailbrokenDevices = ''
            MaxDeviceThreatLevel = ''
            RequireFirewall = ''
            ActionForNoncomplianceDaysPushNotification = ''
            ActionForNoncomplianceDaysSendEmail = ''
            ActionForNoncomplianceDaysRemoteLock = ''
            ActionForNoncomplianceDaysBlock = ''
            ActionForNoncomplianceDaysRetire = ''
            Scope = ''
            IncludedGroups = ''
            ExcludedGroups = ''
        }
    }


    Add-ZtTenantInfo -Name "ConfigDeviceCompliancePolicies" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
