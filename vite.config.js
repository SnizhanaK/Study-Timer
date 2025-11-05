import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig(({ mode }) => {
  const isProd = mode === 'production'
  const base = isProd ? '/study-timer/' : '/'
  const appPath = isProd ? '/study-timer/' : '/'

  return {
    base,
    plugins: [
      vue(),
      tailwindcss(),
      VitePWA({
        registerType: 'autoUpdate',
        devOptions: { enabled: true },
        includeAssets: ['favicon.ico', 'robots.txt', 'apple-touch-icon.png'],
        manifest: {
          id: appPath,
          name: 'Study Timer',
          short_name: 'StudyTimer',
          description: 'Track and boost your study productivity!',
          start_url: appPath,
          scope: appPath,
          display: 'standalone',
          background_color: '#ffffff',
          theme_color: '#6366f1',
          icons: [
            { src: '/pwa-192x192.png', sizes: '192x192', type: 'image/png' },
            { src: '/pwa-512x512.png', sizes: '512x512', type: 'image/png' },
            { src: '/pwa-192x192-maskable.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
            { src: '/pwa-512x512-maskable.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }
          ]
        }
      })
    ]
  }
})