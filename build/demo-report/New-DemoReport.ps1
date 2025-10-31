<#
.SYNOPSIS
    Creates an anonymized demo report from an existing Zero Trust Assessment JSON report.

.DESCRIPTION
    This script takes an existing Zero Trust Assessment JSON report and:
    - Anonymizes sensitive data (tenant domain, name, ID, user emails, etc.)
    - Populates the overview dashboard data to display all charts
    - Generates an HTML report from the anonymized JSON

.PARAMETER InputJsonPath
    Path to the existing Zero Trust Assessment JSON report.
    Example: /Users/merill/GitHub/zerotrustassessment/ZeroTrustReport/pora/2025-10-27-Full/zt-export/ZeroTrustAssessmentReport.json

.PARAMETER OutputHtmlPath
    Path where the generated HTML report should be saved.
    Example: /Users/merill/GitHub/zerotrustassessment/SampleReport.html

.EXAMPLE
    .\New-DemoReport.ps1 -InputJsonPath "C:\Reports\ZeroTrustAssessmentReport.json" -OutputHtmlPath "C:\Reports\DemoReport.html"

.EXAMPLE
    .\New-DemoReport.ps1 -InputJsonPath "/Users/merill/GitHub/zerotrustassessment/ZeroTrustReport/pora/2025-10-27-Full/zt-export/ZeroTrustAssessmentReport.json" -OutputHtmlPath "/Users/merill/GitHub/zerotrustassessment/SampleReport.html"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$InputJsonPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputHtmlPath
)

# Set up paths
$moduleRootPath = Join-Path $PSScriptRoot "..\src\powershell"

Write-Host "Loading Get-HtmlReport function..." -ForegroundColor Cyan

# Set the module root variable that Get-HtmlReport expects
$script:ModuleRoot = $moduleRootPath

# Create a fixed version of Get-HtmlReport that properly serializes JSON
function Get-HtmlReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $AssessmentResults,

        [Parameter(Mandatory = $false)]
        [string] $Path
    )

    # Convert to JSON properly with sufficient depth
    $json = $AssessmentResults | ConvertTo-Json -Depth 100 -Compress

    $htmlFilePath = Join-Path -Path $script:ModuleRoot -ChildPath '../../../src/powershell/assets/ReportTemplate.html'
    $templateHtml = Get-Content -Path $htmlFilePath -Raw

    # Insert the test results json into the template
    $startMarker = 'reportData={'
    $endMarker = 'EndOfJson:"EndOfJson"}'
    $insertLocationStart = $templateHtml.IndexOf($startMarker)
    $insertLocationEnd = $templateHtml.IndexOf($endMarker) + $endMarker.Length

    $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
    $outputHtml += "reportData= $json"
    $outputHtml += $templateHtml.Substring($insertLocationEnd)

    return $outputHtml
}

Write-Host "Loading JSON report from: $InputJsonPath" -ForegroundColor Cyan

# Load the JSON report
$jsonContent = Get-Content -Path $InputJsonPath -Raw | ConvertFrom-Json -Depth 100

Write-Host "Anonymizing report data..." -ForegroundColor Cyan

# Anonymize tenant information
$jsonContent.TenantId = "aaaabbbb-0000-cccc-1111-dddd2222eeee"
$jsonContent.TenantName = "Contoso"
$jsonContent.Domain = "contoso.com"
$jsonContent.Account = "admin@contoso.com"

# Populate overview dashboard data with sample values
Write-Host "Populating overview dashboard data..." -ForegroundColor Cyan

# Ensure we have meaningful test result summaries for the dashboard
if ($null -eq $jsonContent.TestResultSummary) {
    $jsonContent | Add-Member -NotePropertyName "TestResultSummary" -NotePropertyValue @{}
}

# Set sample data for test results summary
$jsonContent.TestResultSummary.IdentityPassed = 45
$jsonContent.TestResultSummary.IdentityTotal = 90
$jsonContent.TestResultSummary.DevicesPassed = 28
$jsonContent.TestResultSummary.DevicesTotal = 36

# Ensure TenantInfo exists
if ($null -eq $jsonContent.TenantInfo) {
    $jsonContent | Add-Member -NotePropertyName "TenantInfo" -NotePropertyValue @{}
}

# Set Tenant Overview with sample data
$jsonContent.TenantInfo.TenantOverview = @{
    UserCount          = 1250
    GuestCount         = 85
    GroupCount         = 340
    ApplicationCount   = 156
    DeviceCount        = 765
    ManagedDeviceCount = 733
}

# Set Device Overview with Desktop Devices Sankey data (Windows + macOS, healthy compliance numbers)
$jsonContent.TenantInfo.DeviceOverview = @{
    DesktopDevicesSummary = @{
        entrahybridjoined = 200
        entrajoined       = 285
        entrareigstered   = 100
        totalDevices      = 660
        description       = "Desktop devices (Windows and macOS) by join type and compliance status."
        nodes             = @(
            # Level 1: Desktop devices to OS
            @{ source = "Desktop devices"; target = "Windows"; value = 585 },
            @{ source = "Desktop devices"; target = "macOS"; value = 75 },
            # Level 2: Windows to join types
            @{ source = "Windows"; target = "Entra joined"; value = 285 },
            @{ source = "Windows"; target = "Entra registered"; value = 100 },
            @{ source = "Windows"; target = "Entra hybrid joined"; value = 200 },
            # Level 3: Windows join types to compliance
            # Entra joined devices - 60% compliant (reduced from 80%)
            @{ source = "Entra joined"; target = "Compliant"; value = 171 },
            @{ source = "Entra joined"; target = "Non-compliant"; value = 42 },
            @{ source = "Entra joined"; target = "Unmanaged"; value = 72 },
            # Entra hybrid joined devices - split between compliant and non-compliant
            @{ source = "Entra hybrid joined"; target = "Compliant"; value = 50 },
            @{ source = "Entra hybrid joined"; target = "Non-compliant"; value = 23 },
            @{ source = "Entra hybrid joined"; target = "Unmanaged"; value = 127 },
            # Entra registered devices - split between compliant and non-compliant (60% compliant)
            @{ source = "Entra registered"; target = "Compliant"; value = 60 },
            @{ source = "Entra registered"; target = "Non-compliant"; value = 40 },
            @{ source = "Entra registered"; target = "Unmanaged"; value = 0 },
            # Level 2: macOS directly to compliance (no join types) - 75% compliant
            @{ source = "macOS"; target = "Compliant"; value = 56 },
            @{ source = "macOS"; target = "Non-compliant"; value = 15 },
            @{ source = "macOS"; target = "Unmanaged"; value = 4 }
        )
    }
    MobileSummary         = @{
        totalDevices = 180
        description  = "Mobile devices by compliance status."
        nodes        = @(
            @{ source = "Mobile devices"; target = "Android"; value = 105 },
            @{ source = "Mobile devices"; target = "iOS"; value = 75 },
            # Android breakdown
            @{ source = "Android"; target = "Android (Company)"; value = 72 },
            @{ source = "Android"; target = "Android (Personal)"; value = 33 },
            # iOS breakdown
            @{ source = "iOS"; target = "iOS (Company)"; value = 58 },
            @{ source = "iOS"; target = "iOS (Personal)"; value = 17 },
            # Android Company compliance (83% compliant)
            @{ source = "Android (Company)"; target = "Compliant"; value = 60 },
            @{ source = "Android (Company)"; target = "Non-compliant"; value = 12 },
            # Android Personal compliance (30% compliant)
            @{ source = "Android (Personal)"; target = "Compliant"; value = 10 },
            @{ source = "Android (Personal)"; target = "Non-compliant"; value = 23 },
            # iOS Company compliance (90% compliant)
            @{ source = "iOS (Company)"; target = "Compliant"; value = 52 },
            @{ source = "iOS (Company)"; target = "Non-compliant"; value = 6 },
            # iOS Personal compliance (65% compliant)
            @{ source = "iOS (Personal)"; target = "Compliant"; value = 11 },
            @{ source = "iOS (Personal)"; target = "Non-compliant"; value = 6 }
        )
    }
    ManagedDevices        = @{
        enrolledDeviceCount              = 733
        mdmEnrolledCount                 = 585
        dualEnrolledDeviceCount          = 148
        lastModifiedDateTime             = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffffffK")
        deviceOperatingSystemSummary     = @{
            androidCount                     = 105
            iosCount                         = 75
            macOSCount                       = 75
            windowsMobileCount               = 0
            windowsCount                     = 525
            unknownCount                     = 0
            androidDedicatedCount            = 35
            androidDeviceAdminCount          = 0
            androidFullyManagedCount         = 0
            androidWorkProfileCount          = 50
            androidCorporateWorkProfileCount = 20
            configMgrDeviceCount             = 0
            aospUserlessCount                = 0
            aospUserAssociatedCount          = 0
            linuxCount                       = 0
            chromeOSCount                    = 0
        }
        deviceExchangeAccessStateSummary = @{
            allowedDeviceCount     = 690
            blockedDeviceCount     = 12
            quarantinedDeviceCount = 5
            unknownDeviceCount     = 8
            unavailableDeviceCount = 18
        }
        desktopCount                     = 553
        mobileCount                      = 180
        totalCount                       = 733
    }
    DeviceCompliance      = @{
        compliantDeviceCount     = 387
        nonCompliantDeviceCount  = 106
        errorDeviceCount         = 8
        inGracePeriodCount       = 15
        unknownDeviceCount       = 5
        notApplicableDeviceCount = 4
        configManagerCount       = 0
        remediatedDeviceCount    = 0
        conflictDeviceCount      = 0
    }
    DeviceOwnership       = @{
        personalCount  = 98
        corporateCount = 427
    }
}

# Set Authentication Methods Overview for All Users
$jsonContent.TenantInfo.OverviewAuthMethodsAllUsers = @{
    description = "Strongest authentication method registered by all users."
    nodes       = @(
        @{ source = "Users"; target = "Single factor"; value = 85 },
        @{ source = "Users"; target = "Phishable"; value = 980 },
        @{ source = "Users"; target = "Phish resistant"; value = 185 },
        @{ source = "Phishable"; target = "Phone"; value = 420 },
        @{ source = "Phishable"; target = "Authenticator"; value = 560 },
        @{ source = "Phish resistant"; target = "Passkey"; value = 125 },
        @{ source = "Phish resistant"; target = "WHfB"; value = 60 }
    )
}

# Set Authentication Methods Overview for Privileged Users
$jsonContent.TenantInfo.OverviewAuthMethodsPrivilegedUsers = @{
    description = "Strongest authentication method registered by privileged users."
    nodes       = @(
        @{ source = "Users"; target = "Single factor"; value = 2 },
        @{ source = "Users"; target = "Phishable"; value = 28 },
        @{ source = "Users"; target = "Phish resistant"; value = 15 },
        @{ source = "Phishable"; target = "Phone"; value = 8 },
        @{ source = "Phishable"; target = "Authenticator"; value = 20 },
        @{ source = "Phish resistant"; target = "Passkey"; value = 12 },
        @{ source = "Phish resistant"; target = "WHfB"; value = 3 }
    )
}

# Set Conditional Access MFA Overview
$jsonContent.TenantInfo.OverviewCaMfaAllUsers = @{
    description = "Over the past 30 days, 68.5% of sign-ins were protected by conditional access policies enforcing multifactor."
    nodes       = @(
        @{ source = "User sign in"; target = "No CA applied"; value = 394 },
        @{ source = "User sign in"; target = "CA applied"; value = 856 },
        @{ source = "CA applied"; target = "No MFA"; value = 146 },
        @{ source = "CA applied"; target = "MFA"; value = 710 }

    )
}

# Set Conditional Access Devices Overview
$jsonContent.TenantInfo.OverviewCaDevicesAllUsers = @{
    description = "Over the past 30 days, 71.2% of sign-ins were from compliant devices."
    nodes       = @(
        @{ source = "User sign in"; target = "Unmanaged"; value = 500 },
        @{ source = "User sign in"; target = "Managed"; value = 1150 },
        @{ source = "Managed"; target = "Non-compliant"; value = 260 },
        @{ source = "Managed"; target = "Compliant"; value = 890 }


    )
}

Write-Host "Anonymizing user information in test results..." -ForegroundColor Cyan

# Load the user mapping from CSV
$demoUsersCsvPath = Join-Path $PSScriptRoot "demo-users.csv"
if (-not (Test-Path $demoUsersCsvPath)) {
    Write-Warning "demo-users.csv not found at $demoUsersCsvPath. Skipping user anonymization."
    $userMappings = @()
}
else {
    Write-Host "Loading user mappings from: $demoUsersCsvPath" -ForegroundColor Cyan
    $userMappings = Import-Csv -Path $demoUsersCsvPath
    Write-Host "Loaded $($userMappings.Count) user mappings" -ForegroundColor Cyan
}

# Function to anonymize a GUID
function New-AnonymousGuid {
    param([string]$originalGuid)

    # Create a deterministic but anonymous GUID based on hash of original
    $hash = [System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($originalGuid))
    $guid = [System.Guid]::new($hash)
    return $guid.ToString()
}

# Process each test to anonymize user data in TestDescription and TestResult
if ($userMappings.Count -gt 0) {
    $replacementCount = 0

    foreach ($test in $jsonContent.Tests) {
        $wasModified = $false

        # Process TestDescription field
        if ($null -ne $test.TestDescription -and $test.TestDescription.Length -gt 0) {
            $originalDescription = $test.TestDescription

            # Replace each user's display name and UPN from the mapping
            foreach ($mapping in $userMappings) {
                # Replace display names (case-insensitive)
                if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalDisplayName)) {
                    $test.TestDescription = $test.TestDescription -replace [regex]::Escape($mapping.OriginalDisplayName), $mapping.DemoDisplayName
                }

                # Replace UPNs (case-insensitive)
                if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalUserPrincipalName)) {
                    $test.TestDescription = $test.TestDescription -replace [regex]::Escape($mapping.OriginalUserPrincipalName), $mapping.DemoUserPrincipalName
                }
            }

            if ($originalDescription -ne $test.TestDescription) {
                $wasModified = $true
            }
        }

        # Process TestResult field
        if ($null -ne $test.TestResult -and $test.TestResult.Length -gt 0) {
            $originalResult = $test.TestResult

            # Replace each user's display name and UPN from the mapping
            foreach ($mapping in $userMappings) {

                # Replace UPNs (case-insensitive)
                if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalUserPrincipalName)) {
                    $test.TestResult = $test.TestResult -replace [regex]::Escape($mapping.OriginalUserPrincipalName), $mapping.DemoUserPrincipalName
                }

                # Replace display names (case-insensitive)
                if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalDisplayName)) {
                    $test.TestResult = $test.TestResult -replace [regex]::Escape($mapping.OriginalDisplayName), $mapping.DemoDisplayName
                }

                # Catch all for domain
                $test.TestResult = $test.TestResult -replace [regex]::Escape("@elapora.com"), "@contoso.com"
                $test.TestResult = $test.TestResult -replace [regex]::Escape("erill"), "anson"
                $test.TestResult = $test.TestResult -replace [regex]::Escape("pora.onmicrosoft.com"), "contoso.onmicrosoft.com"
            }

            if ($originalResult -ne $test.TestResult) {
                $wasModified = $true
            }
        }

        # Track if any replacements were made in this test
        if ($wasModified) {
            $replacementCount++
        }
    }

    Write-Host "Anonymized user information in $replacementCount tests" -ForegroundColor Cyan
}
else {
    Write-Host "No user mappings available, skipping user anonymization" -ForegroundColor Yellow
}

Write-Host "Generating HTML report..." -ForegroundColor Cyan

# Get the directory for the output path to use as temp location
$outputDir = Split-Path -Path $OutputHtmlPath -Parent
if ([string]::IsNullOrEmpty($outputDir)) {
    $outputDir = Get-Location
}

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

# Generate HTML report using Get-HtmlReport
$htmlContent = Get-HtmlReport -AssessmentResults $jsonContent -Path $outputDir

# Save the HTML report
$htmlContent | Out-File -FilePath $OutputHtmlPath -Encoding utf8 -Force

Write-Host "Sample report generated successfully!" -ForegroundColor Green
Write-Host "Output: $OutputHtmlPath" -ForegroundColor Green

# Optionally save the anonymized JSON as well
$anonymizedJsonPath = $OutputHtmlPath -replace '\.html$', '.json'
$jsonContent | ConvertTo-Json -Depth 100 | Out-File -FilePath $anonymizedJsonPath -Encoding utf8 -Force
Write-Host "Anonymized JSON saved to: $anonymizedJsonPath" -ForegroundColor Green
