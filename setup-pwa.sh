#!/bin/bash

echo "==> 1) Install deps"
npm install

echo "==> 2) Vite config with PWA (will overwrite vite.config.ts if exists)"
cat > vite.config.ts <<'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
      manifest: {
        name: 'My PWA App',
        short_name: 'PWA',
        start_url: '.',
        display: 'standalone',
        background_color: '#ffffff',
        description: 'My Progressive Web App!',
        icons: [
          { src: 'pwa-192x192.png', sizes: '192x192', type: 'image/png' },
          { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png' },
          { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ]
      }
    })
  ]
})
EOF

echo "==> 3) Ensure public icon exists"
mkdir -p public
if [ ! -f public/pwa-192x192.png ]; then
  cp node_modules/vite-plugin-pwa/assets/logo.svg public/pwa-192x192.png 2>/dev/null || true
fi

echo "==> 4) Register service worker in src/main.(ts|js)"
MAIN_FILE=""
if [ -f src/main.ts ]; then
  MAIN_FILE="src/main.ts"
elif [ -f src/main.js ]; then
  MAIN_FILE="src/main.js"
fi

if [ -n "$MAIN_FILE" ]; then
  if grep -q 'App from' "$MAIN_FILE"; then
    sed -i '' '/App from/ a \
import { registerSW } from "virtual:pwa-register";\
registerSW({ immediate: true });\
' "$MAIN_FILE"
  else
    sed -i '' '1 i \
import { registerSW } from "virtual:pwa-register";\
registerSW({ immediate: true });\
' "$MAIN_FILE"
  fi
fi

echo "✅ Done! Your Vite PWA setup is complete."
