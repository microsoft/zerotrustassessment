<#
 .Synopsis
  Returns all the members of the specific group ID.

 .Description

 .Example
  Get-ZtGroupMember
#>

Function Get-ZtGroupMember {
  [CmdletBinding()]
  param(
    [Parameter(Position=0,mandatory=$true)]
    [guid]$groupId,
    [switch]$Recursive
  )

  Write-PSFMessage -Message "Getting group members."

  $members = @()
  $members += Invoke-ZtGraphRequest -RelativeUri "groups/$groupId/members" -ApiVersion v1.0

  if(-not $recursive){
    return $members
  }

  $members | Where-Object {`
    $_.'@odata.type' -eq "#microsoft.graph.group"
  } | ForEach-Object {`
    $members += Get-ZtGroupMember -groupId $_.id -Recursive
  }

  return $members

}
