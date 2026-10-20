import { readFileSync } from "node:fs"
import path from "node:path"
import type { Plugin } from "vite"

// PowerShell (Get-HtmlReport) replaces everything between these two markers with the real
// assessment payload, so the block must reach the built HTML byte-for-byte. Injecting it via
// transformIndexHtml keeps it out of the JS bundle, where the Oxc minifier would rename
// `reportData` and rewrite the double quotes to backticks.
export const reportDataStartMarker = "reportData={"
export const reportDataEndMarker = 'EndOfJson:"EndOfJson"}'

export function reportDataPlaceholder(): Plugin {
  return {
    name: "zt:report-data-placeholder",
    transformIndexHtml() {
      const demoPath = path.resolve(__dirname, "demo-report-data.json")
      const demoData = JSON.parse(readFileSync(demoPath, "utf8")) as Record<string, unknown>
      delete demoData.EndOfJson

      // EndOfJson is appended unquoted so the closing marker matches what Get-HtmlReport searches for.
      const body = JSON.stringify(demoData).slice(1, -1)

      return [
        {
          tag: "script",
          children: `window.${reportDataStartMarker}${body},${reportDataEndMarker}`,
          injectTo: "head-prepend",
        },
      ]
    },
  }
}
