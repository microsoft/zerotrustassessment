function Test-DomainResolves {
    param (
        [Parameter(Mandatory)]
        [string]$Domain,
        [int]$TimeoutSeconds = 10
    )

    try {
        # Create a script block for DNS resolution
        $resolveScriptBlock = {
            param($domainToResolve)

            try {
                # Try Resolve-DnsName first (available in PowerShell 7+)
                $null = Resolve-DnsName -Name $domainToResolve -ErrorAction Stop
                return $true
            }
            catch {
                try {
                    # Fallback to nslookup if Resolve-DnsName isn't available
                    $nslookupResult = nslookup $domainToResolve 2>&1
                    return ($LASTEXITCODE -eq 0)
                }
                catch {
                    # If both methods fail, return false
                    return $false
                }
            }
        }

        # Run the resolution with a timeout
        $job = Start-Job -ScriptBlock $resolveScriptBlock -ArgumentList $Domain

        # Wait for the job to complete or timeout
        $completed = Wait-Job -Job $job -Timeout $TimeoutSeconds

        # If the job completed successfully, get the result
        if ($completed -and $completed.State -eq 'Completed') {
            $result = Receive-Job -Job $job
            Remove-Job -Job $job -Force
            return $result
        }
        else {
            # Job timed out or failed
            if ($job.State -ne 'Completed') {
                Stop-Job -Job $job
            }
            Remove-Job -Job $job -Force
            Write-PSFMessage -Level Verbose -Message "DNS resolution for $Domain timed out after $TimeoutSeconds seconds"
            return $false
        }
    }
    catch {
        Write-PSFMessage -Level Warning -Message "Error resolving domain $Domain $_"
        return $false
    }
}
