<#
.SYNOPSIS
    Add tenant info data so that it can be displayed in the report.
#>

function Add-ZtTenantInfo {
    [CmdletBinding()]
    param(
        # The unique name for this tenant info.
        [Parameter(Mandatory = $true)]
        [string] $Name,

        # The value for this tenant info.
        $Value
    )

    if ($script:__ZtSession.ContainsKey($Name)) {
        # throw exception, should be caught during dev if there is clash in names
        throw "Tenant info with name $Name already exists"
    }
    else {
        $script:__ZtSession.TenantInfo.Value[$Name] = $Value
    }
}
