import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Dev server for the React UI. Runs as its own Gently app (live HMR), and proxies
// /api to the Lucee (CFML) app on :8080 in the same sandbox container.
export default defineConfig({
  plugins: [react()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    // The sandbox hostname is dynamic (<slug>.dev.gently.localhost) — accept it.
    allowedHosts: true,
    // The page is served over https://<slug>/ (TLS terminated by the laptop Caddy),
    // so the HMR WebSocket must go back over wss on the public 443 port — not the
    // internal 5173, which isn't reachable through the proxy.
    hmr: { protocol: 'wss', clientPort: 443 },
    proxy: {
      '/api': { target: 'http://127.0.0.1:8080', changeOrigin: false },
    },
  },
})
