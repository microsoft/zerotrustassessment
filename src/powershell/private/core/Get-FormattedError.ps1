function Get-FormattedError {
    <#
    .SYNOPSIS
        Formats PowerShell error messages in a user-friendly way.

    .DESCRIPTION
        Extracts relevant information from PowerShell error objects and formats them
        in a concise, user-friendly bullet-point format suitable for displaying in test results.
        Works with any error type including REST API errors, cmdlet errors, and general exceptions.

    .PARAMETER ErrorObject
        The error object from a catch block ($_)

    .PARAMETER IncludeDetails
        Include additional details like category, exception type, or request IDs when available

    .EXAMPLE
        try {
            $result = Invoke-ZtGraphRequest -RelativeUri 'someEndpoint' -ApiVersion beta
        }
        catch {
            $errorMsg = Get-FormattedError -ErrorObject $_ -IncludeDetails
            Write-Host "Error: $errorMsg"
        }

        Formats the error message from any PowerShell operation
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Management.Automation.ErrorRecord]
        $ErrorObject,

        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeDetails
    )

    try {
        $errorDetails = @()

        # Extract HTTP status code (for REST API errors)
        $httpStatus = $null
        if ($ErrorObject.Exception.Response.StatusCode) {
            $httpStatus = "$($ErrorObject.Exception.Response.StatusCode.value__) $($ErrorObject.Exception.Response.StatusCode)"
        }

        # Try to extract structured error details from JSON responses (Graph API, Azure, etc.)
        $errorMessage = $null
        $requestId = $null

        if ($ErrorObject.ErrorDetails.Message) {
            try {
                # ErrorDetails.Message contains HTTP headers followed by JSON body
                # Find the actual error JSON by looking for {"error" pattern
                $jsonContent = $null
                $startIndex = $ErrorObject.ErrorDetails.Message.IndexOf('{"error"')
                if ($startIndex -ge 0) {
                    # Find the matching closing brace for this JSON object
                    $lastIndex = $ErrorObject.ErrorDetails.Message.LastIndexOf('}')
                    if ($lastIndex -gt $startIndex) {
                        $jsonContent = $ErrorObject.ErrorDetails.Message.Substring($startIndex, $lastIndex - $startIndex + 1)
                    }
                }

                if ($jsonContent) {
                    $errorJson = $jsonContent | ConvertFrom-Json

                    # Try Graph API format
                    if ($errorJson.error) {
                        $errorMessage = $errorJson.error.message
                        if ($errorJson.error.innerError.'request-id') {
                            $requestId = $errorJson.error.innerError.'request-id'
                        }
                    }
                }
            }
            catch {
                # If JSON parsing fails, we'll fall back to Exception.Message later
                Write-PSFMessage "Unable to parse JSON from ErrorDetails.Message" -Level Debug
            }
        }

        # Fallback to Exception.Message if no detailed message found
        if (-not $errorMessage) {
            $errorMessage = $ErrorObject.Exception.Message
        }

        # Build formatted error details
        if ($httpStatus) {
            $errorDetails += "**HTTP Status:** $httpStatus"
        }

        if ($errorMessage) {
            $errorDetails += "**Message:** $errorMessage"
        }

        # Add additional details if requested
        if ($IncludeDetails) {
            if ($requestId) {
                $errorDetails += "**Request ID:** $requestId"
            }

            if ($ErrorObject.CategoryInfo.Category) {
                $errorDetails += "**Category:** $($ErrorObject.CategoryInfo.Category)"
            }

            if ($ErrorObject.Exception.GetType().Name -ne 'RuntimeException') {
                $errorDetails += "**Exception Type:** $($ErrorObject.Exception.GetType().Name)"
            }
        }

        # Format as bullet points
        if ($errorDetails.Count -gt 0) {
            $formattedError = ($errorDetails | ForEach-Object { "- $_" }) -join "`n"
        }
        else {
            # Fallback to raw exception message
            $formattedError = "- **Error:** $($ErrorObject.Exception.Message)"
        }

        return $formattedError
    }
    catch {
        # If formatting fails, return the original error message
        Write-PSFMessage "Error formatting error message: $_" -Level Debug
        return "- **Error:** $($ErrorObject.Exception.Message)"
    }
}
