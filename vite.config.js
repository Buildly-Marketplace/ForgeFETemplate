import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Port 8000 keeps every mode consistent: ops/startup.sh, the nginx image, and
// the Robot suites all default to it.
export default defineConfig({
  plugins: [react()],
  server: {
    port: Number(process.env.PORT) || 8000,
    host: '0.0.0.0',
  },
  preview: {
    port: Number(process.env.PORT) || 8000,
    host: '0.0.0.0',
  },
  build: {
    outDir: 'dist',
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './tests/unit/setup.js',
    include: ['tests/unit/**/*.test.{js,jsx}'],
  },
});
