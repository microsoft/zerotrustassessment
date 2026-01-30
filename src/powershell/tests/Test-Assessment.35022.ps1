<#
.SYNOPSIS
    On-Demand Scans Configured for Sensitive Information Discovery

.DESCRIPTION
    Checks if on-demand scans are configured for sensitive information discovery in SharePoint, OneDrive, and Exchange.
    Ref: https://learn.microsoft.com/en-us/purview/on-demand-classification

.NOTES
    Test ID: 35022
    Pillar: Data
    Risk Level: Medium
    User Impact: Low
    Implementation Cost: Medium
#>

function Test-Assessment35022 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Microsoft 365 E5',
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = 'Workforce',
        TestId = 35022,
        Title = 'On-Demand Scans Configured for Sensitive Information Discovery',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking On-Demand Scan Configuration for Sensitive Information Discovery'
    Write-ZtProgress -Activity $activity -Status 'Getting on-demand scans'

    $scansList = $null
    $errorMsg = $null

    try {
        # Query 1: Get all on-demand scans
        $scansList = Get-SensitiveInformationScan -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying on-demand scans: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
        $scanCount = 0
        $tableData = $null
        $statusCounts = $null
        $hasSharePoint = 0
        $hasOneDrive = 0
        $hasExchange = 0
        $mostRecentScan = $null
    }
    else {
        $scanCount = if ($null -ne $scansList) { @($scansList).Count } else { 0 }
        $passed = $scanCount -ge 1

        if ($scanCount -gt 0) {
            # SIT GUID Mapping
            $sitGuidMap = @{
                "50842eb7-edc8-4019-85dd-5a5c1f2bb085" = "Credit Card Number"
                "a44669fe-0d48-453d-a9b1-2cc83f2cba77" = "U.S. Social Security Number (SSN)"
                "ed36cf51-9d63-40f3-a9a6-5a865c418d21" = "U.S. Bank Account Number"
                "48ee9090-3f74-4238-89c9-6c0a93767a8f" = "SWIFT Code"
                "50f56e32-3a6f-459f-82e9-e2b27b96b430" = "Drivers License Number (U.S.)"
                "65ce4b3d-79b3-46c0-ba9d-8226d98130c8" = "IBAN (International Banking Account Number)"
                "3b35900d-fd2d-446b-b3ad-b4723419e2d5" = "ABA Routing Number"
                "f3dbc5dd-e2d4-4487-b43c-ebd87f349aa4" = "Canada Social Insurance Number"
                "f87b75b6-570d-465d-a91a-f0d9b9e0b000" = "U.K. National Insurance Number (NINO)"
                "b3a2fd72-cc1b-40fc-b0dc-6c5ca0e00f6f" = "International Medical Record Number (MRN)"
            }

            # Build table with scan details
            $tableData = @()
            foreach ($scan in @($scansList)) {
                # Get detailed scan info
                $scanDetail = Get-SensitiveInformationScan -Identity $scan.Name -ErrorAction SilentlyContinue
                if (-not $scanDetail) { $scanDetail = $scan }

                # Parse SIT details
                $sitDetails = @()
                if ($scanDetail.ItemStatistics -and $scanDetail.ItemStatistics.SIT) {
                    $sits = $scanDetail.ItemStatistics.SIT
                    $sitKeys = if ($sits -is [System.Collections.IDictionary]) { $sits.Keys } elseif ($sits -is [PSCustomObject]) { $sits.PSObject.Properties.Name } else { $null }

                    if ($sitKeys) {
                        foreach ($guid in $sitKeys) {
                            $count = if ($sits -is [System.Collections.IDictionary]) { $sits[$guid] } else { $sits.$guid }
                            $friendlyName = if ($sitGuidMap.ContainsKey($guid)) { $sitGuidMap[$guid] } else { "Unknown SIT - $guid" }
                            $sitDetails += "$friendlyName`: $count matches"
                        }
                    }
                }

                $sitString = if ($sitDetails.Count -gt 0) { $sitDetails -join ", " } else { "None" }
                $workload = if ($scanDetail.Workload) { $scanDetail.Workload -join ", " } else { "" }
                $lastScanTime = if ($scanDetail.LastScanStartTime) { $scanDetail.LastScanStartTime } else { "" }

                $tableData += [PSCustomObject]@{
                    Name                      = $scanDetail.Name
                    Status                    = $scanDetail.SensitiveInformationScanStatus
                    Workload                  = $workload
                    'SIT Detected'            = $sitString
                    'Created (UTC)'           = $scanDetail.WhenCreatedUTC
                    'Last Scan Start'         = $lastScanTime
                }
            }

            # Count scans by status
            $statusCounts = @{}
            @($scansList) | ForEach-Object {
                $status = $_.SensitiveInformationScanStatus
                if ($statusCounts.ContainsKey($status)) {
                    $statusCounts[$status]++
                } else {
                    $statusCounts[$status] = 1
                }
            }

            # Check workload coverage
            $hasSharePoint = @($scansList) | Where-Object { $_.Workload -contains "SharePoint" } | Measure-Object | Select-Object -ExpandProperty Count
            $hasOneDrive = @($scansList) | Where-Object { $_.Workload -contains "OneDrive" } | Measure-Object | Select-Object -ExpandProperty Count
            $hasExchange = @($scansList) | Where-Object { $_.Workload -contains "Exchange" } | Measure-Object | Select-Object -ExpandProperty Count

            # Get most recent scan time
            $mostRecentScan = @($scansList) |
                Where-Object { $_.LastScanStartTime } |
                Sort-Object LastScanStartTime -Descending |
                Select-Object -First 1 |
                Select-Object -ExpandProperty LastScanStartTime
        }
        else {
            $tableData = $null
            $statusCounts = $null
            $hasSharePoint = 0
            $hasOneDrive = 0
            $hasExchange = 0
            $mostRecentScan = $null
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Unable to retrieve on-demand scan configuration due to error: $errorMsg`n`n"
        $testResultMarkdown += "Ensure you have the required permissions (Compliance Administrator, Compliance Data Administrator, or Security Administrator) and that Security & Compliance Center PowerShell is connected via `Connect-IPPSSession`."
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ At least one on-demand scan is configured in the organization, enabling discovery and classification of historical sensitive information.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No on-demand scans are configured in the organization; historical sensitive data cannot be discovered.`n`n"
        }

        $testResultMarkdown += "### On-Demand Scan Configuration Summary`n`n"

        if ($scanCount -gt 0 -and $tableData) {
            # Convert table to markdown
            $testResultMarkdown += "**Scan Details:**`n`n"
            $testResultMarkdown += "| Name | Status | Workload | SIT Detected | Created (UTC) | Last Scan Start |`n"
            $testResultMarkdown += "|------|--------|----------|--------------|---------------|-----------------|`n"

            foreach ($row in $tableData) {
                $testResultMarkdown += "| $($row.Name) | $($row.Status) | $($row.Workload) | $($row.'SIT Detected') | $($row.'Created (UTC)') | $($row.'Last Scan Start') |`n"
            }

            $testResultMarkdown += "`n"

            # Build summary statistics
            $testResultMarkdown += "**Summary Statistics:**`n`n"
            $testResultMarkdown += "* **Total On-Demand Scans Configured:** $scanCount`n"
            $testResultMarkdown += "* **Scans by Status:**`n"
            foreach ($status in ($statusCounts.Keys | Sort-Object)) {
                $testResultMarkdown += "  * $status`: $($statusCounts[$status])`n"
            }
            $testResultMarkdown += "* **Locations Scanned:**`n"
            $testResultMarkdown += "  * SharePoint: $(if ($hasSharePoint -gt 0) { 'Yes' } else { 'No' })`n"
            $testResultMarkdown += "  * OneDrive: $(if ($hasOneDrive -gt 0) { 'Yes' } else { 'No' })`n"
            $testResultMarkdown += "  * Exchange: $(if ($hasExchange -gt 0) { 'Yes' } else { 'No' })`n"
            $testResultMarkdown += "* **Most Recent Scan Completion:** $(if ($mostRecentScan) { $mostRecentScan } else { 'No completed scans' })`n"
        }
        else {
            $testResultMarkdown += "* **Total On-Demand Scans Configured:** 0`n"
            $testResultMarkdown += "* **Status:** No scans are configured`n"
        }

        $testResultMarkdown += "`n[Manage On-Demand Scans in Microsoft Purview Portal](https://purview.microsoft.com/informationprotection/dataclassification/colddatascans)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId             = '35022'
        Title              = 'On-Demand Scans Configured for Sensitive Information Discovery'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
