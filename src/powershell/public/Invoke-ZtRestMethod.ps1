<#
 .SYNOPSIS
   Helper module to run Azure REST Method request that supports paging and caching.

 .Description
    This wrapper for Invoke-AzRestMethod supports:
    * Filter, Select and Top as parameters
    * Automatic paging using Invoke-AzRestMethod's -Paginate
    * Caching of results for the duration of the session
    * Ability to skip cache and go directly to Azure
    * Throws on non-2xx errors (consistent with Invoke-ZtGraphRequest)
    * Return full response with -FullResponse for StatusCode inspection

 .Example

    Invoke-ZtRestMethod -Path "/subscriptions" -ApiVersion "2022-01-01"

    Get all subscriptions.

 .Example

    Invoke-ZtRestMethod -Path "/subscriptions/$subscriptionId/providers/Microsoft.Compute/virtualMachines" -ApiVersion "2024-03-01" -Select "name,location"

    Get all virtual machines with selected properties.

 .Example

    $response = Invoke-ZtRestMethod -Path "/providers/Microsoft.Authorization/roleAssignments" -ApiVersion "2022-04-01" -Filter "atScope()" -FullResponse
    if ($response.StatusCode -eq 403) {
        # Handle forbidden access
    }

    Get role assignments at root scope with full response to check status code.

#>
function Invoke-ZtRestMethod {
	[CmdletBinding()]
	param(
		# Path of target resource URL. Hostname of Resource Manager should not be added.
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string] $Path,
		# API Version (required for Azure REST API).
		[Parameter(Mandatory = $true)]
		[string] $ApiVersion,
		# Filters properties (columns).
		[Parameter(Mandatory = $false)]
		[string[]] $Select,
		# Filters results (rows).
		[Parameter(Mandatory = $false)]
		[string] $Filter,
		# The number of items to be included in the result.
		[Parameter(Mandatory = $false)]
		[string] $Top,
		# Additional query parameters.
		[Parameter(Mandatory = $false)]
		[hashtable] $QueryParameters,
		# Only return first page of results.
		[Parameter(Mandatory = $false)]
		[switch] $DisablePaging,
		# Specify if this request should skip cache and go directly to Azure.
		[Parameter(Mandatory = $false)]
		[switch] $DisableCache,
		# Return the full PSHttpResponse object instead of just the parsed content.
		# When specified, does not throw on non-2xx status codes.
		[Parameter(Mandatory = $false)]
		[switch] $FullResponse
	)

	process {
		#region Build Path with Query Parameters
		$uriBuilder = [System.UriBuilder]::new("https://management.azure.com$Path")

		# Parse existing query string if present
		if ($uriBuilder.Query) {
			$finalQueryParameters = ConvertFrom-QueryString -InputStrings $uriBuilder.Query -AsHashtable
		}
		else {
			$finalQueryParameters = @{}
		}

		# Add custom query parameters
		if ($QueryParameters) {
			foreach ($paramName in $QueryParameters.Keys) {
				$finalQueryParameters[$paramName] = $QueryParameters[$paramName]
			}
		}

		# Add standard OData parameters
		if ($Select) {
			$finalQueryParameters['$select'] = $Select -join ','
		}
		if ($Filter) {
			$finalQueryParameters['$filter'] = $Filter
		}
		if ($Top) {
			$finalQueryParameters['$top'] = $Top
		}

		# Add API version
		$finalQueryParameters['api-version'] = $ApiVersion

		# Build final query string
		$uriBuilder.Query = ConvertTo-QueryString $finalQueryParameters

		# Extract path with query for Invoke-AzRestMethod
		$finalPath = $uriBuilder.Path + $uriBuilder.Query
		#endregion Build Path with Query Parameters

		#region Execute Request
		$requestParams = @{
			Path          = $finalPath
			DisableCache  = $DisableCache
			DisablePaging = $DisablePaging
			FullResponse  = $FullResponse
		}

		$results = Invoke-ZtRestMethodCache @requestParams
		#endregion Execute Request

		#region Format Results
		if ($FullResponse) {
			# Return full response as-is
			return $results
		}

		# Return content, extracting value array if present
		if ($results -and ($results.PSObject.Properties.Name -contains 'value')) {
			return $results.value
		}

		$results
		#endregion Format Results
	}
}
