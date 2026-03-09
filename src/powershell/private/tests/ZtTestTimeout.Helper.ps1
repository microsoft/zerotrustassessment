function Initialize-ZtTimeoutHelper {
	if ('ZeroTrustAssessment.TimeoutHelperV2' -as [type]) {
		return
	}

	try {
		Add-Type -TypeDefinition @'
using System;
using System.Management.Automation;
using System.Threading;

namespace ZeroTrustAssessment {
	public sealed class TimeoutControllerV2 : IDisposable {
        private readonly Timer _timer;
        private int _fired;

		public TimeoutControllerV2(PowerShell ps, int timeoutMilliseconds) {
            _timer = new Timer(
                _ => {
                    Interlocked.Exchange(ref _fired, 1);
                    try { ps.Stop(); } catch { /* best effort */ }
                },
                null,
                timeoutMilliseconds,
                Timeout.Infinite
            );
        }

        public bool Fired {
            get { return Interlocked.CompareExchange(ref _fired, 0, 0) == 1; }
        }

        public void Dispose() {
            _timer.Dispose();
        }
    }

	public static class TimeoutHelperV2 {
		public static TimeoutControllerV2 CreateTimeoutController(PowerShell ps, int timeoutMilliseconds) {
			return new TimeoutControllerV2(ps, timeoutMilliseconds);
        }
    }
}
'@
	}
	catch {
		if (-not ('ZeroTrustAssessment.TimeoutHelperV2' -as [type])) {
			throw
		}
	}
}

function New-ZtTimeoutErrorRecord {
	param (
		[Parameter(Mandatory = $true)]
		$Test,

		[Parameter(Mandatory = $true)]
		[timespan]
		$Timeout
	)

	$message = "Test '$($Test.TestID)' timed out after $($Timeout.ToString('hh\:mm\:ss'))"
	$exception = [System.TimeoutException]::new($message)
	[System.Management.Automation.ErrorRecord]::new(
		$exception,
		'ZtTestTimeout',
		[System.Management.Automation.ErrorCategory]::OperationTimeout,
		$Test
	)
}

function Set-ZtTimedOutResult {
	param (
		[Parameter(Mandatory = $true)]
		$Result,

		[Parameter(Mandatory = $true)]
		$Test,

		[Parameter(Mandatory = $true)]
		[timespan]
		$Timeout
	)

	if ($Result.TimedOut) {
		return
	}

	$Result.TimedOut = $true
	$Result.Success = $false
	$Result.Output = $null
	$Result.Error = New-ZtTimeoutErrorRecord -Test $Test -Timeout $Timeout

	try {
		Add-ZtTestResultDetail -TestId $Test.TestID -Status $false -Result "The test did not complete within the configured timeout of $($Timeout.ToString('hh\:mm\:ss')). Partial results, if any, were discarded."
	}
	catch {
		Write-PSFMessage -Level Warning -Message "Failed to overwrite timed-out test result detail for test '{0}': {1}" -StringValues $Test.TestID, $_ -Target $Test -Tag timeout
	}

	Write-PSFMessage -Level Warning -Message "Test '{0}' timed out after {1}" -StringValues $Test.TestID, $Timeout.ToString('hh\:mm\:ss') -Target $Test -ErrorRecord $Result.Error -Tag timeout
}
