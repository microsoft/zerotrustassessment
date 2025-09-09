$global:__testData.Tests.Integrity = @{}
# List of forbidden commands
$global:__testData.Tests.Integrity.BannedCommands = @(
	# Costs performance without benefit
	'Write-Output'

	# Use CIM instead where possible
	'Get-WmiObject'
	'Invoke-WmiMethod'
	'Register-WmiEvent'
	'Remove-WmiObject'
	'Set-WmiInstance'

	# Use Get-WinEvent instead
	'Get-EventLog'

	# User Preference should not be used in automation
	'Clear-Host' # Console Screen belongs to the user
	'Set-Location' # Console path belongs to the user. Use $PSScriptRoot instead.

	# Dynamic Variables are undesirable. Use hashtable instead.
	'Get-Variable'
	'Set-Variable'
	'Clear-Variable'
	'Remove-Variable'
	'New-Variable'

	# Dynamic Code execution should not require this
	'Invoke-Expression' # Consider splatting instead. Yes, you can splat parameters for external applications!
)

<#
	Contains list of exceptions for banned cmdlets.
	Insert the file names of files that may contain them.

	Example:
	"Write-Host"  = @('Write-PSFHostColor.ps1','Write-PSFMessage.ps1')
#>
$global:__testData.Tests.Integrity.MayContainCommand = @{
	"Write-Host"  = @()
	"Write-Verbose" = @()
	"Write-Warning" = @()
	"Write-Error"  = @()
	"Write-Output" = @()
	"Write-Information" = @()
	"Write-Debug" = @()
}
