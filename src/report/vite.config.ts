import path from "path"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"
import { viteSingleFile } from "vite-plugin-singlefile"

export default defineConfig(({ command }) => {
  const isProd = command === 'build'

  return {
    plugins: [react(), viteSingleFile()],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    esbuild: {
      minifyIdentifiers: false,
      keepNames: true,
    },
    define: {
      global: {
        basename: '',
      },
    },
  }
})
