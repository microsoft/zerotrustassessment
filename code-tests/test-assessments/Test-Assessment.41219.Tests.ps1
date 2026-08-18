Describe 'Test-Assessment-41219' {
    BeforeAll {
        $srcRoot = Join-Path $PSScriptRoot '../../src/powershell'

        if (-not (Get-Command Write-PSFMessage -ErrorAction SilentlyContinue)) {
            function global:Write-PSFMessage {}
        }
        if (-not (Get-Command Write-ZtProgress -ErrorAction SilentlyContinue)) {
            function global:Write-ZtProgress {}
        }
        if (-not (Get-Command Invoke-ZtAzureResourceGraphRequest -ErrorAction SilentlyContinue)) {
            function global:Invoke-ZtAzureResourceGraphRequest {
                [CmdletBinding()]
                param([string] $Query)
            }
        }
        if (-not (Get-Command Get-SafeMarkdown -ErrorAction SilentlyContinue)) {
            function global:Get-SafeMarkdown { param($Text) return $Text }
        }
        if (-not (Get-Command Add-ZtTestResultDetail -ErrorAction SilentlyContinue)) {
            function global:Add-ZtTestResultDetail {
                param(
                    [string]   $Description, [bool]     $Status,    [string]   $Result,
                    [Object[]] $GraphObjects,[string]   $GraphObjectType,
                    [string]   $TestId,      [string]   $Title,     [string]   $SkippedBecause,
                    [string]   $UserImpact,  [string]   $Risk,      [string]   $ImplementationCost,
                    [string[]] $AppliesTo,   [string[]] $Tag,       [string]   $CustomStatus,
                    [string[]] $NotConnectedService,    [string]   $Pillar,    [string]   $Category
                )
            }
        }

        $classPath = Join-Path $srcRoot 'classes/ZtTest.ps1'
        if (-not ('ZtTest' -as [type])) { . $classPath }

        . (Join-Path $srcRoot 'tests/Test-Assessment.41219.ps1')

        $script:outputFile = Join-Path $PSScriptRoot '../TestResults/Report-Test-Assessment.41219.md'
        $outputDir = Split-Path $script:outputFile
        if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
        '# Test Results for 41219' | Set-Content $script:outputFile

        # Mock objects returned by Invoke-ZtAzureResourceGraphRequest (objectArray format — named properties).
        # Based on real tenant response provided by @astaykov.
        function global:New-MockCapacity {
            param(
                [string] $Name              = 'tralala-test',
                [string] $ResourceGroup     = 'secopilot-rg',
                [string] $Location          = 'eastus',
                [string] $SubscriptionId    = '11111111-fc82-4634-aa52-62dd91b3ebaa',
                [string] $SubscriptionName  = 'Test Subscription',
                [string] $ProvisioningState = 'Succeeded'
            )
            [PSCustomObject]@{
                id                = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.SecurityCopilot/capacities/$Name"
                name              = $Name
                subscriptionId    = $SubscriptionId
                subscriptionName  = $SubscriptionName
                resourceGroup     = $ResourceGroup
                location          = $Location
                provisioningState = $ProvisioningState
            }
        }
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }

        $script:capturedStatus       = $null
        $script:capturedResult       = $null
        $script:capturedCustomStatus = $null

        Mock Add-ZtTestResultDetail {
            param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
            $script:capturedStatus       = $Status
            $script:capturedResult       = $Result
            $script:capturedCustomStatus = $CustomStatus
            "## $Title — $CustomStatus`n`n$Result`n" | Add-Content $script:outputFile
        }
    }

    # ── Pass scenarios ───────────────────────────────────────────────────────

    Context 'When Q4 returns two Succeeded capacities (real tenant data from @astaykov)' {
        It 'Should pass and render the capacity table with both entries' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                @(
                    New-MockCapacity -Name 'tralala-test'   -ResourceGroup 'secopilot-rg'    -SubscriptionId '11111111-fc82-4634-aa52-62dd91b3ebaa' -ProvisioningState 'Succeeded'
                    New-MockCapacity -Name 'real-scu-zero'  -ResourceGroup 'secopilot-secco' -SubscriptionId '11111111-fc82-4634-aa52-62dd91b3ebaa' -ProvisioningState 'Succeeded'
                )
            }

            Test-Assessment-41219

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly
            $script:capturedStatus       | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult       | Should -Match 'prerequisites for AI-assisted identity and device review are in place'
            $script:capturedResult       | Should -Match 'tralala-test'
            $script:capturedResult       | Should -Match 'real-scu-zero'
            $script:capturedResult       | Should -Match '✅ Succeeded'
            $script:capturedResult       | Should -Not -Match '%TestResult%'
        }
    }

    Context 'When Q4 returns one Succeeded and one Provisioning capacity' {
        It 'Should pass (any Succeeded is enough) and show both rows' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                @(
                    New-MockCapacity -Name 'ready-cap'   -ProvisioningState 'Succeeded'
                    New-MockCapacity -Name 'pending-cap' -ProvisioningState 'Provisioning'
                )
            }

            Test-Assessment-41219

            $script:capturedStatus       | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult       | Should -Match '✅ Succeeded'
            $script:capturedResult       | Should -Match '⚠️ Provisioning'
        }
    }

    # ── Investigate scenarios ─────────────────────────────────────────────────

    Context 'When Q4 returns zero capacities' {
        It 'Should return Investigate with E5/E7 inclusion-path message' {
            Mock Invoke-ZtAzureResourceGraphRequest { @() }

            Test-Assessment-41219

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match 'E5/E7'
            $script:capturedResult       | Should -Match 'Security Copilot portal'
        }
    }

    Context 'When Q4 returns capacities but none have provisioningState = Succeeded' {
        It 'Should return Investigate and render the non-ready capacities' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                @(
                    New-MockCapacity -Name 'failed-cap'  -ProvisioningState 'Failed'
                    New-MockCapacity -Name 'deleted-cap' -ProvisioningState 'Deleting'
                )
            }

            Test-Assessment-41219

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match '⚠️ Failed'
            $script:capturedResult       | Should -Match '⚠️ Deleting'
        }
    }

    Context 'When Q4 returns a capacity with missing provisioningState' {
        It 'Should return Investigate and show Unknown state' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                New-MockCapacity -Name 'unknown-cap' -ProvisioningState ''
            }

            Test-Assessment-41219

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match '⚠️ Unknown'
        }
    }

    Context 'When Q4 ARG returns HTTP 403' {
        It 'Should return Investigate with Azure Reader guidance' {
            Mock Invoke-ZtAzureResourceGraphRequest { throw 'Azure REST request failed with status 403: Forbidden' }

            { Test-Assessment-41219 } | Should -Not -Throw

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match 'HTTP 403'
            $script:capturedResult       | Should -Match 'Azure Reader'
        }
    }

    Context 'When Q4 ARG returns HTTP 401' {
        It 'Should return Investigate with auth error message' {
            Mock Invoke-ZtAzureResourceGraphRequest { throw 'Azure REST request failed with status 401: Unauthorized' }

            { Test-Assessment-41219 } | Should -Not -Throw

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match 'HTTP 401'
        }
    }

    Context 'When Q4 ARG returns a transient 5xx error' {
        It 'Should return Investigate with the raw error message' {
            Mock Invoke-ZtAzureResourceGraphRequest { throw 'Azure REST request failed with status 503: Service Unavailable' }

            { Test-Assessment-41219 } | Should -Not -Throw

            $script:capturedStatus       | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult       | Should -Match 'Service Unavailable'
        }
    }

    Context 'When Q4 ARG returns a capacity without subscriptionName (no join match)' {
        It 'Should fall back to subscriptionId in the table' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                New-MockCapacity -Name 'no-sub-name' -SubscriptionId '99999999-0000-0000-0000-000000000001' -SubscriptionName ''
            }

            Test-Assessment-41219

            $script:capturedStatus | Should -BeTrue
            $script:capturedResult | Should -Match '99999999-0000-0000-0000-000000000001'
        }
    }
}
