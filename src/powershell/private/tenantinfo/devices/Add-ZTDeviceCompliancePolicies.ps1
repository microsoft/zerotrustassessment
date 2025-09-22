﻿
<#
.SYNOPSIS
    Add Device compliance policies.
#>

function Add-ZTDeviceCompliancePolicies {

    function Get-DefenderEndPointLabel($advancedThreatProtectionRequiredSecurityLevel) {
        switch ($advancedThreatProtectionRequiredSecurityLevel) {
            'high' {
                return 'High'
            }
            'medium' {
                return 'Medium'
            }
            'low' {
                return 'Low'
            }
            'secured' {
                return 'Clear'
            }
            'unavailable' {
                return ''
            }
            'notSet' {
                return ''
            }
            default {
                return ''
            }
        }
    }

    function Get-DeviceThreatLevelLabel($deviceThreatProtectionRequiredSecurityLevel) {
        switch ($deviceThreatProtectionRequiredSecurityLevel) {
            'high' {
                return 'High'
            }
            'medium' {
                return 'Medium'
            }
            'low' {
                return 'Low'
            }
            'secured' {
                return 'Secured'
            }
            'unavailable' {
                return ''
            }
            'notSet' {
                return ''
            }
            default {
                return ''
            }
        }
    }

    function Get-PasswordRequiredType($passwordType) {

        switch ($passwordType) {
            'deviceDefault' {
                return 'Device default'
            }
            'alphanumeric' {
                return 'Alphanumeric'
            }
            'numeric' {
                return 'Numeric'
            }
            'alphabetic' {
                return 'Alphabetic'
            }
            'alphanumericWithSymbols' {
                return 'Alphanumeric with symbols'
            }
            'lowSecurityBiometric' {
                return 'Biometric (low security)'
            }
            'customPassword' {
                return 'Custom password'
            }
            'required' {
                return 'Password required'
            }
            'Any' {
                return 'Any'
            }
            default {
                return $passwordType
            }
        }
    }

    function Get-ActionForNoncomplianceDays ($scheduledActionsForRule, $actionType) {
        $action = $scheduledActionsForRule | Where-Object { $_.actionType -eq $actionType }
        if ($action) {
            return $action.daysAfterComplianceGracePeriodEnd
        } else {
            return ''
        }
    }
    function Get-CompliancePolicyView($Policy, $Platform) {
        return [PSCustomObject]@{
            Platform                                   = $Platform
            PolicyName                                 = $Policy.displayName
            DefenderForEndPoint                        = Get-DefenderEndPointLabel $Policy.AdvancedThreatProtectionRequiredSecurityLevel
            MinOsVersion                               = $Policy.OsMinimumVersion
            MaxOsVersion                               = $Policy.OsMaximumVersion
            RequirePswd                                = $Policy.passwordRequired -eq 'true' ? 'Yes' : ''
            MinPswdLength                              = $Policy.PasswordMinimumLength
            PasswordType                               = Get-PasswordRequiredType $Policy.passwordType
            PswdExpiryDays                             = $Policy.PasswordExpirationDays
            CountOfPreviousPswdToBlock                 = $Policy.PasswordPreviousPasswordBlockCount
            RequireEncryption                          = $Policy.storageRequireEncryption -eq 'true' ? 'Yes' : ''
            RootedJailbrokenDevices                    = $Policy.securityBlockJailbrokenDevices -eq 'true' ? 'Blocked' : ''
            MaxDeviceThreatLevel                       = Get-DeviceThreatLevelLabel $Policy.DeviceThreatProtectionRequiredSecurityLevel
            RequireFirewall                            = ''
            MaxInactivityMin                           = $Policy.PasswordMinutesOfInactivityBeforeLock
            ActionForNoncomplianceDaysPushNotification = ''
            ActionForNoncomplianceDaysSendEmail        = ''
            ActionForNoncomplianceDaysRemoteLock       = ''
            ActionForNoncomplianceDaysBlock            = ''
            ActionForNoncomplianceDaysRetire           = ''
            Scope                                      = ''
            IncludedGroups                             = ($Policy.assignments | Where-Object { $_.target.groupId -and $_.target.includeAllDevices -eq $false } | ForEach-Object { Get-GroupName $_.target.groupId }) -join ", "
            ExcludedGroups                             = ($Policy.assignments | Where-Object { $_.target.groupId -and $_.target.excludeAllDevices -eq $true } | ForEach-Object { Get-GroupName $_.target.groupId }) -join ", "
        }
    }

    $activity = "Getting Device compliance policies"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $compliancePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies' -QueryParameters @{ '$expand' = 'assignments,scheduledActionsForRule($expand=scheduledActionConfigurations)' } -ApiVersion 'beta'

    #$linuxCompliancePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies' -QueryParameters @{ '$expand' = 'assignments,scheduledActionsForRule($expand=scheduledActionConfigurations)' } -ApiVersion 'beta'

    # Create the table data structure
    $tableData = @()
    foreach ($policy in $compliancePolicies) {

        switch ($policy.'@odata.type') {
            '#microsoft.graph.androidCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Android device administrator'
                $policyView.RequireFirewall = 'Not Applicable'
            }
            '#microsoft.graph.androidDeviceOwnerCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Android Enterprise (Corp)'
                $policyView.RequireFirewall = 'Not Applicable'
            }
            '#microsoft.graph.androidWorkProfileCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Android Enterprise (Personal)'
                $policyView.RequireFirewall = 'Not Applicable'

            }
            '#microsoft.graph.aospDeviceOwnerCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Android (AOSP)'
                $policyView.DefenderForEndPoint = 'Not Applicable'
                $policyView.PswdExpiryDays = 'Not Applicable'
                $policyView.CountOfPreviousPswdToBlock = 'Not Applicable'
                $policyView.MaxDeviceThreatLevel = 'Not Applicable'
                $policyView.RequireFirewall = 'Not Applicable'
            }
            '#microsoft.graph.iosCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'iOS/iPadOS'
                $policyView.RequireFirewall = 'Not Applicable'
                $policyView.RequirePswd = $policy.PasscodeRequired
                $policyView.MinPswdLength = $policy.PasscodeMinimumLength
                $policyView.PswdExpiryDays = $policy.PasscodeExpirationDays
                $policyView.MaxInactivityMin = $policy.PasscodeMinutesOfInactivityBeforeLock
                $policyView.CountOfPreviousPswdToBlock = $policy.PasscodePreviousPasscodeBlockCount
                $policyView.PasswordType = Get-PasswordRequiredType $Policy.PasscodeRequiredType
                $policyView.RequireEncryption = 'Not Applicable'
            }
            '#microsoft.graph.macOSCompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'macOS'
                $policyView.RootedJailbrokenDevices = 'Not Applicable'
                $policyView.RequireFirewall = $policy.FirewallEnabled -eq 'true' ? 'Yes' : ''
            }
            '#microsoft.graph.windows10CompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Windows 10 and later'
                $policyView.DefenderForEndPoint = Get-DefenderEndPointLabel $Policy.DeviceThreatProtectionRequiredSecurityLevel

                $policyView.RequireFirewall = $policy.ActiveFirewallRequired -eq 'true' ? 'Yes' : ''
                $policyView.MaxDeviceThreatLevel = 'Not Applicable'
                $policyView.RootedJailbrokenDevices = 'Not Applicable'
                $policyView.RequireFirewall = 'Not Applicable'
            }
            '#microsoft.graph.windows81CompliancePolicy' {
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform 'Windows 8.1 and later'
                $policyView.DefenderForEndPoint = 'Not Applicable'
                $policyView.MaxDeviceThreatLevel = 'Not Applicable'
                $policyView.RootedJailbrokenDevices = 'Not Applicable'
                $policyView.RequireFirewall = 'Not Applicable'
            }
            default {
                $typeName = $policy.'@odata.type' -replace '#microsoft.graph.', ''
                $policyView = Get-CompliancePolicyView -Policy $policy -Platform $typeName
            }

            # foreach($policy in $linuxCompliancePolicies){
            #     $tableData += Get-LinuxCompliancePolicy -Policy $policy
            # }


        }
        $tableData += $policyView
    }


    Add-ZtTenantInfo -Name "ConfigDeviceCompliancePolicies" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
