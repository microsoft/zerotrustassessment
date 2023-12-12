function CreateMarkdown($list, $folder)
{
    foreach($item in $list)
    {
        $id = $item.id
        $fileName = $item.id.Substring(0, 7) + ".md"

        # Find second occurence of '_' and get all the characters before it
        $fileName = $id.Substring(0, $id.IndexOf("_", $id.IndexOf("_") + 1)) + ".md"

        $filePath = Join-Path -Path $folder -ChildPath $fileName

        $index = $id.Substring($id.IndexOf("_") + 1, 3)

        $title = $item.title.replace("`n", "")
        $content = "# $($index): $($title)`n`n"
        $content += "## Overview`n`n`n`n"
        $content += "## Reference`n`n* `n"

        $content | Out-File -FilePath $filePath

    }
}

$template = Get-Content -Raw -Path ./template.json | ConvertFrom-Json

CreateMarkdown $template.identity ../src/react/docs/workshop-guidance/identity
CreateMarkdown $template.device ../src/react/docs/workshop-guidance/devices
CreateMarkdown $template.devSecOps ../src/react/docs/workshop-guidance/devsecops