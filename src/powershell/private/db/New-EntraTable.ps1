<#
.SYNOPSIS
    Creates a new table in the database.
#>

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
        'SignIn' = @{
            'use_union_by_name' = $true
            'sample_size' = 20  # Sample more files to avoid schema inference issues
            'reason' = 'Sign-in logs may have similar mixed data type issues'
        }
    }

    return $configs[$TableName]
}

function New-EntraTable {
    [CmdletBinding()]
    param (
        # The connection to the database.
        [Parameter(Mandatory = $true)]
        [DuckDB.NET.Data.DuckDBConnection]
        $Connection,

        # The name of the table to create.
        [Parameter(Mandatory = $true)]
        [string]
        $TableName,

        # The file path to import from
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath
    )

    # Get schema configuration if available for this table
    $schemaConfig = Get-TableSchemaConfig -TableName $TableName

    # Build read_json parameters
    $readJsonParams = @('maximum_object_size=40000000')

    if ($schemaConfig) {
        Write-PSFMessage "Using special schema configuration for table $TableName`: $($schemaConfig.reason)" -Level Debug -Tag DB

        if ($schemaConfig.use_union_by_name) {
            $readJsonParams += 'union_by_name=true'
        }

        if ($schemaConfig.sample_size) {
            $readJsonParams += "sample_size=$($schemaConfig.sample_size)"
        }
    } else {
        Write-PSFMessage "Using automatic schema inference for table $TableName" -Level Debug -Tag DB
        # Add union_by_name=true as default for better schema flexibility
        $readJsonParams += 'union_by_name=true'
    }

    $paramsString = $readJsonParams -join ', '
    $sqlTemp = "CREATE TABLE temp$TableName AS SELECT unnest(value) as d FROM read_json('$FilePath', $paramsString);"
    $sqlTable = "CREATE TABLE $TableName AS SELECT d.* FROM temp$TableName;"

    try {
        Write-PSFMessage "Creating temporary table temp$TableName with parameters: $paramsString" -Level Debug -Tag DB
        Invoke-DatabaseQuery -Database $Connection -Sql $sqlTemp -NonQuery

        Write-PSFMessage "Creating final table $TableName" -Level Debug -Tag DB
        Invoke-DatabaseQuery -Database $Connection -Sql $sqlTable -NonQuery
    }
    catch {
        Write-PSFMessage "Error creating table $TableName`: $($_.Exception.Message)" -Level Error -Tag DB -ErrorRecord $_

        # If we get a schema inference error, suggest solutions
        if ($_.Exception.Message -like "*Could not convert*" -or $_.Exception.Message -like "*JSON transform error*") {
            Write-PSFMessage "This appears to be a schema inference issue. Consider adding $TableName to Get-TableSchemaConfig with appropriate settings." -Level Warning -Tag DB
        }

        throw
    }
}
