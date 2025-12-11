# Ensure that any support packages also include the statistics of the last export and test run
Register-PSFSupportDataProvider -Name 'ZTA_ExportStatistics' -ScriptBlock { Get-ZtExportStatistics }
Register-PSFSupportDataProvider -Name 'ZTA_TestStatistics' -ScriptBlock { Get-ZtTestStatistics }
