﻿function Get-ZtTotalObjectCount {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        # The type of object to count.
        [ValidateSet('Users', 'Groups', 'Devices', 'Applications',
        'ServicePrincipals', 'AccessReviews', 'AccessPackages', 'ConnectedOrganizations'
        )]
        [Parameter(Mandatory = $true)]
        [string] $ObjectType
    )

    # FutureUse: If object type name is different to entity name, map it here.
    switch ($ObjectType) {
        'AccessReviews' { $entityName = 'identityGovernance/accessReviews/definitions' }
        'AccessPackages' { $entityName = 'identityGovernance/entitlementManagement/accessPackages' }
        'ConnectedOrganizations' { $entityName = 'identityGovernance/entitlementManagement/connectedOrganizations' }
        default { $entityName = $ObjectType }
    }

    $result = Invoke-ZtGraphRequest -RelativeUri $entityName + '?$count=true' -Select 'id' -Top 1 -Headers @{"ConsistencyLevel" = "eventual" } -DisablePaging
    $result.'@odata.count'
}
