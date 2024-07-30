<#
 .Synopsis
  Returns all the conditional access policies in the tenant.

 .Description

 .Example
  Get-ZtConditionalAccessPolicy
#>

Function Get-ZtConditionalAccessPolicy {
  [CmdletBinding()]
  param()

  Write-Verbose -Message "Getting conditional access policies."

  return Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

}
