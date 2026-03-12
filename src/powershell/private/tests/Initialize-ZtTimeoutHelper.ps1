function Initialize-ZtTimeoutHelper {
	if ('ZeroTrustAssessment.TimeoutHelper' -as [type]) {
		return
	}

	try {
		Add-Type -TypeDefinition @'
using System;
using System.Management.Automation;
using System.Threading;

namespace ZeroTrustAssessment {
	public sealed class TimeoutController : IDisposable {
        private readonly Timer _timer;
        private int _fired;

		public TimeoutController(PowerShell ps, int timeoutMilliseconds) {
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

	public static class TimeoutHelper {
		public static TimeoutController CreateTimeoutController(PowerShell ps, int timeoutMilliseconds) {
			return new TimeoutController(ps, timeoutMilliseconds);
        }
    }
}
'@
	}
	catch {
		if (-not ('ZeroTrustAssessment.TimeoutHelper' -as [type])) {
			throw
		}
	}
}
