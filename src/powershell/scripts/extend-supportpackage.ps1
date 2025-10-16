# Ensure that any support packages also include the statistics of the last test run
Register-PSFSupportDataProvider -Name 'ZTA_TestStatistics' -ScriptBlock { Get-ZtTestStatistics }
