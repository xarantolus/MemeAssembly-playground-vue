import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import wasm from 'vite-plugin-wasm';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [wasm(), vue()],
  build: {
    target: 'es2020',
  },
  optimizeDeps: {
    exclude: ['ax-x86', 'assembly-script'],
    include: [
      `monaco-editor/esm/vs/editor/editor.worker`,
    ],
    esbuildOptions: {
      target: 'es2020',
    },
  }
})
