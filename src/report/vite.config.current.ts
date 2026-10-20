import path from "path"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"
import { viteSingleFile } from "vite-plugin-singlefile"
import { reportDataPlaceholder } from "./vite-plugin-report-data"

export default defineConfig({
  plugins: [react(), reportDataPlaceholder(), viteSingleFile()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src-curent"),
    },
  },
  define: {
    global: {
      basename: "",
    },
  },
  build: {
    rolldownOptions: {
      input: path.resolve(__dirname, "index.current.html"),
    },
  },
})
