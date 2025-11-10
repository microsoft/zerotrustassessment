function Get-ObjectProperty {
	<#
	.SYNOPSIS
		Get object property value.

	.DESCRIPTION
		Get object property (or sub-property) value.
		Traverses as many levels as needed, as specified by the `-Property` parameter.
		Works for both hashtables and psobjects or a mix of either.

	.PARAMETER InputObjects
		Object containing property values

	.PARAMETER Property
		Name of property. Specify an array of property names to tranverse nested objects.

	.EXAMPLE
		PS C:\>$object = New-Object psobject -Property @{ title = 'title value' }
		PS C:\>$object | Get-ObjectProperty -Property 'title'

		Get value of object property named title.

	.EXAMPLE
		PS C:\>$object = New-Object psobject -Property @{ lvl1 = (New-Object psobject -Property @{ nextLevel = 'lvl2 data' }) }
		PS C:\>Get-ObjectProperty $object -Property 'lvl1', 'nextLevel'

		Get value of nested object property named nextLevel.

	.INPUTS
		System.Collections.Hashtable
		System.Management.Automation.PSObject
	#>
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [object]
		$InputObjects,

        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]
		$Property
    )

    process {
        :main foreach ($InputObject in $InputObjects) {
			$value = $InputObject
			foreach ($propertyName in $Property) {
				$value = $value.$propertyName
				if ($null -eq $value) { continue main }
			}
			$value
        }
    }
}
