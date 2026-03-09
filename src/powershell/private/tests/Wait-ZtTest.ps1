function Wait-ZtTest {
	<#
	.SYNOPSIS
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.DESCRIPTION
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.PARAMETER Workflow
		The PSFramework Runspace Workflow executing the tests.

	.PARAMETER Timeout
		The maximum time to wait for the workflow to complete before giving up and writing a warning message

	.PARAMETER StartedAt
		The DateTime when the workflow started. This is used in combination with Timeout to determine if the workflow has exceeded the allowed time.

	.EXAMPLE
		PS C:\> Wait-ZtTest -Workflow $workflow

		Wait for all Tests of the workflow in $workflow to complete, writing progress on screen and reporting failed tests.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSFramework.Runspace.RSWorkflow]
		$Workflow,

		[TimeSpan]
		$Timeout = '1.00:00:00',

		[datetime]
		$StartedAt = [DateTime]::Now
	)
	Begin {
		$failedTests = @{}
		$totalCount = $Workflow.Queues["Input"].TotalItemCount
		$progressID = Get-Random -Minimum 1 -Maximum 999
	}
	process {
		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -PercentComplete 0
		while (-not $Workflow.Queues["Results"].Closed -and $Timeout -gt ([DateTime]::Now - $StartedAt)) {
			Start-Sleep -Milliseconds 500

			$failed = Get-ZtTestStatistics | Where-Object Success -eq $false
			foreach ($failure in $failed) {
				if ($failedTests[$failure.TestID]) { continue }
				$failedTests[$failure.TestID] = $true
				Write-PSFMessage -Level Warning -Message "Error processing Test {0}" -StringValues $failure.TestID -ErrorRecord $failure.Error
			}
			$percent = ($Workflow.Queues["Results"].Count / $totalCount * 100) -as [int]
			if ($percent -lt 0) { $percent = 0 }
			if ($percent -gt 100) { $percent = 100 }

			$status = "Completed: $($Workflow.Queues["Results"].Count) / $totalCount"

			Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Status $status -PercentComplete $percent
		}

		if ($Timeout -le ([DateTime]::Now - $StartedAt)) {
			Write-PSFMessage -Level Warning -Message "Timeout of $($Timeout) reached while waiting for tests to complete. Processed $($Workflow.Queues["Results"].Count) out of $totalCount tests (left $($Workflow.Queues["Input"].Count) to process)." -Target $Workflow
		}

		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Completed
	}
}
