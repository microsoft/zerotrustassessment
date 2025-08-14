<#
.SYNOPSIS
    Returns the explicit schema handling information for tables that need special treatment.
#>

function Get-TableSchemaConfig {
    [CmdletBinding()]
    param (
        # The name of the table to get schema config for
        [Parameter(Mandatory = $true)]
        [string]
        $TableName
    )

    $configs = @{
        'ServicePrincipalSignIn' = @{
            'use_union_by_name' = $true
            'sample_size' = 50  # Sample more files to avoid schema inference issues
            'reason' = 'Contains mixed data types in lastSignInRequestId fields (UUIDs and "Aggregated")'
        }
    }

    return $configs[$TableName]
}
