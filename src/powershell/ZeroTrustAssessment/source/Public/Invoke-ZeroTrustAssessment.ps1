function Invoke-ZeroTrustAssessment
{
    <#
      .SYNOPSIS
      Runs the Zero Trust Assessment against the signed in tenant and generates a report of the findings.

      .DESCRIPTION
      This function is only a sample Advanced function that returns the Data given via parameter Data.

      .EXAMPLE
      Invoke-ZeroTrustAssessment


      #>
    [cmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType([string])]
    param
    (
        # Optional. The folder to output the report to. If not specified, the report will be output to the current directory.
        [Parameter(
            Mandatory = $false
            , ValueFromPipeline = $true
            , ValueFromPipelineByPropertyName = $true
        )]
        [String]
        $OutputFolder
    )

    process
    {
        if ($pscmdlet.ShouldProcess($Data))
        {
            Write-Verbose ('Returning the data: {0}' -f $Data)
            $Data
        }
        else
        {
            Write-Verbose 'oh dear'
        }
    }
}
