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

$jsonContent | Add-Member -NotePropertyName "IsDemo" -NotePropertyValue 'true' -Force

# Populate overview dashboard data with sample values
Write-Host "Populating overview dashboard data..." -ForegroundColor Cyan

# Ensure we have meaningful test result summaries for the dashboard
if ($null -eq $jsonContent.TestResultSummary) {
    $jsonContent | Add-Member -NotePropertyName "TestResultSummary" -NotePropertyValue @{}
}

# Set sample data for test results summary
$jsonContent.TestResultSummary.IdentityPassed = 85
$jsonContent.TestResultSummary.IdentityTotal = 100
$jsonContent.TestResultSummary.DevicesPassed = 25
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
        entraregistered   = 100
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

# Process each test to anonymize user data in TestDescription and TestResult
if ($userMappings.Count -gt 0) {
    $replacementCount = 0

    # Helper script block that applies all user-mapping + catch-all replacements
    # to a single string and returns the anonymized version.
    $applyAnonymization = {
        param([string]$text)

        if ([string]::IsNullOrEmpty($text)) { return $text }

        # Secret redaction (must run first, before any other transforms).
        # The assessment can capture failed HTTP requests in error records,
        # which include the outbound "Authorization: Bearer <JWT>" header.
        # We also redact bare JWT-looking tokens (eyXXX.YYY.ZZZ) anywhere in
        # the text, as a defence in depth.
        # Redact "Authorization: Bearer <token>" (optionally wrapped over
        # multiple whitespace chars after the colon).
        $text = $text -replace '(?i)Authorization\s*:\s*Bearer\s+[A-Za-z0-9._\-]+', 'Authorization: Bearer [REDACTED]'
        # Redact "Bearer <jwt>" without the Authorization header prefix.
        $text = $text -replace '(?i)\bBearer\s+ey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+', 'Bearer [REDACTED]'
        # Redact bare 3-part JWTs (header.payload.signature, base64url).
        $text = $text -replace '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', '[REDACTED-JWT]'

        # Replace each user's display name and UPN from the mapping.
        # UPNs are replaced before display names because display names are often
        # substrings of UPNs (e.g. "manoj" is in "manoj.p@..." and "Manoj.Kesana@...").
        foreach ($mapping in $userMappings) {
            if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalUserPrincipalName)) {
                $text = $text -replace [regex]::Escape($mapping.OriginalUserPrincipalName), $mapping.DemoUserPrincipalName
            }
            if (-not [string]::IsNullOrWhiteSpace($mapping.OriginalDisplayName)) {
                $text = $text -replace [regex]::Escape($mapping.OriginalDisplayName), $mapping.DemoDisplayName
            }
        }

        # Catch-all replacements for tenant-specific strings that may slip past
        # the per-user mappings (e.g. new users not yet in demo-users.csv).
        # Order matters: do simple, well-known swaps first so already-mapped
        # demo accounts (finley@elapora.com -> finley@contoso.com) stay readable.
        # Anything still on elapora.com after this is unmapped and gets a
        # generic demouser-* alias.
        $text = $text -replace [regex]::Escape('@elapora.com'), '@contoso.com'
        $text = $text -replace [regex]::Escape('pora.onmicrosoft.com'), 'contoso.onmicrosoft.com'
        # Replace the bare tenant brand "elapora" (used in service-principal /
        # app-registration display names) with "contoso".
        $text = $text -replace '(?i)elapora', 'contoso'
        $text = $text -replace 'erill', 'anson'

        # External guest users from other tenants: Name.Surname_otherorg.com#EXT#@...
        # -> guest-user@external.com#EXT#@contoso.com
        $text = $text -replace '(?i)[A-Za-z0-9._-]+_[A-Za-z0-9.-]+\.com#EXT#@[A-Za-z0-9.-]+', 'guest-user_external.com#EXT#@contoso.com'

        # Auto-generated agent / app users: AgentUser1234567@... -> demouser1234567@contoso.com
        $text = $text -replace '(?i)AgentUser(\d+)@[A-Za-z0-9.-]+', 'demouser$1@contoso.com'
        # Any remaining UPN on the source tenant domain (only fires if @elapora.com
        # somehow re-appears, or for variant spellings).
        $text = $text -replace '(?i)([A-Za-z0-9._-]+)@elapora\.com', 'demouser-$1@contoso.com'
        # GUID-like external UPN prefixes on the onmicrosoft tenant remnants
        $text = $text -replace '(?i)([a-f0-9]{8,})@(contoso|pora)\.onmicrosoft\.com', 'demouser-$1@contoso.onmicrosoft.com'

        # Standalone first-name / short-handle variants that show up in tenant-
        # owned resource names (CA policies, app names, test accounts, etc.).
        # These run AFTER the structured mappings so we don't double-replace.
        $text = $text -replace '(?i)\b(komal[_-]?test|komal[_-]?\d+|komal\.p|komal)\b', 'peyton'
        $text = $text -replace '(?i)\b(manoj[_-]?test|manoj[_-]?\d+|manoj\.kesana|manoj\.p|manoj)\b', 'finley'
        $text = $text -replace '(?i)\b(praneeth[_-]?test|praneeth[_-]?\d+|praneeth)\b', 'parker'
        $text = $text -replace '(?i)\b(sandeep\.p|sandeep)\b', 'sage'
        $text = $text -replace '(?i)\b(sushant\.p|sushant)\b', 'river'
        $text = $text -replace '(?i)\b(chukka\.p|chukka)\b', 'cameron'
        $text = $text -replace '(?i)\b(varsha\.mane|varsha)\b', 'avery.brooks'
        $text = $text -replace '(?i)\b(ravi\.kalwani|ravik|ravi)\b', 'ellis'
        $text = $text -replace '(?i)(madura\.sonnadara|madura\w*)', 'charlie'
        $text = $text -replace '(?i)\b(bagula|bagul)\b', 'morgan'
        $text = $text -replace '(?i)\bafif(\.p|ahmed)?\b', 'hayden'
        $text = $text -replace '(?i)\bkshitiz\b', 'sky'
        $text = $text -replace '(?i)\b(jackief|jackie\s+fernandez)\b', 'jules'
        $text = $text -replace '(?i)\bjackie\b', 'jules'
        $text = $text -replace '(?i)\b(ty\.?grady(test)?|tygrady(test)?|grady)\b', 'dakota'
        $text = $text -replace '(?i)\b(aleksandar|aleks)\b', 'jordan'
        $text = $text -replace '(?i)\bdamien\b', 'avery'
        $text = $text -replace '(?i)\bgael\b', 'jamie'
        $text = $text -replace '(?i)\b(aahmed[_-]?test|aahmed)\b', 'hayden-test'

        return $text
    }

    foreach ($test in $jsonContent.Tests) {
        $wasModified = $false

        # Process TestDescription field
        if ($null -ne $test.TestDescription -and $test.TestDescription.Length -gt 0) {
            $originalDescription = $test.TestDescription
            $test.TestDescription = & $applyAnonymization $test.TestDescription
            if ($originalDescription -ne $test.TestDescription) {
                $wasModified = $true
            }
        }

        # Process TestResult field
        if ($null -ne $test.TestResult -and $test.TestResult.Length -gt 0) {
            $originalResult = $test.TestResult
            $test.TestResult = & $applyAnonymization $test.TestResult
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

    # Also anonymize string values anywhere under TenantInfo. Some report
    # sections (e.g. ConfigDeviceAppProtectionPolicies) embed raw policy
    # payloads that can contain personal URLs/emails, and they are NOT under
    # the Tests array, so the per-test loop above never sees them.
    Write-Host "Anonymizing string values under TenantInfo..." -ForegroundColor Cyan

    $anonymizeNode = {
        param($node)

        if ($null -eq $node) { return }
        # Primitives don't need recursion.
        if ($node -is [string] -or $node.GetType().IsPrimitive -or $node -is [datetime] -or $node -is [decimal]) { return }

        if ($node -is [System.Collections.IDictionary]) {
            $keys = @($node.Keys)
            foreach ($k in $keys) {
                $v = $node[$k]
                if ($v -is [string]) {
                    $node[$k] = & $applyAnonymization $v
                }
                elseif ($null -ne $v) {
                    & $anonymizeNode $v
                }
            }
            return
        }

        if ($node -is [System.Collections.IList]) {
            for ($i = 0; $i -lt $node.Count; $i++) {
                $v = $node[$i]
                if ($v -is [string]) {
                    $node[$i] = & $applyAnonymization $v
                }
                elseif ($null -ne $v) {
                    & $anonymizeNode $v
                }
            }
            return
        }

        # PSCustomObject (the shape ConvertFrom-Json produces).
        if ($node -is [System.Management.Automation.PSCustomObject]) {
            foreach ($prop in @($node.PSObject.Properties)) {
                $v = $prop.Value
                if ($v -is [string]) {
                    $prop.Value = & $applyAnonymization $v
                }
                elseif ($null -ne $v) {
                    & $anonymizeNode $v
                }
            }
            return
        }
    }

    if ($null -ne $jsonContent.TenantInfo) {
        & $anonymizeNode $jsonContent.TenantInfo
    }
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

# ---------------------------------------------------------------------------
# Post-generation verification: scan the produced HTML for known tenant
# fingerprints. Anything found here means an individual / tenant identifier
# slipped past anonymization and should be fixed (either by adding a row to
# demo-users.csv or by extending the catch-all rules above).
# ---------------------------------------------------------------------------
Write-Host "Verifying anonymized output..." -ForegroundColor Cyan

$leakPatterns = @(
    @{ Name = 'elapora brand';        Pattern = '(?i)elapora' }
    @{ Name = 'pora.onmicrosoft.com'; Pattern = '(?i)pora\.onmicrosoft\.com' }
    @{ Name = 'merill literal';       Pattern = '(?i)merill' }
    @{ Name = 'AgentUserNNNN';        Pattern = '(?i)AgentUser\d+' }
    @{ Name = 'manoj';                Pattern = '(?i)\bmanoj\b' }
    @{ Name = 'afif';                 Pattern = '(?i)\bafif\b' }
    @{ Name = 'jackie';               Pattern = '(?i)\bjackie\b' }
    @{ Name = 'kshitiz';              Pattern = '(?i)\bkshitiz\b' }
    @{ Name = 'praneeth';             Pattern = '(?i)\bpraneeth\b' }
    @{ Name = 'komal';                Pattern = '(?i)\bkomal\b' }
    @{ Name = 'grady';                Pattern = '(?i)\bgrady\b' }
    @{ Name = 'madura';               Pattern = '(?i)\bmadura\b' }
    @{ Name = 'varsha';               Pattern = '(?i)\bvarsha\b' }
    @{ Name = 'sandeep';              Pattern = '(?i)\bsandeep\b' }
    @{ Name = 'sushant';              Pattern = '(?i)\bsushant\b' }
    @{ Name = 'bagul';                Pattern = '(?i)\bbagul\b' }
    @{ Name = 'aleksandar';           Pattern = '(?i)\baleksandar\b' }
    @{ Name = 'damien';               Pattern = '(?i)\bdamien\b' }
    @{ Name = 'Bearer token';         Pattern = '(?i)Authorization\s*:\s*Bearer\s+[A-Za-z0-9._\-]+' }
    @{ Name = 'JWT (eyJ...)';         Pattern = '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' }
)

$producedHtml = Get-Content -Path $OutputHtmlPath -Raw
$hasLeaks = $false
foreach ($p in $leakPatterns) {
    $matches = [regex]::Matches($producedHtml, $p.Pattern)
    if ($matches.Count -gt 0) {
        $hasLeaks = $true
        $sample = ($matches | Select-Object -First 3 | ForEach-Object { $_.Value }) -join ', '
        Write-Warning "Anonymization leak: '$($p.Name)' still appears $($matches.Count) time(s). Samples: $sample"
    }
}

if (-not $hasLeaks) {
    Write-Host "No known tenant fingerprints detected in output." -ForegroundColor Green
}
else {
    Write-Warning "Add the leaking values to demo-users.csv or extend the catch-all rules in New-DemoReport.ps1."
}
