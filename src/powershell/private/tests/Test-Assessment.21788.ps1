<#
.SYNOPSIS

#>

function Test-Assessment-21788 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Global Administrators don't have standing elevated access to all Azure subscriptions in the tenant"
    Write-ZtProgress -Activity $activity -Status "Getting role assignments"

    $roleAssignments = Invoke-AzRestMethod -Method GET -Uri 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignments?$filter=atScope()&api-version=2022-04-01'

    $results = ($roleAssignments.Content | ConvertFrom-Json).value.properties | Where-Object {
        $_.roleDefinitionId -eq '/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
    }

    $testResultMarkdown = ""

    if ($results.Count -gt 0) {
        $passed = $false
        $testResultMarkdown += "Standing access to Root Management group was found.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown += "No standing access to Azure Root Management Group."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Entra ID objects with standing access to Root Management group"
    $tableRows = ""

    if ($results.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Entra ID Object | Object ID | Principal type |
| :-------------- | :-------- | :------------- |
{1}

'@

        foreach ($result in $results) {
            $object = Invoke-ZtGraphRequest -RelativeUri "directoryObjects/$($result.principalId)" -ApiVersion 'v1.0'
            if ($result.principalType -eq 'User') {
                $displayName = $object.userPrincipalName
            }
            else {
                $displayName = $object.displayName
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
        TestId             = '21788'
        Title              = "Global Administrators don't have standing elevated access to all Azure subscriptions in the tenant"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
