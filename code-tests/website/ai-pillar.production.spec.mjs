import { createRequire } from 'node:module';
import { lessons, resumeStorageKey } from '../../src/react/src/components/AIPillarLearning/catalog.mjs';

const require = createRequire(new URL('../../src/react/package.json', import.meta.url));
const { test, expect } = require('@playwright/test');
const modulePath = '/zerotrustassessment/docs/videos/AIPillar/deep-dive-learning-module';

for (const id of ['registry-readiness', 'enterprise-compliance-integration', 'missing']) {
    test(`production direct lesson URL hydrates without errors: ${id}`, async ({ page, context, baseURL }) => {
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        page.on('console', message => {
            if (message.type() === 'error'
                && /hydrat|server.*HTML|Minified React error/i.test(message.text())) {
                errors.push(message.text());
            }
        });
        await context.addCookies([{ name: 'cookie-consent', value: 'declined', url: baseURL }]);
        await page.route('**/*', route =>
            new URL(route.request().url()).origin === baseURL ? route.continue() : route.abort(),
        );
        await page.addInitScript(({ key, origin }) => {
            if (location.origin === origin) {
                localStorage.setItem(key, 'agent-registry-operations');
            }
        }, { key: resumeStorageKey, origin: baseURL });

        const response = await page.goto(`${modulePath}#lesson-${id}`);
        expect(response.ok()).toBe(true);
        expect(await response.text()).toMatch(/<h2\b[^>]*id="selected-lesson"[^>]*>Gain AI Visibility<\/h2>/);

        const lesson = lessons.find(item => item.id === id);
        const panel = page.getByRole('region', { name: 'Selected lesson' });
        const heading = panel.getByRole('heading', { name: lesson?.title ?? 'Lesson not found', exact: true });
        await expect(heading).toBeFocused();
        await expect(page.getByRole('button', { name: 'Resume lesson', exact: true })).toHaveCount(0);
        await expect.poll(() => page.evaluate(key => localStorage.getItem(key), resumeStorageKey))
            .toBe(lesson?.id ?? 'agent-registry-operations');
        if (lesson?.videoId) {
            await expect(panel.locator('iframe')).toHaveAttribute('src',
                `https://www.youtube-nocookie.com/embed/${lesson.videoId}`);
        } else {
            await expect(panel.locator('iframe')).toHaveCount(0);
            if (lesson) {
                await expect(panel.getByRole('heading', { name: 'Video not yet available', exact: true })).toBeVisible();
            } else {
                await expect(panel.getByRole('alert')).toBeVisible();
            }
        }
        expect(errors).toEqual([]);
    });
}
