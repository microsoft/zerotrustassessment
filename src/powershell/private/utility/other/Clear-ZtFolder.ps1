function Clear-ZtFolder {
	<#
	.SYNOPSIS
		Ensures the directory specified exists, but is empty.

	.DESCRIPTION
		Ensures the directory specified exists, but is empty.
		If the directory already exists, it will be deleted, even if nothing was in it.

	.PARAMETER Path
		The path to the folder to clear.

	.EXAMPLE
		PS C:\> Clear-ZtFolder -Path C:\Temp

		Ensures the path "C:\Temp" exists, but is empty
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    if (Test-Path -Path $Path) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
    }
    $null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop
}
