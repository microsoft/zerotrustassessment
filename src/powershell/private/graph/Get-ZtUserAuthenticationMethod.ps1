﻿function Get-ZtUserAuthenticationMethod {
	<#
	.SYNOPSIS
		Get the authentication methods for the specified user

	.DESCRIPTION
		Get the authentication method from the /users/{id}/authentication/methods endpoint and
		appends the `typeDisplayName` and `isMfa` properties to each authentication method.

		The user authentication method returned by Graph is missing key information such as the
		display name and whether an auth method is a multi-factor authentication method or not.

		This cmdlet also returns an IsMfa status for the overall user object and is set to true
		if the user has at least one MFA method enabled.

		Note: The overall IsMfa status may not be accurate in tenants that identity federation
		or authentication methods like Certificate Based Authentication that don't have a state
		registered against the user object.

	.EXAMPLE
		Get-ZtUserAuthenticationMethod -UserId 'john@contoso.com'

		Get the authentication methods for the specified user
	#>
	[CmdletBinding()]
	param(
		# The GUID or user principal name of the user to get Authentication Methods for.
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
		$UserId
	)

	process {
		function Add-ZtiAuthMethodInfo {
			[CmdletBinding()]
			param (
				$UserAuthMethod
			)
			$authMethodInfo = Get-ZtUserAuthenticationMethodInfoByType -AuthenticationMethod $UserAuthMethod

			[PSFramework.Object.ObjectHost]::AddNoteProperty(
				$UserAuthMethod,
				@{
					typeDisplayName = $authMethodInfo.DisplayName
					isMfa = $authMethodInfo.IsMfa
				},
				$true
			)
		}

		Write-PSFMessage "Querying graph for user authentication methods for $UserId" -Level Debug
		$userAuthMethods = Invoke-ZtGraphRequest -RelativeUri "users/$UserId/authentication/methods"

		Write-PSFMessage "Appending auth method displayname and isMfa properties to each auth method." -Level Debug
		$IsMfa = $false
		foreach ($method in $userAuthMethods) {
			Add-ZtiAuthMethodInfo -UserAuthMethod $method
			if ($method.IsMfa) {
				$IsMfa = $true
			}
		}

		[PSCustomObject][Ordered]@{
			UserId                = $userId
			IsMfa                 = $IsMfa
			AuthenticationMethods = @($userAuthMethods)
		}
	}
}
