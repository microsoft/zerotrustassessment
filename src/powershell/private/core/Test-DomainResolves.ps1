function Test-DomainResolves {
    param (
        [Parameter(Mandatory)]
        [string]$Domain
    )

    try {
        # Try Resolve-DnsName first (available in PowerShell 7+)
        $null = Resolve-DnsName -Name $Domain -ErrorAction Stop
        return $true
    }
    catch {
        # Fallback to nslookup if Resolve-DnsName isn't available
        $nslookupResult = nslookup $Domain > $null 2>&1
        return ($LASTEXITCODE -eq 0)
    }
}
