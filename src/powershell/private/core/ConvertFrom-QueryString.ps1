function ConvertFrom-QueryString {
	<#
	.SYNOPSIS
		Convert Query String to object.

	.DESCRIPTION
		Converts Query String to object.

	.PARAMETER InputStrings
		Value to convert

	.PARAMETER DecodeParameterNames
		URL decode parameter names

	.PARAMETER AsHashtable
		Converts to hash table object

	.EXAMPLE
		PS C:\>ConvertFrom-QueryString '?name=path/file.json&index=10'

		Convert query string to object.

	.EXAMPLE
		PS C:\>'name=path/file.json&index=10' | ConvertFrom-QueryString -AsHashtable

		Convert query string to hashtable.

	.INPUTS
		System.String

	.LINK
		https://github.com/jasoth/Utility.PS
	#>
	[CmdletBinding(DefaultParameterSetName = 'Default')]
	[OutputType([psobject], ParameterSetName = 'Default')]
	[OutputType([hashtable], ParameterSetName = 'AsHashtable')]
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string[]]
		$InputStrings,

		[switch]
		$DecodeParameterNames,

		[Parameter(ParameterSetName = 'AsHashtable')]
		[switch]
		$AsHashtable
	)

	process {
		foreach ($inputString in $InputStrings) {
			$outputObject = @{ }
			if ($inputString[0] -eq '?') {
				$inputString = $inputString.Substring(1)
			}
			$queryParameters = $inputString.Split('&')

			foreach ($queryParameter in $queryParameters) {
				# Split only on the first '=' to handle nested OData queries that contain '=' in the value
				$key, $value = $queryParameter.Split('=', 2)
				if ($DecodeParameterNames) {
					$key = [System.Net.WebUtility]::UrlDecode($key)
				}
				$outputObject[$key] = [System.Net.WebUtility]::UrlDecode($value)
			}

			if ($AsHashtable) {
				$outputObject
			}
			else {
				[PSCustomObject]$outputObject
			}
		}
	}
}
