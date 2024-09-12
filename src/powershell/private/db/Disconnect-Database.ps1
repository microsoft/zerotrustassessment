<#
.SYNOPSIS
    Closes the connection to the database and flushes the file.
#>
function Disconnect-Database {
    [CmdletBinding()]
    param (
        # The database connection to close.
        $Database
    )
    $Database.Close()
    $Database.Dispose()
}
