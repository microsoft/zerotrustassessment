import path from "path"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"
import { viteSingleFile } from "vite-plugin-singlefile"
import { reportDataPlaceholder } from "./vite-plugin-report-data"

export default defineConfig(() => {
  return {
    plugins: [react(), reportDataPlaceholder(), viteSingleFile()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    define: {
      global: {
        basename: '',
      },
    },
  }
})
