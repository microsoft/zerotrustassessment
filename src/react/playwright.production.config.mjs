import config from './playwright.config.mjs';

const baseURL = 'http://127.0.0.1:3002';

export default {
    ...config,
    testMatch: ['ai-pillar.browser.spec.mjs', '*.production.spec.mjs'],
    use: {
        ...config.use,
        baseURL,
    },
    webServer: {
        command: 'npm run build -- --locale en && npm run serve -- --host 127.0.0.1 --port 3002 --no-open',
        url: `${baseURL}/zerotrustassessment/`,
        reuseExistingServer: false,
        timeout: 180_000,
    },
};
