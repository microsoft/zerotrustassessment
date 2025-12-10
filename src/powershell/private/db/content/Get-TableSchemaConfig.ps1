function Get-TableSchemaConfig {
	<#
	.SYNOPSIS
		Returns the explicit schema handling information for tables that need special treatment.

	.DESCRIPTION
		Returns the explicit schema handling information for tables that need special treatment.
		Will return nothing if the table is a table without special needs.

	.PARAMETER TableName
		The name of the table to get schema config for

	.EXAMPLE
		PS C:\> Get-TableSchemaConfig -TableName ServicePrincipalSignIn

		Returns the explicit schema handling information for the ServicePrincipalSignIn table.
	#>
    [CmdletBinding()]
    param (
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
        'SignIn' = @{
            'use_union_by_name' = $true
            'sample_size' = 20  # Sample more files to avoid schema inference issues
            'reason' = 'Sign-in logs may have similar mixed data type issues'
        }
        'ConfigurationPolicy' = @{
            'use_union_by_name' = $true
            'sample_size' = 50
            'reason' = 'Contains complex nested objects (settings, assignments) that may vary'
        }
    }

    $configs[$TableName]
}
