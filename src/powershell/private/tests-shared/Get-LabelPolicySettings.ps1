function Get-LabelPolicySettings {
    <#
    .SYNOPSIS
        Parses the PolicySettingsBlob XML from a sensitivity label policy.

    .DESCRIPTION
        Extracts label policy settings from the PolicySettingsBlob XML structure.
        This function provides a common parser for sensitivity label policy settings
        used by multiple assessment tests (35016, 35017, etc.).

    .PARAMETER PolicySettingsBlob
        The PolicySettingsBlob XML string from a label policy.

    .PARAMETER PolicyName
        The name of the policy (used for logging purposes).

    .OUTPUTS
        PSCustomObject with parsed settings including:
        - DefaultLabelId: Default label for documents/emails
        - OutlookDefaultLabel: Default label for Outlook
        - PowerBIDefaultLabelId: Default label for Power BI
        - SiteAndGroupDefaultLabelId: Default label for SharePoint/Groups
        - Mandatory: Email mandatory labeling
        - TeamworkMandatory: Files/collaboration mandatory labeling
        - SiteAndGroupMandatory: Sites/Groups mandatory labeling
        - PowerBIMandatory: Power BI mandatory labeling
        - DisableMandatoryInOutlook: Email override setting
        - ParseError: Any error that occurred during parsing

    .EXAMPLE
        $settings = Get-LabelPolicySettings -PolicySettingsBlob $policy.PolicySettingsBlob -PolicyName $policy.Name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$PolicySettingsBlob,

        [Parameter(Mandatory = $false)]
        [string]$PolicyName = 'Unknown'
    )

    # Initialize result object with all default values
    $result = [PSCustomObject]@{
        # Default label settings
        DefaultLabelId           = $null
        OutlookDefaultLabel      = $null
        PowerBIDefaultLabelId    = $null
        SiteAndGroupDefaultLabelId = $null
        # Mandatory labeling settings
        Mandatory                = $false
        TeamworkMandatory        = $false
        SiteAndGroupMandatory    = $false
        PowerBIMandatory         = $false
        DisableMandatoryInOutlook = $false
        # Parsing metadata
        ParseError               = $null
    }

    if ([string]::IsNullOrWhiteSpace($PolicySettingsBlob)) {
        return $result
    }

    try {
        $xmlSettings = [xml]$PolicySettingsBlob

        # Validate XML structure before accessing properties
        if ($xmlSettings.settings -and $xmlSettings.settings.setting) {
            foreach ($setting in $xmlSettings.settings.setting) {
                # Add null safety for key and value attributes
                if (-not $setting.key -or -not $setting.value) {
                    Write-PSFMessage "Skipping setting with null key or value in policy '$PolicyName'" -Level Verbose
                    continue
                }

                $key = $setting.key.ToLower()
                $value = $setting.value.Trim()
                $valueLower = $value.ToLower()

                switch ($key) {
                    # Default label settings (values are GUIDs)
                    'defaultlabelid' {
                        $result.DefaultLabelId = $value
                    }
                    'outlookdefaultlabel' {
                        $result.OutlookDefaultLabel = $value
                    }
                    'powerbidefaultlabelid' {
                        $result.PowerBIDefaultLabelId = $value
                    }
                    'siteandgroupdefaultlabelid' {
                        $result.SiteAndGroupDefaultLabelId = $value
                    }
                    # Mandatory labeling settings (values are boolean strings)
                    'mandatory' {
                        $result.Mandatory = ($valueLower -eq 'true')
                    }
                    'teamworkmandatory' {
                        $result.TeamworkMandatory = ($valueLower -eq 'true')
                    }
                    'siteandgroupmandatory' {
                        $result.SiteAndGroupMandatory = ($valueLower -eq 'true')
                    }
                    'powerbimandatory' {
                        $result.PowerBIMandatory = ($valueLower -eq 'true')
                    }
                    'disablemandatoryinoutlook' {
                        $result.DisableMandatoryInOutlook = ($valueLower -eq 'true')
                    }
                    default {
                        Write-PSFMessage "Unknown setting key '$key' in policy '$PolicyName'" -Level Verbose
                    }
                }
            }
        }
        else {
            Write-PSFMessage "Policy '$PolicyName' has PolicySettingsBlob but no settings elements found" -Level Verbose
        }
    }
    catch {
        $result.ParseError = $_.Exception.Message
        Write-PSFMessage "Error parsing PolicySettingsBlob XML for policy '$PolicyName': $_" -Level Warning
    }

    return $result
}
