# Used in the Test-Functions to declare their metadata
class ZtTest : System.Attribute
{
	[string]$Category
	[ValidateSet('Low','Medium','High')][string]$ImplementationCost
	[string]$Pillar
	[ValidateSet('Low','Medium','High')][string]$RiskLevel
	[string]$SfiPillar
	[ValidateSet('Workforce','External')][string[]]$TenantType
	[int]$TestId
	[string]$Title
	[ValidateSet('Low','Medium','High')][string]$UserImpact
}
<#
Example Usage:

function Get-Test {
	[ZtTest(
		Category = 'Access control',
		Cost = 'Low',
		Pillar = 'Identity',
		Risk = 'High',
		SfiPillar = "Protect identities and secrets",
		TenantType = ('Workforce', 'External'),
		TestId = 21786,
		Title = "User sign-in activity uses token protection",
		UserImpact = 'Low'
	)]
	[CmdletBinding()]
	param ()
}
#>
