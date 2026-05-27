Describe "Release workflow" {
    BeforeAll {
        $workflowPath = Join-Path (Split-Path -Parent $global:__testData.TestRoot) '.github/workflows/release.yml'
        $workflowContent = Get-Content -Path $workflowPath -Raw
    }

    It "should not run both tag push and published release events for the same tag" {
        $workflowContent | Should -Match "(?m)^\s*push:\s*$"
        $workflowContent | Should -Not -Match "(?m)^\s*release:\s*$"
    }

    It "should target the triggering repository for GitHub CLI release commands" {
        $workflowContent | Should -Match "(?m)^\s*GH_REPO:\s*\$\{\{ github\.repository \}\}\s*$"
    }
}
