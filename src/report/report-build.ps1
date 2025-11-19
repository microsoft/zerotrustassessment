# Run this in the ./src/report directory to build the report, append the end marker and copy the report template to the powershell assets directory

Write-Host "Adding EndJson marker to report-data.ts"
$content = Get-Content ./src/config/report-data.ts
$last = $content[$content.Count-4]

if(!$last.EndsWith("|EndJson|`"")){
    $content[$content.Count-4] = $last.Substring(0, $last.Length - 1) + "|EndJson|`""
}

$content | Set-Content ./src/config/report-data.ts

Write-Host "Building report"
npm run build

Write-Host "Updating report template"
Copy-Item ./dist/index.html ../powershell/assets/ReportTemplate.html -Force
