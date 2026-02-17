<#
 .SYNOPSIS
    Queries Azure Resource Graph and returns results with automatic pagination.

 .DESCRIPTION
    Thin wrapper over Invoke-ZtAzureRequest that handles Azure Resource Graph's
    POST-based query endpoint and its $skipToken pagination model.

    Sends the KQL query to the ARG REST API, follows $skipToken across pages,
    and returns a flat array of result objects.

    Uses Invoke-ZtAzureRequest internally, so sovereign-cloud resolution (-Path)
    and error handling (throw on non-2xx) are inherited automatically.

 .PARAMETER Query
    The Kusto Query Language (KQL) query to execute against Azure Resource Graph.

 .PARAMETER SubscriptionId
    Optional array of subscription IDs to scope the query to.
    When omitted, the query runs at tenant scope (all accessible subscriptions).

 .PARAMETER ApiVersion
    The API version for the Resource Graph endpoint.
    Defaults to '2024-04-01'.

 .PARAMETER MaxPages
    Maximum number of pages to retrieve during pagination.
    Defaults to 100. Valid range is 1-1000.

 .EXAMPLE
    Invoke-ZtAzureResourceGraphRequest -Query "Resources | summarize count() by type"

    Query all accessible resources at tenant scope, grouped by type.

 .EXAMPLE
    $subs = (Get-AzSubscription).Id
    Invoke-ZtAzureResourceGraphRequest -Query "Resources | where type =~ 'microsoft.compute/virtualmachines'" -SubscriptionId $subs

    Query virtual machines scoped to specific subscriptions.
#>
function Invoke-ZtAzureResourceGraphRequest {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Query,

		[Parameter()]
		[string[]]
		$SubscriptionId,

		[Parameter()]
		[string]
		$ApiVersion = '2024-04-01',

		[Parameter()]
		[ValidateRange(1, 1000)]
		[int]
		$MaxPages = 100
	)

	process {
		$argPath = "/providers/Microsoft.ResourceGraph/resources?api-version=$ApiVersion"
		$pageSize = 1000
		$pageCount = 0
		$skipToken = $null
		$allResults = [System.Collections.Generic.List[psobject]]::new()

		do {
			#region Build request body
			$requestBody = @{
				query   = $Query
				options = @{
					resultFormat = 'objectArray'
					'$top'       = $pageSize
				}
			}

			if ($SubscriptionId) {
				$requestBody['subscriptions'] = @($SubscriptionId)
			}

			# $skipToken is the sole pagination cursor returned by ARG.
			# When present it supersedes $skip, so we only send $skip = 0
			# on the very first request (implicitly, by omission on subsequent pages).
			if ($skipToken) {
				$requestBody.options['$skipToken'] = $skipToken
			}

			$bodyJson = $requestBody | ConvertTo-Json -Depth 10
			#endregion Build request body

			#region Execute request
			# -DisablePaging: ARG uses $skipToken in the request body for pagination (handled by this loop),
			# not the standard ARM nextLink pattern that Invoke-ZtAzureRequest's -Paginate follows.
			$content = Invoke-ZtAzureRequest -Path $argPath -Method POST -Payload $bodyJson -DisablePaging

			# Accumulate results
			if ($content.data) {
				if ($content.data -is [array]) {
					$allResults.AddRange([psobject[]]$content.data)
				}
				else {
					$allResults.Add($content.data)
				}
			}
			#endregion Execute request

			#region Pagination
			$skipToken = $content.'$skipToken'
			$pageCount++
			if ($pageCount -ge $MaxPages) {
				Write-PSFMessage "Azure Resource Graph pagination exceeded $MaxPages pages ($($allResults.Count) results so far). Stopping." -Level Warning
				break
			}
			#endregion Pagination

		} while ($skipToken)

		$allResults.ToArray()
	}
}
