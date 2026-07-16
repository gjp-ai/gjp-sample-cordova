import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    base: './',
    root: 'web',
    publicDir: 'public',
    plugins: [react()],
    build: {
        emptyOutDir: true,
        outDir: '../www'
    }
});
