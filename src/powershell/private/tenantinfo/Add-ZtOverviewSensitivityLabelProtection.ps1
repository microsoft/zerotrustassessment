<#
.SYNOPSIS
    Builds the sensitivity label protection overview (spec 35063).
#>

function Add-ZtOverviewSensitivityLabelProtection {
    [CmdletBinding()]
    param()

    $tenantInfoName = 'SensitivityLabelProtection'
    $activity = 'Building sensitivity label protection overview'
    Write-ZtProgress -Activity $activity -Status 'Querying sensitivity labels'

    try {
        $labels = @(Get-Label -IncludeDetailedLabelActions -ErrorAction Stop)
        $enabledLabels = @($labels | Where-Object { $_.Disabled -ne $true })

        $categories = foreach ($label in $enabledLabels) {
            $labelActions = @()
            if (-not [string]::IsNullOrWhiteSpace([string]$label.LabelActions)) {
                $labelActions = @($label.LabelActions | ConvertFrom-Json -ErrorAction Stop)
            }

            $encryptAction = @($labelActions | Where-Object { $_.Type -ieq 'encrypt' } | Select-Object -First 1)
            $encryptionDisabled = $encryptAction.Count -gt 0 -and @(
                $encryptAction[0].Settings |
                    Where-Object { $_.Key -ieq 'disabled' -and $_.Value -ieq 'true' }
            ).Count -gt 0

            $hasEncryption = $encryptAction.Count -gt 0 -and -not $encryptionDisabled
            $hasDke = $hasEncryption -and $label.Capabilities -contains 'DoubleKeyEncryption'
            $hasVisualMarking =
                $label.ApplyContentMarkingHeaderEnabled -eq $true -or
                $label.ApplyContentMarkingFooterEnabled -eq $true -or
                $label.ApplyWaterMarkingEnabled -eq $true -or
                $label.ApplyDynamicWatermarkingEnabled -eq $true

            if ($hasDke) {
                'Encryption + DKE'
            }
            elseif ($hasEncryption) {
                'Encryption'
            }
            elseif ($hasVisualMarking) {
                'Visual marking only'
            }
            else {
                'Classification only'
            }
        }

        $totalLabelCount = $categories.Count
        $encryptionDkeCount = @($categories | Where-Object { $_ -eq 'Encryption + DKE' }).Count
        $encryptionCount = @($categories | Where-Object { $_ -eq 'Encryption' }).Count
        $visualMarkingOnlyCount = @($categories | Where-Object { $_ -eq 'Visual marking only' }).Count
        $classificationOnlyCount = @($categories | Where-Object { $_ -eq 'Classification only' }).Count

        if ($totalLabelCount -ne ($encryptionDkeCount + $encryptionCount + $visualMarkingOnlyCount + $classificationOnlyCount)) {
            throw 'Sensitivity label protection counts are inconsistent.'
        }

        $source = "$totalLabelCount labels"
        $summary = @{
            description               = 'Strongest protection applied by configured sensitivity labels.'
            totalLabelCount           = $totalLabelCount
            encryptionDkeCount        = $encryptionDkeCount
            encryptionCount           = $encryptionCount
            visualMarkingOnlyCount    = $visualMarkingOnlyCount
            classificationOnlyCount   = $classificationOnlyCount
            nodes                     = @(
                @{ source = $source; target = 'Encryption + DKE'; value = $encryptionDkeCount }
                @{ source = $source; target = 'Encryption'; value = $encryptionCount }
                @{ source = $source; target = 'Visual marking only'; value = $visualMarkingOnlyCount }
                @{ source = $source; target = 'Classification only'; value = $classificationOnlyCount }
            )
        }

        Add-ZtTenantInfo -Name $tenantInfoName -Value $summary
    }
    catch {
        Write-PSFMessage 'Unable to build sensitivity label protection overview.' -Tag Test -Level Warning
        Add-ZtTenantInfo -Name $tenantInfoName -Value $null
    }
}
