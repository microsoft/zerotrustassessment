<#
 .Synopsis
  Returns the markdown label for the state of a conditional access policy.

 .Description

 .Example
  Get-ZtCaPolicyState -State "enabled"
#>
function Get-ZtCaPolicyState {
  [CmdletBinding()]
  param($State)

  switch($State) {
    'enabled' {
      return '🟢 Enabled'
    }
    'disabled' {
      return '🔴 Disabled'
    }
    'enabledForReportingButNotEnforced' {
      return '🟡 Report-only'
    }
  }
}
