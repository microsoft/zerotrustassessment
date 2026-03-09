function Get-ZtRoleScopeTag {
    [CmdletBinding()]
    param (
        $RoleScopeTagIds
    )
    $scopeTags = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/roleScopeTags' -ApiVersion 'beta'
    $roleScopeTagNames = @()
    foreach ($scopeTagId in $RoleScopeTagIds) {
        $scopeTag = $scopeTags | Where-Object { $_.id -eq $scopeTagId }
        if ($scopeTag) {
            $roleScopeTagNames += $scopeTag.displayName
        }
        else {
            $roleScopeTagNames += $_
        }
    }
    return $roleScopeTagNames -join ", "
}
