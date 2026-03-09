[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TestsPath = "c:\src\zerotrustassessment\src\powershell\tests"
)

$allowedServices = @('Graph','Azure','AipService','ExchangeOnline','SecurityCompliance','SharePointOnline')

function Get-RequiredServices {
    param([string]$Content)

    $services = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    # Graph
    if ($Content -match '\b(Get|Invoke|Connect|Disconnect)-Mg\w+\b' -or
        $Content -match '\bInvoke-ZtGraphRequest\b' -or
        $Content -match '\bGet-MgContext\b' -or
        $Content -match '\bMicrosoft\s+Graph\b') {
        $null = $services.Add('Graph')
    }

    # Azure (Az.* cmdlets)
    if ($Content -match '\b(Get|Set|New|Remove|Connect|Disconnect|Invoke|Start|Stop)-Az\w+\b') {
        $null = $services.Add('Azure')
    }

    # AIP
    if ($Content -match '\b(Get|Set|New|Remove|Connect|Disconnect)-Aip\w+\b') {
        $null = $services.Add('AipService')
    }

    # Exchange Online
    if ($Content -match '\b(Get|Set|New|Remove|Connect|Disconnect)-(EXO\w+|Exo\w+|ExchangeOnline)\b' -or
        $Content -match '\bConnect-ExchangeOnline\b') {
        $null = $services.Add('ExchangeOnline')
    }

    # Security & Compliance
    if ($Content -match '\bConnect-IPPSSession\b' -or
        $Content -match '\b(Get|Set|New|Remove)-(Label|Dlp\w+|Retention\w+|Case\w+|Compliance\w+)\b') {
        $null = $services.Add('SecurityCompliance')
    }

    # SharePoint Online
    if ($Content -match '\b(Get|Set|New|Remove|Connect|Disconnect)-SPO\w+\b' -or
        $Content -match '\bSharePoint\s+Online\b') {
        $null = $services.Add('SharePointOnline')
    }

    # Safe default
    if ($services.Count -eq 0) {
        $null = $services.Add('Graph')
    }

    # Keep only allowed values and stable order
    $ordered = foreach ($s in $allowedServices) {
        if ($services.Contains($s)) { $s }
    }

    return [string[]]$ordered
}

$files = Get-ChildItem -Path $TestsPath -Filter '*.ps1' -File -Recurse
$changed = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $services = Get-RequiredServices -Content $content
    $serviceLiteral = "Service = ('" + ($services -join "','") + "'),"

    # Match [ZtTest( ... )] block
    $ztTestRegex = '\[ZtTest\((?<body>[\s\S]*?)\)\]'
    $m = [regex]::Match($content, $ztTestRegex)
    if (-not $m.Success) { continue }

    $body = $m.Groups['body'].Value
    $newBody = $body

    if ($body -match '(?m)^\s*Service\s*=\s*\([^\)]*\)\s*,?\s*$') {
        $newBody = [regex]::Replace(
            $body,
            '(?m)^\s*Service\s*=\s*\([^\)]*\)\s*,?\s*$',
            ('        ' + $serviceLiteral)
        )
    }
    else {
        # Insert before closing by appending
        $newBody = $body.TrimEnd() + "`r`n        $serviceLiteral`r`n    "
    }

    $newAttr = "[ZtTest($newBody)]"
    $newContent = $content.Substring(0, $m.Index) + $newAttr + $content.Substring($m.Index + $m.Length)

    if ($newContent -ne $content) {
        if ($PSCmdlet.ShouldProcess($file.FullName, "Update ZtTest Service")) {
            Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
            $changed++
            Write-Host "Updated: $($file.FullName)" -ForegroundColor Green
        }
    }
}

Write-Host "Done. Updated $changed file(s)." -ForegroundColor Cyan
