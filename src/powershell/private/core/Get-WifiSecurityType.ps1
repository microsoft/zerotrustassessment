<#
.SYNOPSIS
    Returns the WiFi security type category based on Intune wiFiSecurityType value.

.DESCRIPTION
    Categorizes WiFi security types from Intune WiFi policies into Basic or Enterprise types.
    Based on Microsoft Graph wiFiSecurityType enum values.

    Security Type Values:
    - open (0): Open (No Authentication)
    - wpaPersonal (1): WPA-Personal
    - wpaEnterprise (2): WPA-Enterprise
    - wep (3): WEP Encryption
    - wpa2Personal (4): WPA2-Personal
    - wpa2Enterprise (5): WPA2-Enterprise

.PARAMETER SecurityType
    The wiFiSecurityType value from an Intune WiFi policy configuration.

.OUTPUTS
    String - Returns 'Enterprise' for enterprise security types, 'Basic' for all others.

.EXAMPLE
    Get-WifiSecurityType -SecurityType 'wpa2Enterprise'
    Returns: Enterprise

.EXAMPLE
    Get-WifiSecurityType -SecurityType 'wpa2Personal'
    Returns: Basic

.NOTES
    Reference: https://learn.microsoft.com/en-us/graph/api/resources/intune-deviceconfig-wifisecuritytype
    Reference: https://learn.microsoft.com/en-us/intune/intune-service/configuration/wi-fi-settings-ios
#>
function Get-WifiSecurityType {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SecurityType
    )

    # Enterprise security types require EAP authentication and certificate infrastructure
    $enterpriseTypes = @(
        'wpaEnterprise',      # WPA-Enterprise (value: 2)
        'wpa2Enterprise'      # WPA2-Enterprise (value: 5)
    )

    # Basic security types include open, personal, and WEP
    # - open (0): No authentication
    # - wpaPersonal (1): WPA with pre-shared key
    # - wep (3): WEP encryption (legacy)
    # - wpa2Personal (4): WPA2 with pre-shared key

    if ($SecurityType -in $enterpriseTypes) {
        return 'Enterprise'
    }
    else {
        return 'Basic'
    }
}
