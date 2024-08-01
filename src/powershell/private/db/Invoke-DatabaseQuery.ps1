function Invoke-DatabaseQuery {
    [CmdletBinding()]
    param (
        $Database,
        # The query to run
        [string]
        [Parameter(Mandatory = $true)]
        $Sql
    )

    $cmd = $Database.CreateCommand()
    $cmd.CommandText = $Sql
    $reader = $cmd.ExecuteReader()

    while ($reader.read()) {
        $rowObject = @{}
        for ($columnIndex = 0; $columnIndex -lt $reader.FieldCount; $columnIndex++ ) {
            $rowObject[$reader.GetName($columnIndex)] = $reader.GetValue($columnIndex)
        }
        Write-Verbose $rowObject
        $rowObject
    }
}
