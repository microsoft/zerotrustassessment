<#
.SYNOPSIS
    Gets the duration of sign ins for the overview report.
#>

function Get-ZtSignInDuration {
	[CmdletBinding()]
	param(
		$Database
	)

	if ($null -ne $script:__ZtSession.SignInLogDuration) {
		return $script:__ZtSession.SignInLogDuration
	}

	$sql = @"
select
    datediff('minute', min(createdDateTime::TIMESTAMP), max(createdDateTime::TIMESTAMP)) as 'minutes',
    datediff('hour', min(createdDateTime::TIMESTAMP), max(createdDateTime::TIMESTAMP)) as 'hours',
    datediff('day', min(createdDateTime::TIMESTAMP), max(createdDateTime::TIMESTAMP)) as 'days',
from SignIn
"@

	$results = Invoke-DatabaseQuery -Database $Database -Sql $sql

	# Handle empty SignIn table (e.g., when export times out)
	if ($null -eq $results -or $results.minutes -is [System.DBNull]) {
		$script:__ZtSession.SignInLogDuration = "0 duration"
		return $script:__ZtSession.SignInLogDuration
	}

	$duration = 0
	if ($results.days -gt 0) {
		$duration = $results.days
		$label = "day"
	}
	elseif ($results.hours -gt 0) {
		$duration = $results.hours
		$label = "hour"
	}
	elseif ($results.minutes -gt 0) {
		$duration = $results.minutes
		$label = "minute"
	}
	else {
		$duration = 0
		$label = "duration" # Unknown duration
	}
	if ($duration -gt 1) {
		$label += "s" # Pluralize
	}

	$script:__ZtSession.SignInLogDuration = "$duration $label"
	$script:__ZtSession.SignInLogDuration
}
