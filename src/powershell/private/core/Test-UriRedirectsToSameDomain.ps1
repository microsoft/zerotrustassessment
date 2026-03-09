function Test-UriRedirectsToSameDomain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Url
    )

    $result = $true

    try {
        # Create a web request that doesn't automatically follow redirects
        $request = [System.Net.WebRequest]::Create($url)
        $request.Method = "GET"
        $request.AllowAutoRedirect = $false
        $request.Timeout = 10000  # 10 second timeout

        # Get the response
        $response = $request.GetResponse()

        # Check if there's a redirect (3xx status code)
        if ([int]$response.StatusCode -ge 300 -and [int]$response.StatusCode -lt 400) {
            # Get the redirect location
            $redirectUrl = $response.Headers["Location"]

            # If redirect URL exists and is an absolute URL
            if (-not [string]::IsNullOrEmpty($redirectUrl) -and
                ($redirectUrl.StartsWith("http:") -or $redirectUrl.StartsWith("https:"))) {

                # Parse the redirect URL
                $redirectUri = [System.Uri]$redirectUrl

                # Compare domains - if different, flag as failed
                # Ignore if redirectUr is login.microsoftonline.com
                if ($redirectUri.Host -ne $uri.Host -and
                    $redirectUri.Host -ne "login.microsoftonline.com") {
                    $result = $false # Redirects to another domain
                    Write-PSFMessage -Level Verbose -Message "$url → redirects to $($redirectUri.Host)"
                }
            }
        }

        # Close the response
        $response.Close()
    }
    catch {
        # Unable to check redirect, but we'll continue without marking as risky
        Write-PSFMessage -Level Verbose -Message "Unable to check redirect for $url $_"
    }

    return $result
}
