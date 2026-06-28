import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Builds the SPA into ../public (Lucee's webroot), next to the .cfm API.
// `base: './'` keeps asset URLs relative so it works under any host/path.
// `emptyOutDir: false` preserves the committed CFML (Application.cfc, api/, etc.).
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: '../public',
    emptyOutDir: false,
    assetsDir: 'assets',
  },
  server: {
    proxy: { '/api': 'http://localhost:8080' },
  },
})
