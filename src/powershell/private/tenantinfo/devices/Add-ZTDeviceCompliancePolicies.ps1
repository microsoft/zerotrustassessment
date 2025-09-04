
<#
.SYNOPSIS
    Add Device compliance policies.
#>

function Add-ZTDeviceCompliancePolicies {

    function Get-DefenderEndPointLabel($advancedThreatProtectionRequiredSecurityLevel) {
        switch ($advancedThreatProtectionRequiredSecurityLevel) {
            'high' { return 'High' }
            'medium' { return 'Medium' }
            'low' { return 'Low' }
            'secured' { return 'Clear' }
            'unavailable' { return '' }
            'notSet' { return '' }
            default { return '' }
        }
    }

    function Get-DeviceThreatLevelLabel($deviceThreatProtectionRequiredSecurityLevel) {
        switch ($deviceThreatProtectionRequiredSecurityLevel) {
            'high' { return 'High' }
            'medium' { return 'Medium' }
            'low' { return 'Low' }
            'secured' { return 'Secured' }
            'unavailable' { return '' }
            'notSet' { return '' }
            default { return '' }
        }
    }

    function Get-PasswordRequiredType($passwordType) {

        switch ($passwordType) {
            'deviceDefault' { return 'Device default' }
            'alphanumeric' { return 'Alphanumeric' }
            'numeric' { return 'Numeric' }
            'alphabetic' { return 'Alphabetic'}
            'alphanumericWithSymbols' { return 'Alphanumeric with symbols'}
            'lowSecurityBiometric' { return 'Biometric (low security)'}
            'customPassword' { return 'Custom password'}
            'required' { return 'Password required'}
            'Any' { return 'Any'}
            default { return $passwordType }
        }
    }

    function Get-AndroidCompliancePolicy($Policy) {
        return [PSCustomObject]@{
            Platform = 'Android device administrator'
            PolicyName = $Policy.displayName
            DefenderForEndPoint = Get-DefenderEndPointLabel $Policy.AdvancedThreatProtectionRequiredSecurityLevel
            MinOsVersion = $Policy.OsMinimumVersion
            MaxOsVersion = $Policy.OsMaximumVersion
            RequirePswd = $Policy.passwordRequired -eq 'true' ? 'Yes' : ''
            MinPswdLength = $Policy.PasswordMinimumLength
            PasswordType = Get-PasswordRequiredType $Policy.passwordType
            PswdExpiryDays = $Policy.PasswordExpirationDays
            CountOfPreviousPswdToBlock = $Policy.PasswordPreviousPasswordBlockCount
            #MaxInactivityMin = $Policy.maxInactivityTimeDeviceLockInMinutes
            RequireEncryption = $Policy.storageRequireEncryption -eq 'true' ? 'Yes' : ''
            RootedJailbrokenDevices = $Policy.securityBlockJailbrokenDevices -eq 'true' ? 'Blocked' : ''
            MaxDeviceThreatLevel = Get-DeviceThreatLevelLabel $Policy.deviceThreatProtectionLevel
            RequireFirewall = ''
            ActionForNoncomplianceDaysPushNotification = Get-ActionForNoncomplianceDays($Policy.scheduledActionsForRule, 'pushNotification')
            ActionForNoncomplianceDaysSendEmail = Get-ActionForNoncomplianceDays($Policy.scheduledActionsForRule, 'sendEmail')
            ActionForNoncomplianceDaysRemoteLock = Get-ActionForNoncomplianceDays($Policy.scheduledActionsForRule, 'remoteLock')
            ActionForNoncomplianceDaysBlock = Get-ActionForNoncomplianceDays($Policy.scheduledActionsForRule, 'block')
            ActionForNoncomplianceDaysRetire = Get-ActionForNoncomplianceDays($Policy.scheduledActionsForRule, 'retire')
            Scope = ''
            IncludedGroups = ($Policy.assignments | Where-Object { $_.target.groupId -and $_.target.includeAllDevices -eq $false } | ForEach-Object { Get-GroupName $_.target.groupId }) -join ", "
            ExcludedGroups = ($Policy.assignments | Where-Object { $_.target.groupId -and $_.target.excludeAllDevices -eq $true } | ForEach-Object { Get-GroupName $_.target.groupId }) -join ", "
        }
    }

    $activity = "Getting Device compliance policies"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $compliancePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies' -QueryParameters @{ '$expand' = 'assignments,scheduledActionsForRule($expand=scheduledActionConfigurations)' } -ApiVersion 'beta'

    $linuxCompliancePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies' -QueryParameters @{ '$expand' = 'assignments,scheduledActionsForRule($expand=scheduledActionConfigurations)' } -ApiVersion 'beta'

    # Create the table data structure
    $tableData = @()
    foreach ($policy in $compliancePolicies) {

        # switch $policy.'@odata.type'{
        #     '#microsoft.graph.androidCompliancePolicy' {
        #         $tableData += Get-AndroidCompliancePolicy -Policy $policy
        #     }

        #     '#microsoft.graph.androidDeviceOwnerCompliancePolicy' {
        #         $tableData += Get-AndroidDeviceOwnerCompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.androidWorkProfileCompliancePolicy' {
        #         $tableData += Get-AndroidWorkProfileCompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.aospDeviceOwnerCompliancePolicy' {
        #         $tableData += Get-AospDeviceOwnerCompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.iosCompliancePolicy' {
        #         $tableData += Get-IosCompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.macOSCompliancePolicy' {
        #         $tableData += Get-MacOSCompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.windows10CompliancePolicy' {
        #         $tableData += Get-Windows10CompliancePolicy -Policy $policy
        #     }
        #     '#microsoft.graph.windows81CompliancePolicy' {
        #         $tableData += Get-Windows81CompliancePolicy -Policy $policy
        #     }
        # }

        # foreach($policy in $linuxCompliancePolicies){
        #     $tableData += Get-LinuxCompliancePolicy -Policy $policy
        # }

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
