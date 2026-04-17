<#
.SYNOPSIS
    Gets emergency access accounts from the configuration.

.DESCRIPTION
    Returns emergency access accounts defined in the ZeroTrustAssessment configuration file.
    Uses Maester-style configuration format where customers explicitly define their
    emergency/breakglass accounts.

    Configuration format (in zt-config.json) - follows Maester format:
    {
        "GlobalSettings": {
            "EmergencyAccessAccounts": [
                { "Type": "User", "UserPrincipalName": "breakglass1@contoso.com" },
                { "Type": "User", "Id": "00000000-0000-0000-0000-000000000001" },
                { "Type": "Group", "Id": "00000000-0000-0000-0000-000000000002" }
            ]
        }
    }

    Note: Group-based emergency accounts are resolved at runtime via Microsoft Graph API.

.PARAMETER Database
    The SQLite database connection used to resolve user information.

.OUTPUTS
    Array of PSCustomObject with properties:
    - Id: User's object ID
    - UserPrincipalName: User's UPN
    - DisplayName: User's display name
    - Type: 'User' or 'GroupMember' (indicates user resolved from a configured group)

.EXAMPLE
    $emergencyAccounts = Get-ZtEmergencyAccessAccounts -Database $Database

.NOTES
    Created to fix Issue #266 - Test 21815 incorrectly flags emergency access accounts
    as failures for having permanent privileged role assignments.

    Updated to use config-based approach per PM feedback (FIDO2 requirement too strict).
#>

function Get-ZtEmergencyAccessAccounts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database
    )

    Write-PSFMessage 'Getting emergency access accounts from configuration' -Level Verbose

    # Get emergency accounts from PSFConfig (set by Invoke-ZtAssessment)
    $configuredAccounts = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.EmergencyAccessAccounts'

    if (-not $configuredAccounts -or $configuredAccounts.Count -eq 0) {
        Write-PSFMessage 'No emergency access accounts configured' -Level Verbose
        return @()
    }

    Write-PSFMessage "Found $($configuredAccounts.Count) configured emergency access accounts" -Level Verbose

    $emergencyAccessAccounts = @()

    foreach ($account in $configuredAccounts) {
        $type = $account.Type
        $id = $account.Id
        $upn = $account.UserPrincipalName

        if ($type -eq 'User') {
            # Resolve user by UPN or ID
            if ($upn) {
                $escapedUpn = $upn -replace "'", "''"
                $sql = "SELECT id, userPrincipalName, displayName FROM User WHERE userPrincipalName = '$escapedUpn' COLLATE NOCASE"
            }
            elseif ($id) {
                $escapedId = $id -replace "'", "''"
                $sql = "SELECT id, userPrincipalName, displayName FROM User WHERE id = '$escapedId'"
            }
            else {
                Write-PSFMessage "Skipping invalid user entry: no Id or UserPrincipalName provided" -Level Warning
                continue
            }

            $user = Invoke-DatabaseQuery -Database $Database -Sql $sql | Select-Object -First 1

            if ($user) {
                $emergencyAccessAccounts += [PSCustomObject]@{
                    Id                = $user.id
                    UserPrincipalName = $user.userPrincipalName
                    DisplayName       = $user.displayName
                    Type              = 'User'
                }
                Write-PSFMessage "Emergency access user found: $($user.userPrincipalName)" -Level Verbose
            }
            else {
                Write-PSFMessage "Emergency access user not found in tenant: UPN=$upn, Id=$id" -Level Warning
            }
        }
        elseif ($type -eq 'Group') {
            if (-not $id) {
                Write-PSFMessage "Skipping invalid group entry: no Id provided" -Level Warning
                continue
            }

            # Resolve group members via Microsoft Graph API (GroupMember table not available in DB)
            try {
                Write-PSFMessage "Resolving emergency access group members via Graph API: Id=$id" -Level Verbose
                $members = @(Get-MgGroupMember -GroupId $id -All -ErrorAction Stop | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.user' })

                if ($members.Count -gt 0) {
                    foreach ($member in $members) {
                        # Get additional user properties
                        $userDetails = Get-MgUser -UserId $member.Id -Property Id, UserPrincipalName, DisplayName -ErrorAction SilentlyContinue
                        if ($userDetails) {
                            $emergencyAccessAccounts += [PSCustomObject]@{
                                Id                = $userDetails.Id
                                UserPrincipalName = $userDetails.UserPrincipalName
                                DisplayName       = $userDetails.DisplayName
                                Type              = 'GroupMember'
                            }
                            Write-PSFMessage "Emergency access group member found: $($userDetails.UserPrincipalName)" -Level Verbose
                        }
                    }
                }
                else {
                    Write-PSFMessage "Emergency access group has no user members: Id=$id" -Level Warning
                }
            }
            catch {
                Write-PSFMessage "Failed to resolve emergency access group members: Id=$id. Error: $($_.Exception.Message)" -Level Warning
            }
        }
        else {
            Write-PSFMessage "Skipping unknown account type: $type" -Level Warning
        }
    }

    Write-PSFMessage "Total emergency access accounts resolved: $($emergencyAccessAccounts.Count)" -Level Verbose

    return $emergencyAccessAccounts
}
