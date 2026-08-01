import path from "path"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"
import { viteSingleFile } from "vite-plugin-singlefile"

export default defineConfig({
  plugins: [react(), viteSingleFile()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src-curent"),
    },
  },
  esbuild: {
    minifyIdentifiers: false,
    keepNames: true,
  },
  define: {
    global: {
      basename: "",
    },
  },
  build: {
    rollupOptions: {
      input: path.resolve(__dirname, "index.current.html"),
    },
  },
})
