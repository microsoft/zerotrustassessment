import { createRequire } from 'node:module';

const require = createRequire(new URL('../../src/react/package.json', import.meta.url));
const { test, expect } = require('@playwright/test');
const { default: AxeBuilder } = require('@axe-core/playwright');
const demoUrl = 'https://msdemostorecdn.blob.core.windows.net/ztworkshop/devsecops/index.html';

test.beforeEach(async ({ context }) => {
    await context.addCookies([{ name: 'cookie-consent', value: 'declined', url: 'http://127.0.0.1:3000' }]);
});

for (const width of [1440, 390, 320]) {
    test(`DevSecOps demo preserves its route and fits a ${width}px viewport`, async ({ page }) => {
        await page.setViewportSize({ width, height: 900 });
        await page.goto('/zerotrustassessment/docs/videos/DevSecOpsPillar');
        await expect(page.getByRole('heading', { name: 'DevSecOps Pillar', exact: true })).toBeVisible();
        await expect(page.locator('article')).not.toContainText('coming soon');
        const demo = page.locator('#clickthru-frame');
        await expect(page.locator('article iframe')).toHaveCount(1);
        await expect(demo).toHaveAttribute('src', demoUrl);
        await expect(demo).toHaveAccessibleName('DevSecOps Pillar - Zero Trust workshop guide');
        await expect(demo).toHaveAttribute('allowfullscreen', '');
        await expect(demo).toHaveCSS('height', '576px');
        await expect(demo).toHaveCSS('border-width', '0px');
        const layout = await demo.evaluate(node => {
            const rect = node.getBoundingClientRect();
            const article = node.closest('article').getBoundingClientRect();
            return {
                fits: rect.width > 0 && rect.width <= 1024 && rect.left >= article.left
                    && rect.right <= article.right && rect.right <= innerWidth
                    && document.documentElement.scrollWidth <= innerWidth,
                above: rect.top - node.previousElementSibling.getBoundingClientRect().bottom,
                below: node.nextElementSibling.getBoundingClientRect().top - rect.bottom,
            };
        });
        expect(layout.fits).toBe(true);
        expect(layout.above).toBeGreaterThan(0);
        expect(layout.below).toBeCloseTo(layout.above, 1);
        const fallback = page.getByRole('link', { name: 'open the interactive demo in a new tab', exact: true });
        await expect(fallback).toHaveAttribute('href', demoUrl);
        await expect(fallback).toHaveAttribute('target', '_blank');
        await expect(fallback).toHaveAttribute('rel', 'noopener noreferrer');
        const accessibility = await new AxeBuilder({ page })
            .include(`a[href="${demoUrl}"]`)
            .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
            .analyze();
        expect(accessibility.violations).toEqual([]);
    });
}
