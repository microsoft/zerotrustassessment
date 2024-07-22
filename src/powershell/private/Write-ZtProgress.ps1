<#
.SYNOPSIS
   Write progress to the console based on the current verbosity level.

.DESCRIPTION
   Show updates to the user on the current activity.
#>

function Write-ZtProgress(
    # The current step of the overal generation
    [ValidateSet('SignInLog', 'AuditLog', 'ServicePrincipal', 'AppPerm', 'DownloadDelegatePerm', 'ProcessDelegatePerm', 'GenerateExcel', 'Complete')]
    $MainStep,
    $Status = 'Processing...',
    # The percentage of completion within the child step
    $ChildPercent,
    [switch]$ForceRefresh) {
    $percent = 0
    switch ($MainStep) {
        'SignInLog' {
            $percent = GetNextPercent $ChildPercent 2 5
            $activity = 'Downloading service principals'
        }
        'AuditLog' {
            $percent = GetNextPercent $ChildPercent 5 7
            $activity = 'Downloading service principals'
        }
        'ServicePrincipal' {
            $percent = GetNextPercent $ChildPercent 7 10
            $activity = 'Downloading service principals'
        }
        'AppPerm' {
            $percent = GetNextPercent $ChildPercent 10 50
            $activity = 'Downloading application permissions'
        }
        'DownloadDelegatePerm' {
            $percent = GetNextPercent $ChildPercent 50 75
            $activity = 'Downloading delegate permissions'
        }
        'ProcessDelegatePerm' {
            $percent = GetNextPercent $ChildPercent 75 90
            $activity = 'Processing delegate permissions'
        }
        'GenerateExcel' {
            $percent = GetNextPercent $ChildPercent 90 99
            $activity = 'Processing risk information'
        }
        'Complete' {
            $percent = 100
            $activity = 'Complete'
        }
    }

    if ($ForceRefresh.IsPresent) {
        Start-Sleep -Milliseconds 250
    }
    Write-Progress -Id 0 -Activity $activity -PercentComplete $percent -Status $Status
}

function GetNextPercent($childPercent, $parentPercent, $nextPercent) {
    if ($childPercent -eq 0) { return $parentPercent }

    $gap = $nextPercent - $parentPercent
    return (($childPercent / 100) * $gap) + $parentPercent
}
