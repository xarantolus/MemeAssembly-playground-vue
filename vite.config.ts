import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  build: {
    target: 'es2020',
  },
  optimizeDeps: {
    include: [
      `monaco-editor/esm/vs/editor/editor.worker`,
    ],
    esbuildOptions: {
      target: 'es2020',
    },
  }
})
