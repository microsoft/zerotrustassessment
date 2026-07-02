# Debugging Settings
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Logging.Database.IncludeQueryResults' -Value $false -Initialize -Validation bool -Description 'Include the individual results from queries against the internal database in the logs. Significantly increases logsize and includes sensitive data.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Logging.InMemoryLog.MinSize' -Value 51200 -Initialize -Validation integerpositive -Description 'The smallest size the in-memory log may be. If it is configured to be less than that, the size will be raised during module import. A large log may impact memory consumption, but will enable better troubleshooting.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Debug.KeepWorkflows' -Value $false -Initialize -Validation bool -Description 'Do not remove the parallelization engines after completion. This will leave artifacts and needs manual termination before starting again, but allows better debugging of background tasks.'

# UX Settings
Set-PSFConfig -Module ZeroTrustAssessment -Name 'TabExpansion.TestLimit' -Value 10 -Initialize -Validation integerpositive -Description 'Maximum number of tests offered via tab exansion'

# Export Settings
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Export.DependencyWaitLimit' -Value '1d' -Initialize -Validation timespan -Description 'During the export stage of the assessment, how long will a component wait for another export it depends on? If the dependencies are not exported by the timeout, export will fail.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Export.SignInLog.MaxSizeBytes' -Value 1073741824 -Initialize -Validation integerpositive -Description 'Maximum size in bytes for sign-in log exports. Defaults to 1GB (1073741824 bytes). When this limit is reached, the export will stop and continue with the next export.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'ThrottleLimit.Export' -Value 5 -Initialize -Validation integerpositive -Description 'Maximum number of data collectors processed in parallel'

# Test Settings
Set-PSFConfig -Module ZeroTrustAssessment -Name 'ThrottleLimit.Tests' -Value 5 -Initialize -Validation integerpositive -Description 'Maximum number of tests processed in parallel'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Tests.Timeout' -Value '1h' -Initialize -Validation timespan -Description 'Maximum time a single test is allowed to run before it is stopped. Defaults to 1 hour. Set to 0 to disable the timeout. Tests that exceed this limit are recorded as timed out and execution continues with the next test.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Tests.TimeoutType' -Value 'Idle' -Validation rstimeout -Initialize -Description 'How the timeout for test execution is measured: Idle = "Since last activity", Start = "Since the Test was started"'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Tests.RetryCount' -Value 0 -Validation integerpositive -Initialize -Description 'How many times a failed test should be reattempted.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Tests.RetryTimeout' -Value $false -Validation bool -Initialize -Description 'Whether a timedout test should be reattempted.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Tests.Statistics.MaxMessageCount' -Value 1024 -Validation integerpositive -Initialize -Description 'How many log messages will be stored in the test statistics. If the number is higher than specified, the message objects will be simplified to help preserve memory.'

# Caching Settings
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Azure.DisableCache' -Value $false -Initialize -Validation bool -Description 'Global toggle to disable azure caching. Caching improves performance of some requests, but potentially consumes a lot of memory, which might lead to swapping and cratering code performance.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Azure.CacheMaxItems' -Value 50000 -Initialize -Validation integerpositive -Handler { (Set-PSFDynamicContentObject -Name "ZtAssessment.AzureCache" -Cache -PassThru).Value.SetMaxItems($_) } -Description 'Maximum number of items in the azure cache.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Azure.CacheLifetime' -Value '30m' -Initialize -Validation timespan -Handler { (Set-PSFDynamicContentObject -Name "ZtAssessment.AzureCache" -Cache -PassThru).Value.SetLifetime($_) } -Description 'Maximum age of values in the azure cache'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Graph.DisableCache' -Value $false -Initialize -Validation bool -Description 'Global toggle to disable graph caching. Caching improves performance of some requests, but potentially consumes a lot of memory, which might lead to swapping and cratering code performance.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Graph.CacheMaxItems' -Value 50000 -Initialize -Validation integerpositive -Handler { (Set-PSFDynamicContentObject -Name "ZtAssessment.GraphCache" -Cache -PassThru).Value.SetMaxItems($_) } -Description 'Maximum number of items in the graph cache.'
Set-PSFConfig -Module ZeroTrustAssessment -Name 'Graph.CacheLifetime' -Value '30m' -Initialize -Validation timespan -Handler { (Set-PSFDynamicContentObject -Name "ZtAssessment.GraphCache" -Cache -PassThru).Value.SetLifetime($_) } -Description 'Maximum age of values in the graph cache'
