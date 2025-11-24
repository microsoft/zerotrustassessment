Describe "Connect-ZtAssessment parameter validation" {
    It "should export Connect-ZtAssessment function" {
        (Get-Command -Name Connect-ZtAssessment -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
    }

    It "should have ClientId parameter" {
        (Get-Command Connect-ZtAssessment).Parameters.ContainsKey('ClientId') | Should -BeTrue
    }

    It "should have ClientSecret parameter" {
        (Get-Command Connect-ZtAssessment).Parameters.ContainsKey('ClientSecret') | Should -BeTrue
    }
}

Describe "Connect-ZtAssessment client credential mapping" {
    BeforeAll {
        # Ensure a stub exists for Connect-MgGraph if Microsoft Graph module not installed locally
        if (-not (Get-Command -Name Connect-MgGraph -ErrorAction SilentlyContinue)) {
            function Connect-MgGraph { param() }
        }
    }

    It "should build app-only parameter set (PSCredential, no Scopes) when ClientId & ClientSecret provided with -NoConnect" {
        $params = Connect-ZtAssessment -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret "test-secret" -TenantId "contoso.onmicrosoft.com" -UseTokenCache -SkipAzureConnection -NoConnect

        $params | Should -Not -BeNullOrEmpty
        $params.Keys -contains 'ClientSecretCredential' | Should -BeTrue
        $params.ClientSecretCredential.GetType().Name | Should -Be 'PSCredential'
        $params.ClientSecretCredential.UserName | Should -Be "00000000-0000-0000-0000-000000000000"
        $params.ClientSecretCredential.GetNetworkCredential().Password | Should -Be "test-secret"
        $params.Keys -contains 'Scopes' | Should -BeFalse
    }
}
