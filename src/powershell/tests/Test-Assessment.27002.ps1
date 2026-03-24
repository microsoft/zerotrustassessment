<#
.SYNOPSIS
    TLS inspection certificates have sufficient validity period to prevent service disruption

.DESCRIPTION
    Verifies that TLS inspection certificates in Global Secure Access have more than 90 days
    until expiration and no certificates have status of expiring or expired.

.NOTES
    Test ID: 27002
    Pillar: Network
    Risk Level: High
    SFI Pillar: Protect networks
#>

function Test-Assessment-27002 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = '27002',
        Title = 'TLS inspection certificates have sufficient validity period to prevent service disruption',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking TLS inspection certificate validity'

    # Prerequisite check: Verify TLS inspection is configured
    Write-ZtProgress -Activity $activity -Status 'Checking if TLS inspection is configured'

    $tlsInspectionPolicies = $null
    $errorMsg = $null
    try {
        $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Unable to retrieve TLS inspection policies: $errorMsg" -Level Warning
    }

    # If no TLS inspection policies exist, skip the test
    if (-not $errorMsg -and (-not $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0)) {
        Write-PSFMessage 'TLS inspection not configured - skipping test.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q1: Retrieve all TLS inspection certificates
    # Note: The Prefer header is required to get actual status values instead of unknownFutureValue
    $certificates = $null
    $results = @()
    $evaluatedResults = @()
    $totalCount = 0
    $activeCount = 0
    $expiringWithin90Days = 0
    $expiredCount = 0

    if (-not $errorMsg) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving TLS inspection certificates'

        try {
            $certificates = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tls/externalCertificateAuthorityCertificates' -ApiVersion beta -Headers @{ 'Prefer' = 'include-unknown-enum-members' } -ErrorAction Stop
        }
        catch {
            $errorMsg = $_
            Write-PSFMessage "Unable to retrieve TLS inspection certificates: $errorMsg" -Level Warning
        }
    }

    # If no certificates exist, TLS inspection policies exist but no certificates uploaded yet - Pass
    if (-not $errorMsg -and (-not $certificates -or $certificates.Count -eq 0)) {
        Write-PSFMessage 'TLS inspection policies exist but no certificates uploaded yet.' -Tag Test -Level Verbose
        $testResultMarkdown = "TLS inspection policies are configured but no certificates have been uploaded yet."
        Add-ZtTestResultDetail -TestId '27002' -Title 'TLS inspection certificates have sufficient validity period to prevent service disruption' -Status $true -Result $testResultMarkdown
        return
    }

    # Process certificates and calculate expiration details
    if (-not $errorMsg) {
        $currentDate = Get-Date
        $warningThresholdDays = 90
        # Skip certificates that are not actively in use (csrGenerated, enrolling, disabled)
        $skipStatuses = @('csrGenerated', 'enrolling', 'disabled')

        foreach ($cert in $certificates) {
            $isSkipped = $cert.status -in $skipStatuses

            $expirationDate = if ($cert.validity.endDateTime) {
                [datetime]$cert.validity.endDateTime
            }
            else {
                $null
            }

            $daysUntilExpiration = if ($expirationDate) {
                [math]::Floor(($expirationDate - $currentDate).TotalDays)
            }
            else {
                $null
            }

            # Determine if renewal is required
            $renewalRequired = $false
            if (-not $isSkipped) {
                if ($cert.status -in @('expiring', 'expired')) {
                    $renewalRequired = $true
                }
                elseif ($cert.status -in @('active', 'enabled') -and $null -ne $daysUntilExpiration -and $daysUntilExpiration -le $warningThresholdDays) {
                    $renewalRequired = $true
                }
            }

            $results += [PSCustomObject]@{
                Id                  = $cert.id
                Name                = $cert.name
                CommonName          = $cert.commonName
                OrganizationName    = $cert.organizationName
                Status              = $cert.status
                ExpirationDate      = $expirationDate
                DaysUntilExpiration = $daysUntilExpiration
                RenewalRequired     = $renewalRequired
                IsSkipped           = $isSkipped
            }
        }

        # Calculate statistics (only for non-skipped certificates)
        $evaluatedResults = @($results | Where-Object { -not $_.IsSkipped })
        $totalCount = $results.Count
        $activeCount = @($evaluatedResults | Where-Object { $_.Status -in @('active', 'enabled') }).Count
        $expiringWithin90Days = @($evaluatedResults | Where-Object { $_.RenewalRequired -and $_.Status -in @('active', 'enabled') }).Count
        $expiredCount = @($evaluatedResults | Where-Object { $_.Status -eq 'expired' }).Count
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Fail if there was an error retrieving data
    if ($errorMsg) {
        $passed = $false
        $testResultMarkdown = "❌ Unable to retrieve TLS inspection certificates due to error:`n`n$errorMsg`n`n%TestResult%"
    }
    else {
        # Pass if no evaluated certificates require renewal
        $certificatesRequiringRenewal = @($evaluatedResults | Where-Object { $_.RenewalRequired })
        if ($certificatesRequiringRenewal.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ All TLS inspection certificates have more than 90 days until expiration.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ TLS inspection certificate requires renewal; expiration is within 90 days or certificate status indicates expiring/expired.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Build certificate summary list
    $tlsInspectionLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TLSInspectionPolicy.ReactView'

    $mdInfo += @"

## [TLS Inspection Certificates]($tlsInspectionLink)

**Summary:**

- Total active certificates: $activeCount
- Certificates expiring within 90 days: $expiringWithin90Days
- Certificates already expired: $expiredCount

"@

    # Build certificates table
    if ($totalCount -gt 0) {
        $formatTemplate = @'

**Certificate Details:**

| Certificate name | Common name | Status | Expiration date | Days until expiration | Renewal required |
| :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        $tableRows = ''

        foreach ($cert in $results | Sort-Object DaysUntilExpiration) {
            $certName = if ($cert.Name) {
                Get-SafeMarkdown -Text $cert.Name
            }
            else {
                'N/A'
            }

            $commonName = if ($cert.CommonName) {
                Get-SafeMarkdown -Text $cert.CommonName
            }
            else {
                'N/A'
            }

            $statusDisplay = switch ($cert.Status) {
                'active' { 'Active' }
                'enabled' { 'Enabled' }
                'expiring' { 'Expiring' }
                'expired' { 'Expired' }
                'csrGenerated' { 'CSR Generated' }
                'enrolling' { 'Enrolling' }
                'disabled' { 'Disabled' }
                default { $cert.Status }
            }

            $expirationDateDisplay = if ($cert.ExpirationDate) {
                $cert.ExpirationDate.ToString('yyyy-MM-dd')
            }
            else {
                'N/A'
            }

            $daysDisplay = if ($null -ne $cert.DaysUntilExpiration) {
                if ($cert.DaysUntilExpiration -lt 0) {
                    "Expired ($([math]::Abs($cert.DaysUntilExpiration)) days ago)"
                }
                else {
                    $cert.DaysUntilExpiration.ToString()
                }
            }
            else {
                'N/A'
            }

            $renewalRequired = if ($cert.RenewalRequired) { 'Yes' } else { 'No' }

            $tableRows += "| $certName | $commonName | $statusDisplay | $expirationDateDisplay | $daysDisplay | $renewalRequired |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27002'
        Title  = 'TLS inspection certificates have sufficient validity period to prevent service disruption'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
