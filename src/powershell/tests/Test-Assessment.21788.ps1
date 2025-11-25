<#
.SYNOPSIS

#>

function Test-Assessment-21788 {
    [ZtTest(
        Category = 'Privileged access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Free'),
        Pillar = 'Identity',
        RiskLevel = 'High',
        SfiPillar = 'Protect engineering systems',
        TenantType = ('Workforce'),
        TestId = 21788,
        Title = 'Global Administrators don''t have standing access to Azure subscriptions',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Global Administrators don't have standing elevated access to all Azure subscriptions in the tenant"
    Write-ZtProgress -Activity $activity -Status "Checking Azure connection"

    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch [Management.Automation.CommandNotFoundException] {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    $passed = $false

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }
    else {
        Write-ZtProgress -Activity $activity -Status "Getting role assignments"

        $resourceManagementUrl = (Get-AzContext).Environment.ResourceManagerUrl
        $azRoleAssignmentUri = $resourceManagementUrl + 'providers/Microsoft.Authorization/roleAssignments?$filter=atScope()&api-version=2022-04-01'

        try {
            $roleAssignments = Invoke-AzRestMethod -Method GET -Uri $azRoleAssignmentUri -ErrorAction Stop
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like "*403*" -or $_.Exception.Message -like "*Forbidden*") {
                Write-PSFMessage "The signed in user does not have required access to the Azure subscription." -Level Verbose
                Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
                return
            }
            else {
                throw
            }
        }

        $results = ($roleAssignments.Content | ConvertFrom-Json).value.properties | Where-Object {
            $_.roleDefinitionId -eq '/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
        }

        $testResultMarkdown = ""

        if ($results -and $results.Count -eq 0) {
            $passed = $true
            $testResultMarkdown += "No standing access to Azure Root Management Group."
        }
        else {
            $passed = $false
            $testResultMarkdown += "Standing access to Root Management group was found.`n`n%TestResult%"
        }

        # Build the detailed sections of the markdown

        # Define variables to insert into the format string
        $reportTitle = "Entra ID objects with standing access to Root Management group"
        $tableRows = ""

        if ($results -and $results.Count -gt 0) {
            # Create a here-string with format placeholders {0}, {1}, etc.
            $formatTemplate = @'

## {0}


| Entra ID Object | Object ID | Principal type |
| :-------------- | :-------- | :------------- |
{1}

'@

            foreach ($result in $results) {
                try {
                    $object = Invoke-ZtGraphRequest -RelativeUri "directoryObjects/$($result.principalId)" -ApiVersion 'v1.0'
                    if ($result.principalType -eq 'User') {
                        $displayName = $object.userPrincipalName
                    }
                    else {
                        $displayName = $object.displayName
                    }

                }
                catch {
                    Write-PSFMessage "Failed to get object for principalId $($result.principalId): $_"
                    $displayName = $result.principalId
                }

                $tableRows += @"
| $displayName | $($object.id) | $($result.principalType) |`n
"@
            }

            # Format the template by replacing placeholders with values
            $mdInfo = $formatTemplate -f $reportTitle, $tableRows
        }

        # Replace the placeholder with the detailed information
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

        $params = @{
            TestId = '21788'
            Title  = "Global Administrators don't have standing elevated access to all Azure subscriptions in the tenant"
            Status = $passed
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
    }
}
