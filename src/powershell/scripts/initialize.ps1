# General Startup code

#region Configure In-Memory Log
$minSize = Get-PSFConfigValue -FullName 'ZeroTrustAssessment.Logging.InMemoryLog.MinSize' -Fallback 51200
$actualSize = Get-PSFConfigValue -FullName 'PSFramework.Logging.MaxMessageCount'
if ($actualSize -lt $minSize) {
	Set-PSFConfig -FullName 'PSFramework.Logging.MaxMessageCount' -Value $minSize
}
#endregion Configure In-Memory Log
