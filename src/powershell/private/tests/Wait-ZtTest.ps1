function Wait-ZtTest {
	<#
	.SYNOPSIS
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.DESCRIPTION
		Wait for all Test runs to complete, writing progress on screen and reporting failed tests.

	.PARAMETER Workflow
		The PSFramework Runspace Workflow executing the tests.

	.EXAMPLE
		PS C:\> Wait-ZtTest -Workflow $workflow

		Wait for all Tests of the workflow in $workflow to complete, writing progress on screen and reporting failed tests.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PSFramework.Runspace.RSWorkflow]
		$Workflow
	)
	Begin {
		$failedTests = @{}
		$totalCount = $Workflow.Queues["Input"].TotalItemCount
		$progressID = Get-Random -Minimum 1 -Maximum 999
	}
	process {
		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -PercentComplete 0
		$lastTest = "Starting..."
		while (-not $Workflow.Queues["Results"].Closed) {
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

			$lastMessage = Get-PSFMessage -Tag start | Select-Object -Last 1
			if ($lastMessage -and $lastMessage.StringValue) { $lastTest = $lastMessage.StringValue[0] }
			$status = "Completed: $($Workflow.Queues["Results"].Count) / $totalCount | Last Test: $lastTest"

			Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Status $status -PercentComplete $percent
		}

		Write-Progress -Id $progressID -Activity "Processing $($totalCount) Tests" -Completed
	}
}
