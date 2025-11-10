function ConvertTo-QueryString {
	<#
	.SYNOPSIS
		Convert Hashtable to Query String.

	.DESCRIPTION
		Convert Hashtable to Query String.

	.PARAMETER InputObjects
		Value to convert

	.PARAMETER EncodeParameterNames
		URL encode parameter names

	.EXAMPLE
		PS C:\>ConvertTo-QueryString @{ name = 'path/file.json'; index = 10 }

		Convert hashtable to query string.

	.EXAMPLE
		PS C:\>[ordered]@{ title = 'convert&prosper'; id = [guid]'352182e6-9ab0-4115-807b-c36c88029fa4' } | ConvertTo-QueryString

		Convert ordered dictionary to query string.

	.INPUTS
		System.Collections.Hashtable

	.LINK
		https://github.com/jasoth/Utility.PS
	#>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]
		$InputObjects,

		[switch]
		$EncodeParameterNames
    )

    process {
        foreach ($InputObject in $InputObjects) {
            $queryBuilder = [System.Text.StringBuilder]::new()
            if ($InputObject -is [System.Collections.IDictionary]) {
				foreach ($pair in $InputObject.GetEnumerator()) {
					if ($queryBuilder.Length -gt 0) { [void]$queryBuilder.Append('&') }
                    $parameterName = $pair.Key
                    if ($EncodeParameterNames) { $parameterName = [System.Net.WebUtility]::UrlEncode($parameterName) }
                    [void]$queryBuilder.AppendFormat('{0}={1}', $parameterName, [System.Net.WebUtility]::UrlEncode($pair.Value))
                }
            }
            elseif ($InputObject -is [object] -and $InputObject -isnot [ValueType]) {
                foreach ($property in $InputObject.PSObject.Properties) {
                    if ($queryBuilder.Length -gt 0) { [void]$queryBuilder.Append('&') }
                    $parameterName = $property.Name
                    if ($EncodeParameterNames) { $parameterName = [System.Net.WebUtility]::UrlEncode($parameterName) }
                    [void]$queryBuilder.AppendFormat('{0}={1}', $parameterName, [System.Net.WebUtility]::UrlEncode($property.Value))
                }
            }
            else {
                ## Non-Terminating Error
                $exception = New-Object ArgumentException -ArgumentList ('Cannot convert input of type {0} to query string.' -f $InputObject.GetType())
                Write-Error -Exception $exception -Category ([System.Management.Automation.ErrorCategory]::ParserError) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'ConvertQueryStringFailureTypeNotSupported' -TargetObject $InputObject
                continue
            }

            $queryBuilder.ToString()
        }
    }
}
