function Get-PrivateFunction
{
    <#
      .SYNOPSIS
      This is a sample Private function only visible within the module.

      .DESCRIPTION
      This sample function is not exported to the module and only return the data passed as parameter.

      .EXAMPLE
      $null = Get-PrivateFunction -PrivateData 'NOTHING TO SEE HERE'

      .PARAMETER PrivateData
      The PrivateData parameter is what will be returned without transformation.

      #>
    [cmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter()]
        [String]
        $PrivateData
    )

    process
    {
        Write-Output $PrivateData
    }

}
