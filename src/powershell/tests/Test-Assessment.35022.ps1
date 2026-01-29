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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [Object]$Context
    )

    $TestId = "35022"
    $Result = "Investigate"
    $Message = ""
    $Details = @()

    try {
        # Check prerequisites
        if (-not (Get-Command Get-SensitiveInformationScan -ErrorAction SilentlyContinue)) {
            throw "Command 'Get-SensitiveInformationScan' not found. Ensure ExchangeOnlineManagement module is installed and connected."
        }

        # Query 1: Get all on-demand scans
        $ScansList = Get-SensitiveInformationScan -ErrorAction Stop

        # Evaluation Logic
        if ($null -ne $ScansList -and $ScansList.Count -ge 1) {
            $Result = "Pass"
            $Message = "At least one on-demand scan is configured in the organization, enabling discovery and classification of historical sensitive information."
        }
        else {
            $Result = "Fail"
            $Message = "No on-demand scans are configured in the organization; historical sensitive data cannot be discovered."
        }

        # SIT GUID Mapping
        $SitGuidMap = @{
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

        # Process Details
        foreach ($ScanSummary in $ScansList) {
            # Query 3: Get details for specific scan to ensure we have ItemStatistics
            $Scan = Get-SensitiveInformationScan -Identity $ScanSummary.Name -ErrorAction SilentlyContinue
            if (-not $Scan) { $Scan = $ScanSummary }

            $SitDetails = @()

            # ItemStatistics parsing
            if ($Scan.ItemStatistics -and $Scan.ItemStatistics.SIT) {
                $Sits = $Scan.ItemStatistics.SIT

                # Handle if it's a PSObject (common in deserialized objects) or Dictionary
                $SitKeys = if ($Sits -is [System.Collections.IDictionary]) { $Sits.Keys } elseif ($Sits -is [PSCustomObject]) { $Sits.PSObject.Properties.Name } else { $null }

                if ($SitKeys) {
                    foreach ($Guid in $SitKeys) {
                        $Count = if ($Sits -is [System.Collections.IDictionary]) { $Sits[$Guid] } else { $Sits.$Guid }
                        $FriendlyName = if ($SitGuidMap.ContainsKey($Guid)) { $SitGuidMap[$Guid] } else { "Unknown SIT - $Guid" }
                        $SitDetails += "$FriendlyName: $Count matches"
                    }
                }
            }

            $SitString = if ($SitDetails.Count -gt 0) { $SitDetails -join ", " } else { "None" }

            $Details += [PSCustomObject]@{
                Name                                   = $Scan.Name
                SensitiveInformationScanStatus         = $Scan.SensitiveInformationScanStatus
                Workload                               = if ($Scan.Workload) { $Scan.Workload -join ", " } else { "" }
                "Sensitive Information Types Detected" = $SitString
                WhenCreatedUTC                         = $Scan.WhenCreatedUTC
                LastScanStartTime                      = $Scan.LastScanSt
