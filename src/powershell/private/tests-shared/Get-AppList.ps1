function Get-AppList {
    [CmdletBinding()]
    param (
        $Apps,
        $Icon
    )
    $mdInfo = ""
    foreach ($item in $apps) {
        $tenant = $item.publisherName
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($item.id)/appId/$($item.appId)"
        $risk = $item.Risk
        $delPerm = $item.DelegatePermissions -join ", "
        $appPerm = $item.AppPermissions -join ", "
        $mdInfo += "| $($Icon) | [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $risk | $delPerm | $appPerm | $(Get-SafeMarkdown($tenant)) | $(Get-FormattedDate($item.lastSignInDateTime)) | `n"
    }
    return $mdInfo
}