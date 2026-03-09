
function Get-ExportJsonFilePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        # The index of Graph request page. If not specified, the first page is assumed (0).
        [Parameter(Mandatory = $false)]
        [string]$PageIndex
    )
    if ($Path -match "\.json$") {
        return $Path # If the path ends in .json, we're done
    }
    else {
        # Paged results
        $index = 0 # First page
        if ($pageIndex) {
            $index = $pageIndex
        }

        return Join-Path $Path "Page.$index.json"
    }
}
