function Test-DnsName {
	<#
	.SYNOPSIS
		Tests, whether the specified DNS name resolves.

	.DESCRIPTION
		Tests, whether the specified DNS name resolves.

	.PARAMETER Name
		The dns name to resolve.

	.EXAMPLE
		PS C:\> Test-DnsName -Name microsoft.com

		Returns, whether the name "microsoft.com" can be resolved using the DNS system.
	#>
	[OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
		$Name
    )

	try {
		# Resolve-DnsName is windows only, .NET methods work xplat
		$resolution = [System.Net.Dns]::GetHostEntry($Name)
		$resolution -as [bool]
	}
	catch {
		Write-PSFMessage -Level Verbose -Message "Error resolving domain {0}" -StringValues $Name -ErrorRecord $_ -Target $Name
		$false
	}
}
