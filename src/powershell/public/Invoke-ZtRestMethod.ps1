<#
 .SYNOPSIS
    Proxy function for Invoke-AzRestMethod that adds caching, automatic pagination,
    and OData convenience parameters.

 .DESCRIPTION
    This is a proxy function wrapping Invoke-AzRestMethod. It inherits all of
    Invoke-AzRestMethod's parameter sets (ByPath, ByURI, ByParameters) so it works
    identically across all Azure environments (Global, USGov, China) without
    hardcoding any hostnames.

    Additional features over Invoke-AzRestMethod:
    * OData query parameters: -Select, -Filter, -Top
    * Additional query parameters via -QueryParameters hashtable
    * Session-scoped caching of GET results
    * Automatic pagination enabled by default for GET requests
    * Throws on non-2xx errors (consistent with Invoke-ZtGraphRequest)
    * Return full PSHttpResponse with -FullResponse for StatusCode inspection
    * Automatic unwrapping of .value array from responses

 .EXAMPLE
    Invoke-ZtRestMethod -Path "/subscriptions?api-version=2022-01-01"

    Get all subscriptions (api-version in the path, like Invoke-AzRestMethod).

 .EXAMPLE
    Invoke-ZtRestMethod -Path "/subscriptions/$subscriptionId/providers/Microsoft.Compute/virtualMachines?api-version=2024-03-01" -Select "name,location"

    Get all virtual machines with selected properties.

 .EXAMPLE
    $response = Invoke-ZtRestMethod -Path "/providers/Microsoft.Authorization/roleAssignments?api-version=2022-04-01" -Filter "atScope()" -FullResponse
    if ($response.StatusCode -eq 403) {
        # Handle forbidden access
    }

    Get role assignments at root scope with full response to check status code.

 .EXAMPLE
    $body = @{ query = "Resources | where type =~ 'microsoft.compute/virtualmachines'" } | ConvertTo-Json
    Invoke-ZtRestMethod -Path "/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01" -Method POST -Payload $body

    Query Azure Resource Graph using POST with pagination (follows $skipToken automatically).

 .EXAMPLE
    Invoke-ZtRestMethod -Uri "https://management.usgovcloudapi.net/subscriptions?api-version=2022-01-01"

    Use -Uri for full URL (sovereign cloud). All Invoke-AzRestMethod parameters are supported.

#>
function Invoke-ZtRestMethod {
	[CmdletBinding(DefaultParameterSetName = 'ByPath', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
	param(
		#region Invoke-AzRestMethod: ByPath parameter set
		[Parameter(ParameterSetName = 'ByPath', Mandatory, HelpMessage = 'Path of target resource URL. Hostname of Resource Manager should not be added.')]
		[ValidateNotNullOrEmpty()]
		[string]
		${Path},
		#endregion

		#region Invoke-AzRestMethod: ByURI parameter set
		[Parameter(ParameterSetName = 'ByURI', Mandatory, Position = 1, HelpMessage = 'Uniform Resource Identifier of the Azure resources.')]
		[ValidateNotNullOrEmpty()]
		[uri]
		${Uri},

		[Parameter(ParameterSetName = 'ByURI', HelpMessage = 'Identifier URI specified by the REST API you are calling.')]
		[ValidateNotNullOrEmpty()]
		[uri]
		${ResourceId},
		#endregion

		#region Invoke-AzRestMethod: ByParameters parameter set
		[Parameter(ParameterSetName = 'ByParameters', HelpMessage = 'Target Subscription Id')]
		[ValidateNotNullOrEmpty()]
		[string]
		${SubscriptionId},

		[Parameter(ParameterSetName = 'ByParameters', HelpMessage = 'Target Resource Group Name')]
		[ValidateNotNullOrEmpty()]
		[string]
		${ResourceGroupName},

		[Parameter(ParameterSetName = 'ByParameters', HelpMessage = 'Target Resource Provider Name')]
		[ValidateNotNullOrEmpty()]
		[string]
		${ResourceProviderName},

		[Parameter(ParameterSetName = 'ByParameters', HelpMessage = 'List of Target Resource Type')]
		[ValidateNotNullOrEmpty()]
		[string[]]
		${ResourceType},

		[Parameter(ParameterSetName = 'ByParameters', HelpMessage = 'list of Target Resource Name')]
		[ValidateNotNullOrEmpty()]
		[string[]]
		${Name},

		[Parameter(ParameterSetName = 'ByParameters', Mandatory, HelpMessage = 'Api Version')]
		[ValidateNotNullOrEmpty()]
		[string]
		${ApiVersion},
		#endregion

		#region Invoke-AzRestMethod: Common parameters
		[Parameter(HelpMessage = 'Specifies the method used for the web request. Defaults to GET.')]
		[ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
		[ValidateNotNullOrEmpty()]
		[string]
		${Method},

		[Parameter(HelpMessage = 'JSON format payload')]
		[ValidateNotNullOrEmpty()]
		[string]
		${Payload},

		[Parameter(HelpMessage = 'Run cmdlet in the background')]
		[switch]
		${AsJob},

		[Parameter(HelpMessage = 'The credentials, account, tenant, and subscription used for communication with Azure.')]
		[Alias('AzContext', 'AzureRmContext', 'AzureCredential')]
		[Microsoft.Azure.Commands.Common.Authentication.Abstractions.Core.IAzureContextContainer]
		${DefaultProfile},
		#endregion

		#region ZtRestMethod: OData convenience parameters
		# Filters properties (columns). Adds $select query parameter.
		[Parameter()]
		[string[]]
		$Select,

		# Filters results (rows). Adds $filter query parameter.
		[Parameter()]
		[string]
		$Filter,

		# The number of items to be included in the result. Adds $top query parameter.
		[Parameter()]
		[ValidateRange(1, [int]::MaxValue)]
		[int]
		$Top,

		# Additional query parameters to append to the request URL.
		[Parameter()]
		[hashtable]
		$QueryParameters,
		#endregion

		#region ZtRestMethod: Pagination and caching control
		# Only return first page of results. By default, -Paginate is enabled.
		[Parameter()]
		[switch]
		$DisablePaging,

		# Specify if this request should skip cache and go directly to Azure.
		[Parameter()]
		[switch]
		$DisableCache,

		# Return the full PSHttpResponse object instead of just the parsed content.
		# When specified, does not throw on non-2xx status codes.
		[Parameter()]
		[switch]
		$FullResponse
		#endregion
	)

	process {
		# Determine effective method (default to GET)
		$effectiveMethod = if ($Method) { $Method } else { 'GET' }

		#region Build Invoke-AzRestMethod parameters
		# Start with all bound parameters, then remove our custom ones
		$azParams = @{} + $PSBoundParameters

		# Remove ZtRestMethod-specific parameters (not recognized by Invoke-AzRestMethod)
		foreach ($customParam in @('Select', 'Filter', 'Top', 'QueryParameters', 'DisablePaging', 'DisableCache', 'FullResponse')) {
			$azParams.Remove($customParam) | Out-Null
		}

		# Inject OData and custom query parameters into -Path or -Uri
		$extraQueryParams = [ordered]@{}
		if ($Select) { $extraQueryParams['$select'] = $Select -join ',' }
		if ($Filter) { $extraQueryParams['$filter'] = $Filter }
		if ($Top) { $extraQueryParams['$top'] = $Top }
		if ($QueryParameters) {
			foreach ($key in $QueryParameters.Keys) {
				$extraQueryParams[$key] = $QueryParameters[$key]
			}
		}

		if ($extraQueryParams.Count -gt 0) {
			$extraQs = ConvertTo-QueryString $extraQueryParams

			if ($azParams.ContainsKey('Path')) {
				# -Path is a relative path (e.g., "/subscriptions?api-version=...")
				$pathStr = $azParams['Path']
				$fragment = ''
				if ($pathStr -match '(#.+)$') {
					$fragment = $matches[1]
					$pathStr = $pathStr.Substring(0, $pathStr.Length - $fragment.Length)
				}

				if ($pathStr -match '\?') {
					$azParams['Path'] = $pathStr + '&' + $extraQs + $fragment
				}
				else {
					$azParams['Path'] = $pathStr + '?' + $extraQs + $fragment
				}
			}
			elseif ($azParams.ContainsKey('Uri')) {
				# -Uri is a full URL
				# Use UriBuilder to safely handle query parameters and fragments
				$uriBuilder = [System.UriBuilder]::new($azParams['Uri'])
				if ([string]::IsNullOrWhiteSpace($uriBuilder.Query)) {
					$uriBuilder.Query = $extraQs
				}
				else {
					# UriBuilder.Query includes the leading '?'
					$uriBuilder.Query = $uriBuilder.Query.TrimStart('?') + '&' + $extraQs
				}
				$azParams['Uri'] = $uriBuilder.Uri
			}
			else {
				# ByParameters set: Invoke-AzRestMethod builds the URL internally,
				# so we cannot append OData/custom query parameters.
				Write-PSFMessage -Level Warning -Message "OData/query parameters (Select, Filter, Top, QueryParameters) are not supported with the ByParameters parameter set and will be ignored. Use -Path or -Uri instead."
			}
		}

		# Enable automatic pagination for GET requests only.
		# POST-based APIs (e.g. Resource Graph) handle paging via request body (skipToken in options).
		$isGet = $effectiveMethod -eq 'GET'
		if ($isGet -and -not $DisablePaging -and -not $AsJob) {
			$azParams['Paginate'] = $true
		}
		#endregion Build Invoke-AzRestMethod parameters

		#region Determine cache key
		if ($azParams.ContainsKey('Path')) {
			$cacheKey = $azParams['Path']
		}
		elseif ($azParams.ContainsKey('Uri')) {
			$cacheKey = $azParams['Uri'].ToString()
		}
		else {
			# ByParameters set: build a key from the components
			$cacheKey = '{0}/{1}/{2}/{3}/{4}' -f $SubscriptionId, $ResourceGroupName, $ResourceProviderName, ($ResourceType -join '/'), ($Name -join '/')
		}

		# Prefix with HTTP method for non-GET requests to prevent cache-key collisions
		# (e.g. a POST to the same URL as a previous GET should not share a cache entry).
		if ($effectiveMethod -ne 'GET') {
			$cacheKey = "$effectiveMethod`:$cacheKey"
		}
		#endregion Determine cache key

		#region Execute with caching
		$results = Invoke-ZtRestMethodCache -CacheKey $cacheKey -AzParams $azParams `
			-DisableCache:$DisableCache -FullResponse:$FullResponse
		#endregion Execute with caching

		#region Format Results
		if ($FullResponse) {
			return $results
		}

		# Unwrap .value array if present (standard ARM list response envelope)
		if ($results -and ($results.PSObject.Properties.Name -contains 'value')) {
			return $results.value
		}

		$results
		#endregion Format Results
	}
}
<#
.ForwardHelpTargetName Az.Accounts\Invoke-AzRestMethod
.ForwardHelpCategory Cmdlet
#>
