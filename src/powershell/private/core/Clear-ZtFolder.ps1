function Clear-ZtFolder {
    [CmdletBinding()]
    param (
        # The path to the folder to clear.
        [string]
        $Path
    )

    if ((Test-Path $Path)) {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop | Out-Null
    }
    New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
}
