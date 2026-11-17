import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const { defineConfig } = require('@playwright/test');

export default defineConfig({
    testDir: fileURLToPath(new URL('../../code-tests/website', import.meta.url)),
    testMatch: '*.browser.spec.mjs',
    workers: 1,
    reporter: 'list',
    use: {
        baseURL: 'http://127.0.0.1:3000',
        browserName: 'chromium',
    },
});
