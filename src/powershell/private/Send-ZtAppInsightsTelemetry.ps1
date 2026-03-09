function Send-ZtAppInsightsTelemetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $EventName,

        [Parameter(Mandatory = $false)]
        [hashtable]
        $Properties
    )

    try {
        # Application Insights Instrumentation Key
        $instrumentationKey = "9ef9a343-9c69-4468-a1a0-e1786a6d9f89"

        # Set up the telemetry data
        $timestamp = [System.DateTime]::UtcNow.ToString("o")

        # Create the JSON payload
        $body = @{
            name = "AppEvents"
            time = $timestamp
            iKey = $instrumentationKey
            tags = @{
                #"ai.cloud.roleInstance" = $hostname
            }
            data = @{
                baseType = "EventData"
                baseData = @{
                    ver = 2
                    name = $EventName
                    properties = if ($Properties) { $Properties } else { @{} }
                }
            }
        }

        # Convert to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10 -Compress

        # Create a memory stream for GZIP compression
        $ms = New-Object System.IO.MemoryStream
        $gzip = New-Object System.IO.Compression.GZipStream $ms, ([System.IO.Compression.CompressionMode]::Compress)
        $writer = New-Object System.IO.StreamWriter $gzip
        $writer.Write($jsonBody)
        $writer.Flush()
        $writer.Close()
        $gzip.Close()

        # Get the compressed bytes
        $compressedBytes = $ms.ToArray()
        $ms.Close()

        # Create HTTP request
        $uri = "https://dc.services.visualstudio.com/v2/track"
        $headers = @{
            "Content-Type" = "application/x-json-stream"
            "Content-Encoding" = "gzip"
        }

        # Send request without waiting for response
        $null = Invoke-WebRequest -Uri $uri -Method Post -Body $compressedBytes -Headers $headers -UseBasicParsing -ErrorAction SilentlyContinue

        Write-PSFMessage -Level Debug -Message "Telemetry event '$EventName' sent successfully."
    }
    catch {
        # Silently handle any errors to ensure the main functionality isn't affected
        Write-PSFMessage -Level Debug -Message "Telemetry event failed to send: $_"
    }
}
