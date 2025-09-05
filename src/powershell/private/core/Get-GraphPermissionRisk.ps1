<#
.SYNOPSIS
    Get the risk of a permission in the graph database.
#>


function Get-GraphPermissionRisk {
    [CmdletBinding()]
    param(
        # The permission to get the risk for e.g. User.Read
        [Parameter(Mandatory)]
        [string]
        $Permission,

        # The type of permission e.g. Application, Delegated
        [Parameter(Mandatory)]
        [ValidateSet('Application', 'Delegated')]
        [string]
        $PermissionType
    )

    $permKey = $Permission + $PermissionType
    if (!$Script:GraphPermissions) {
        $Script:GraphPermissions = @{}
    }
    # Check if permission has been cached
    if (!$Script:GraphPermissions.ContainsKey($permKey)) {

        $permstable = GetPermissionsTable

        $permsHash = @{}

        foreach ($perm in $permstable) {
            $key = $perm.Type + $perm.Permission
            $permsHash[$key] = $perm
            if ($perm.permission -Match ".") {
                $key = $perm.Type + $perm.Permission.Split(".")[0]
                $permsHash[$key] = $perm
            }
        }
        $scope = $Permission
        $type = $PermissionType


        $scoperoot = $scope.Split(".")[0]

        $risk = "Unranked"
        # Search for matching root level permission if there was no exact match
        if ($permsHash.ContainsKey($type + $scope)) {
            # Exact match e.g. Application.Read.All
            $risk = $permsHash[$type + $scope].Privilege
        }
        elseif ($permsHash.ContainsKey($type + $scoperoot)) {
            #Matches top level e.g. Application.
            $risk = $permsHash[$type + $scoperoot].Privilege
        }
        elseif ($type -eq "Application") {
            # Application permissions without exact or root matches with write scope
            $risk = "Medium"
            if ($scope -like "*Write*") {
                $risk = "High"
            }
        }
        $Script:GraphPermissions[$permKey] = $risk
    }
    return $Script:GraphPermissions[$permKey]
}

function GetPermissionsTable
{
	[CmdletBinding()]
	param (

	)
    if (!$Script:GraphPermissionsCsv) {
        $csvFilePath = Join-Path -Path $Script:ModuleRoot -ChildPath 'assets/aadconsentgrantpermissiontable.csv'
        $Script:GraphPermissionsTable = Import-Csv $csvFilePath -Delimiter ','
    }
    return $Script:GraphPermissionsTable
}
