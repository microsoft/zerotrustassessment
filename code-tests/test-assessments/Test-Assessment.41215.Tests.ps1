Describe 'Test-Assessment-41215' {
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
                    [Object[]] $GraphObjects, [string]  $GraphObjectType,
                    [string]   $TestId,      [string]   $Title,     [string]   $SkippedBecause,
                    [string]   $UserImpact,  [string]   $Risk,      [string]   $ImplementationCost,
                    [string[]] $AppliesTo,   [string[]] $Tag,       [string]   $CustomStatus,
                    [string[]] $NotConnectedService,   [string]    $Pillar,    [string]   $Category
                )
            }
        }

        $classPath = Join-Path $srcRoot 'classes/ZtTest.ps1'
        if (-not ('ZtTest' -as [type])) {
            . $classPath
        }

        . (Join-Path $srcRoot 'tests/Test-Assessment.41215.ps1')

        function global:New-TestSecurityCopilotCapacity {
            param(
                [string] $Name = 'security-copilot-capacity',
                [AllowEmptyString()]
                [string] $ProvisioningState = 'Succeeded',
                [AllowEmptyString()]
                [string] $SubscriptionName = 'Production subscription',
                [string] $SubscriptionId = '00000000-0000-0000-0000-000000000001'
            )

            [PSCustomObject]@{
                id                = "/subscriptions/$SubscriptionId/resourceGroups/security-rg/providers/Microsoft.SecurityCopilot/capacities/$Name"
                name              = $Name
                location          = 'eastus'
                resourceGroup     = 'security-rg'
                subscriptionId    = $SubscriptionId
                subscriptionName  = $SubscriptionName
                provisioningState = $ProvisioningState
            }
        }
    }

    BeforeEach {
        Mock Write-PSFMessage {}
        Mock Write-ZtProgress {}
        Mock Get-SafeMarkdown { param($Text) return $Text }

        $script:capturedTestId = $null
        $script:capturedTitle = $null
        $script:capturedStatus = $null
        $script:capturedResult = $null
        $script:capturedCustomStatus = $null
        $script:capturedSkippedBecause = $null

        Mock Add-ZtTestResultDetail {
            param($TestId, $Title, $Status, $Result, $CustomStatus, $SkippedBecause)
            $script:capturedTestId = $TestId
            $script:capturedTitle = $Title
            $script:capturedStatus = $Status
            $script:capturedResult = $Result
            $script:capturedCustomStatus = $CustomStatus
            $script:capturedSkippedBecause = $SkippedBecause
        }
    }

    Context 'When Security Copilot capacity data is returned' {
        It 'Should query the expected resource type and pass for a succeeded capacity' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                New-TestSecurityCopilotCapacity
            }

            Test-Assessment-41215

            Should -Invoke Invoke-ZtAzureResourceGraphRequest -Times 1 -Exactly -ParameterFilter {
                $Query -match "type =~ 'microsoft.securitycopilot/capacities'" -and
                $Query -match 'provisioningState = tostring\(properties\.provisioningState\)'
            }
            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly
            $script:capturedTestId | Should -Be '41215'
            $script:capturedStatus | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'capacity is provisioned and ready'
            $script:capturedResult | Should -Match 'security-copilot-capacity'
            $script:capturedResult | Should -Match '✅ Succeeded'
            $script:capturedResult | Should -Not -Match '%TestResult%'
        }

        It 'Should pass when any capacity succeeded' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                @(
                    New-TestSecurityCopilotCapacity -Name 'capacity-provisioning' -ProvisioningState 'Provisioning'
                    New-TestSecurityCopilotCapacity -Name 'capacity-ready' -ProvisioningState 'Succeeded'
                )
            }

            Test-Assessment-41215

            $script:capturedStatus | Should -BeTrue
            $script:capturedCustomStatus | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'capacity-provisioning'
            $script:capturedResult | Should -Match '⚠️ Provisioning'
            $script:capturedResult | Should -Match 'capacity-ready'
            $script:capturedResult | Should -Match '✅ Succeeded'
        }

        It 'Should investigate when capacities exist but none succeeded' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                @(
                    New-TestSecurityCopilotCapacity -Name 'capacity-failed' -ProvisioningState 'Failed'
                    New-TestSecurityCopilotCapacity -Name 'capacity-deleting' -ProvisioningState 'Deleting'
                )
            }

            Test-Assessment-41215

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'No ready Security Copilot capacity'
            $script:capturedResult | Should -Match '⚠️ Failed'
            $script:capturedResult | Should -Match '⚠️ Deleting'
            $script:capturedResult | Should -Not -Match '%TestResult%'
        }

        It 'Should render the capacity table and fall back to the subscription ID' {
            Mock Invoke-ZtAzureResourceGraphRequest {
                New-TestSecurityCopilotCapacity `
                    -Name 'capacity-without-subscription-name' `
                    -ProvisioningState 'Provisioning' `
                    -SubscriptionName '' `
                    -SubscriptionId '00000000-0000-0000-0000-000000000002'
            }

            Test-Assessment-41215

            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedResult | Should -Match 'Security Copilot capacities'
            $script:capturedResult | Should -Match '\| Name \| Resource group \| Location \| Subscription \| Provisioning state \|'
            $script:capturedResult | Should -Match 'capacity-without-subscription-name'
            $script:capturedResult | Should -Match '00000000-0000-0000-0000-000000000002'
            $script:capturedResult | Should -Match '⚠️ Provisioning'
        }
    }

    Context 'When no Security Copilot capacity data is returned' {
        It 'Should investigate without rendering an empty capacity table' {
            Mock Invoke-ZtAzureResourceGraphRequest { @() }

            Test-Assessment-41215

            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly
            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'No ready Security Copilot capacity'
            $script:capturedResult | Should -Not -Match 'Security Copilot capacities'
            $script:capturedResult | Should -Not -Match '%TestResult%'
        }
    }

    Context 'When Azure Resource Graph returns an error' {
        It 'Should investigate and return exactly one result' {
            Mock Invoke-ZtAzureResourceGraphRequest { throw '503 Service Unavailable' }

            { Test-Assessment-41215 } | Should -Not -Throw

            Should -Invoke Invoke-ZtAzureResourceGraphRequest -Times 1 -Exactly
            Should -Invoke Add-ZtTestResultDetail -Times 1 -Exactly
            $script:capturedStatus | Should -BeFalse
            $script:capturedCustomStatus | Should -Be 'Investigate'
            $script:capturedSkippedBecause | Should -BeNullOrEmpty
            $script:capturedResult | Should -Match 'unexpected error'
            $script:capturedResult | Should -Match 're-run the assessment'
        }
    }
}
