import { createRequire } from 'node:module';

const require = createRequire(new URL('../../src/react/package.json', import.meta.url));
const { test, expect } = require('@playwright/test');
const { default: AxeBuilder } = require('@axe-core/playwright');
const { resumeStorageKey } = await import('../../src/react/src/components/AIPillarLearning/catalog.mjs');
const modulePath = '/zerotrustassessment/docs/videos/AIPillar/deep-dive-learning-module';

test.beforeEach(async ({ context }) => {
    await context.addCookies([{ name: 'cookie-consent', value: 'declined', url: 'http://127.0.0.1:3000' }]);
});

async function expandOutline(page) {
    const toggle = page.getByRole('button', { name: 'Show module outline', exact: true });
    if (await toggle.isVisible()) {
        await toggle.click();
    }
}

async function expectLessonInView(page, title) {
    const panel = page.getByRole('region', { name: 'Selected lesson' });
    const heading = panel.getByRole('heading', { name: title, exact: true });
    await expect(heading).toBeFocused();
    await expect(heading).toHaveAccessibleName(title);
    await expect(heading).toHaveAttribute('tabindex', '-1');
    await expect.poll(async () => page.evaluate(() => {
        const panelRect = document.querySelector('#selected-lesson-panel').getBoundingClientRect();
        const navbarRect = document.querySelector('.navbar').getBoundingClientRect();
        const headingRect = document.querySelector('#selected-lesson').getBoundingClientRect();
        return {
            panelClear: panelRect.top >= navbarRect.bottom,
            headingVisible: headingRect.top >= navbarRect.bottom && headingRect.bottom <= innerHeight,
        };
    })).toEqual({ panelClear: true, headingVisible: true });
}

for (const width of [1440, 390, 320]) {
    test(`AI Pillar overview demo is accessible and fits a ${width}px viewport`, async ({ page }) => {
        await page.setViewportSize({ width, height: 900 });
        await page.goto('/zerotrustassessment/docs/videos/AIPillar');
        const demo = page.locator('#clickthru-frame');
        const demoUrl = 'https://msdemostorecdn.blob.core.windows.net/ztworkshop/ai/index.html';
        await expect(demo).toHaveAttribute('src', demoUrl);
        await expect(demo).toHaveAccessibleName('AI Pillar - Zero Trust workshop guide');
        await expect(demo).toHaveAttribute('allowfullscreen', '');
        await expect(page.getByRole('link', { name: 'open the interactive demo in a new tab', exact: true }))
            .toHaveAttribute('href', demoUrl);
        const fits = await demo.evaluate(node => {
            const rect = node.getBoundingClientRect();
            const article = node.closest('article').getBoundingClientRect();
            return rect.width > 0 && rect.height > 0 && rect.width <= 1024
                && rect.left >= article.left && rect.right <= article.right
                && rect.right <= innerWidth && document.documentElement.scrollWidth <= innerWidth;
        });
        expect(fits).toBe(true);
        await expect(demo).toHaveCSS('height', '576px');
        await expect(demo).toHaveCSS('border-width', '0px');
        await expect(demo).toHaveCSS('border-radius', '0px');
        const gaps = await demo.evaluate(node => {
            const rect = node.getBoundingClientRect();
            return {
                above: rect.top - node.previousElementSibling.getBoundingClientRect().bottom,
                below: node.nextElementSibling.getBoundingClientRect().top - rect.bottom,
            };
        });
        expect(gaps.above).toBeGreaterThan(0);
        expect(gaps.below).toBeCloseTo(gaps.above, 1);
        await expect(page.getByRole('heading', { name: /^General Overview/ })).toBeVisible();
        await expect(page.locator('.theme-doc-toc-desktop, .theme-doc-toc-mobile')).toHaveCount(0);
        await expect(page.getByRole('region', { name: /^Deep Dive Learning Module/ })).toHaveCount(0);
        const openModule = page.getByRole('link', { name: 'Explore the Deep Dive Learning Module', exact: true });
        await expect(openModule).toHaveAttribute('href', '/zerotrustassessment/docs/videos/AIPillar/deep-dive-learning-module');
        await expect(openModule).toHaveCSS('display', 'inline-block');
        await expect(openModule).toHaveCSS('font-weight', '600');
        await expect(openModule).toHaveCSS('text-decoration-line', 'underline');
        await expect(openModule).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');
        await expect(openModule).toHaveCSS('border-width', '0px');
        await expect(openModule).toHaveText('Explore the Deep Dive Learning Module');
        const prominentTarget = await openModule.evaluate(node =>
            node.getBoundingClientRect().height >= 44
            && parseFloat(getComputedStyle(node).fontSize) > parseFloat(getComputedStyle(node.closest('article')).fontSize),
        );
        expect(prominentTarget).toBe(true);
        await expect(openModule).toHaveCSS('color', 'rgb(29, 78, 216)');
        const accessibility = await new AxeBuilder({ page })
            .include(`a[href="${demoUrl}"]`)
            .include(`article p > a[href="${modulePath}"]`)
            .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
            .analyze();
        expect(accessibility.violations).toEqual([]);
        await openModule.hover();
        await expect(openModule).toHaveCSS('color', 'rgb(23, 61, 166)');
        await expect(openModule).toHaveCSS('text-decoration-line', 'underline');
        await page.mouse.move(0, 0);
        await page.evaluate(() => document.documentElement.setAttribute('data-theme', 'dark'));
        await expect(openModule).toHaveCSS('color', 'rgb(147, 180, 255)');
        await openModule.hover();
        await expect(openModule).toHaveCSS('color', 'rgb(182, 204, 255)');
        await expect(openModule).toHaveCSS('text-decoration-line', 'underline');
        const darkAccessibility = await new AxeBuilder({ page })
            .include(`a[href="${demoUrl}"]`)
            .include(`article p > a[href="${modulePath}"]`)
            .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
            .analyze();
        expect(darkAccessibility.violations).toEqual([]);
        await page.addStyleTag({ content: 'html { font-size: 200% !important; }' });
        const linkFits = await openModule.evaluate(node => {
            const rect = node.getBoundingClientRect();
            return rect.left >= 0 && rect.right <= innerWidth;
        });
        expect(linkFits).toBe(true);
        await openModule.focus();
        await page.keyboard.press('Tab');
        await page.keyboard.press('Shift+Tab');
        await expect(openModule).toBeFocused();
        await expect(openModule).toHaveCSS('outline-width', '3px');
        await expect(openModule).toHaveCSS('outline-style', 'solid');
        await page.keyboard.press('Enter');
        await expect(page.getByRole('heading', { name: 'AI Pillar Deep Dive Learning Module', exact: true })).toBeVisible();
    });
}

for (const viewport of [{ width: 1440, height: 1000 }, { width: 390, height: 844 }]) {
    test.describe(`${viewport.width}px viewport`, () => {
        test.use({ viewport, reducedMotion: 'reduce' });

        test('starting by keyboard or pointer reveals the whole lesson header and works repeatedly', async ({ page }) => {
            await page.goto(modulePath);
            const start = page.getByRole('button', { name: 'Start first lesson', exact: true });
            await start.focus();
            await page.keyboard.press('Enter');
            await expect(page).toHaveURL(/#lesson-gain-ai-visibility$/);
            await expectLessonInView(page, 'Gain AI Visibility');
            await expect(page.locator('iframe')).toHaveCount(1);
            await expect(page.locator('iframe')).toHaveAccessibleName('Gain AI Visibility - AI Pillar Deep Dive');
            await expect(page.locator('iframe')).not.toHaveAttribute('src', /autoplay=1/);
            await expect(page.getByRole('navigation', { name: 'Lesson navigation' }))
                .toContainText('Next lesson');
            await page.keyboard.press('Tab');
            await expect(page.locator('iframe')).toBeFocused();
            await start.focus();
            await page.keyboard.press('Space');
            await expectLessonInView(page, 'Gain AI Visibility');
            await start.click();
            await expectLessonInView(page, 'Gain AI Visibility');
            const playerInView = await page.locator('iframe').evaluate(node => {
                const rect = node.getBoundingClientRect();
                return rect.top >= document.querySelector('.navbar').getBoundingClientRect().bottom
                    && rect.bottom <= innerHeight;
            });
            expect(playerInView).toBe(true);
        });

        test('outline shortcuts, disclosure controls, and next/back navigation work by keyboard', async ({ page }) => {
            await page.goto(`${modulePath}#lesson-gain-ai-visibility`);
            await expectLessonInView(page, 'Gain AI Visibility');
            await expandOutline(page);
            const outline = page.getByRole('navigation', { name: 'AI learning outline' });
            const summary = outline.locator('summary').filter({ hasText: 'Register all agents' });
            await summary.focus();
            await page.keyboard.press('Enter');
            await expect(summary.locator('..')).toHaveAttribute('open', '');
            const registry = outline.getByRole('link', { name: /^Registry Readiness/ });
            await registry.focus();
            await page.keyboard.press('Enter');
            await expectLessonInView(page, 'Registry Readiness');
            const next = page.getByRole('navigation', { name: 'Lesson navigation' })
                .getByRole('link', { name: /Next lesson/ });
            await next.focus();
            await page.keyboard.press('Enter');
            await expectLessonInView(page, 'Agent Registry Operations');
            await page.goBack();
            await expectLessonInView(page, 'Registry Readiness');
            await expect(page.getByRole('button', { name: 'Go to selected lesson', exact: true })).toHaveCount(0);
        });

        test('the final lesson gives closing guidance rather than pointing to a missing next lesson', async ({ page }) => {
            await page.goto(`${modulePath}#lesson-assess-ai-risk`);
            await expectLessonInView(page, 'Assess AI Risk');
            const panel = page.getByRole('region', { name: 'Selected lesson' });
            const navigation = panel.getByRole('navigation', { name: 'Lesson navigation' });
            await expect(panel).toContainText('Choose Next lesson to continue.');
            await navigation.getByRole('link', { name: /Next lesson/ }).click();
            await expectLessonInView(page, 'AI Threat Detection & Response');
            await expect(panel).toContainText('You have reached the last lesson. Revisit any swimlane using the outline.');
            await expect(panel).not.toContainText('Choose Next lesson to continue.');
            await expect(navigation.getByRole('link', { name: /Next lesson/ })).toHaveCount(0);
            await expect(navigation).toContainText('End of the AI Pillar Deep Dive Learning Module');
            await navigation.getByRole('link', { name: /Previous lesson/ }).click();
            await expectLessonInView(page, 'Assess AI Risk');
            await expect(panel).toContainText('Choose Next lesson to continue.');
        });

        test('verified durations are visible and the outline stays compact on mobile', async ({ page }) => {
            await page.goto(modulePath);
            await expect(page.locator('time[datetime="PT5664S"]')).toHaveText('1 hr 34 min');
            await expect(page.locator('time[datetime="PT5664S"]')).toHaveAttribute('aria-label', '1 hr 34 min total video time');
            const panel = page.getByRole('region', { name: 'Selected lesson' });
            await expect(panel.locator('time')).toHaveText('15:45');
            const outline = page.getByRole('navigation', { name: 'AI learning outline' });
            const toggle = page.getByRole('button', { name: 'Show module outline', exact: true });
            if (viewport.width <= 1100) {
                await expect(toggle).toHaveAttribute('aria-expanded', 'false');
                await expect(outline.locator('summary').first()).not.toBeVisible();
                expect((await outline.boundingBox()).height).toBeLessThan(260);
                await expect(outline).toContainText('Discover AI Agents, Apps, and Workloads');
                await expect(outline).toContainText('Gain AI Visibility');
                await toggle.focus();
                await page.keyboard.press('Enter');
                await expect(page.getByRole('button', { name: 'Hide module outline' })).toHaveAttribute('aria-expanded', 'true');
            } else {
                await expect(toggle).not.toBeVisible();
                expect((await panel.locator('iframe').boundingBox()).y).toBeLessThan(800);
            }
            const register = outline.locator('summary').filter({ hasText: 'Register all agents' });
            await expect(register.locator('time')).toHaveText('20:56');
            await register.click();
            const registry = outline.getByRole('link', { name: /^Registry Readiness/ });
            await expect(registry.locator('time')).toHaveText('7:04');
            await registry.click();
            await expectLessonInView(page, 'Registry Readiness');
            if (viewport.width <= 1100) {
                await expect(toggle).toHaveAttribute('aria-expanded', 'false');
                await expect(outline.locator('summary').first()).not.toBeVisible();
                await expect(outline.locator('strong')).toHaveText('Registry Readiness');
            }
        });

        test('resume restores the last opened swimlane while explicit lesson links take precedence', async ({ page }) => {
            await page.goto(`${modulePath}#lesson-agent-registry-operations`);
            await expectLessonInView(page, 'Agent Registry Operations');
            await expect.poll(() => page.evaluate(key => localStorage.getItem(key), resumeStorageKey))
                .toBe('agent-registry-operations');
            await page.goto(modulePath);
            const resume = page.getByRole('button', { name: 'Resume lesson', exact: true });
            await expect(resume).toBeVisible();
            await expect(resume).toHaveAccessibleDescription(/Agent Registry Operations/);
            await resume.click();
            await expectLessonInView(page, 'Agent Registry Operations');
            await page.goto(`${modulePath}#lesson-security-validation`);
            await expectLessonInView(page, 'Security Validation');
            await expect.poll(() => page.evaluate(key => localStorage.getItem(key), resumeStorageKey))
                .toBe('security-validation');
            await page.goto(modulePath);
            await expect(resume).toHaveAccessibleDescription(/Security Validation/);
        });

        test('workshop actions are clear and unavailable training omits notes and redundant links', async ({ page }) => {
            await page.goto(modulePath);
            const launch = page.getByRole('link', { name: 'Launch Workshop Tool (opens in new tab)', exact: true });
            await expect(launch).toHaveAttribute('href', 'https://zerotrust.microsoft.com/');
            await expect(launch).toHaveAttribute('target', '_blank');
            await expect(launch).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)');
            await expect(launch).toHaveCSS('border-top-width', '0px');
            await expect(page.getByRole('button', { name: 'Choose a swimlane', exact: true })).toHaveCount(0);
            await expect(page.getByRole('button', { name: 'Start first lesson', exact: true }))
                .not.toHaveAttribute('aria-describedby', /.+/);
            await expect(page.getByText('Begin with', { exact: false })).toHaveCount(0);
            await expect(page.getByRole('link', { name: /Link to this (lesson|swimlane)/ })).toHaveCount(0);
            await expect(page.getByRole('link', { name: /Watch on YouTube/ })).toHaveCount(0);
            const notes = page.getByRole('region', { name: 'Selected lesson' });
            await expect(notes.getByRole('heading', { name: 'Apply this in your workshop', exact: true })).toBeVisible();
            await expect(notes.getByRole('link', {
                name: 'Explore the AI Pillar in the Workshop Tool (opens in new tab)', exact: true,
            })).toHaveAttribute('href', 'https://zerotrust.microsoft.com/');
            await page.goto(`${modulePath}#lesson-enterprise-compliance-integration`);
            await expectLessonInView(page, 'Enterprise Compliance Integration');
            await expect(page.getByRole('heading', { name: 'Video not yet available', exact: true })).toBeVisible();
            await expect(page.getByRole('heading', { name: 'Apply this in your workshop', exact: true })).toHaveCount(0);
            await expect(page.getByText('FACILITATOR NOTES', { exact: true })).toHaveCount(0);
            await expect(page.getByRole('button', { name: 'Choose a swimlane', exact: true })).toHaveCount(0);
            await expect(page.getByRole('link', { name: /Link to this (lesson|swimlane)/ })).toHaveCount(0);
            await page.getByRole('navigation', { name: 'Lesson navigation' })
                .getByRole('link', { name: /Next lesson/ }).click();
            await expectLessonInView(page, 'Security Validation');
            await expect(page.getByRole('heading', { name: 'Apply this in your workshop', exact: true })).toBeVisible();
            await expect(page.getByRole('link', { name: /Watch on YouTube/ })).toHaveCount(0);
        });

        test('module-owned content has no detected WCAG A/AA violations, including its unavailable lesson', async ({ page }) => {
            for (const hash of ['', '#lesson-enterprise-compliance-integration']) {
                await page.goto(`${modulePath}${hash}`);
                await expect(page.getByRole('heading', { level: 1 })).toHaveText('AI Pillar Deep Dive Learning Module');
                if (hash) {
                    await expectLessonInView(page, 'Enterprise Compliance Integration');
                    await expect(page.locator('iframe')).toHaveCount(0);
                }
                const results = await new AxeBuilder({ page })
                    .include('[class*="module_"]')
                    .exclude('iframe')
                    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
                    .analyze();
                expect(results.violations.map(({ id, nodes }) => ({
                    id,
                    elements: nodes.map(({ target, failureSummary }) => ({ target, failureSummary })),
                }))).toEqual([]);
            }
        });
    });
}

test('320px reflow and enlarged text do not clip module content or focus indicators', async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 720 });
    await page.goto(`${modulePath}#lesson-enterprise-compliance-integration`);
    await expect.poll(async () => page.evaluate(() =>
        document.documentElement.scrollWidth <= innerWidth,
    )).toBe(true);
    await page.addStyleTag({ content: 'html { font-size: 200% !important; }' });
    const overflowingModuleElements = await page.locator('[class*="module_"] *').evaluateAll(nodes =>
        nodes.filter(node => {
            const rect = node.getBoundingClientRect();
            return rect.width > 0 && (rect.left < 0 || rect.right > innerWidth);
        }).map(node => node.tagName),
    );
    expect(overflowingModuleElements).toEqual([]);
    const heading = page.getByRole('region', { name: 'Selected lesson' }).getByRole('heading', { level: 2 });
    await expect(heading).toHaveText('Enterprise Compliance Integration');
    const clipped = await page.locator('#ai-learning-outline, #selected-lesson-panel').evaluateAll(nodes =>
        nodes.some(node => getComputedStyle(node).overflow === 'hidden'),
    );
    expect(clipped).toBe(false);
    await expandOutline(page);
    await page.getByRole('navigation', { name: 'AI learning outline' }).locator('summary').first().focus();
    await page.keyboard.press('Tab');
    const focusedStyle = await page.evaluate(() => ({
        width: getComputedStyle(document.activeElement).outlineWidth,
        style: getComputedStyle(document.activeElement).outlineStyle,
    }));
    expect(focusedStyle).toEqual({ width: '3px', style: 'solid' });
});

test('stale saved lessons are cleared with an explicit notice', async ({ page }) => {
    await page.addInitScript(key => localStorage.setItem(key, 'removed-swimlane'), resumeStorageKey);
    await page.goto(modulePath);
    await expect(page.getByRole('status')).toContainText('Your saved lesson is no longer available');
    await expect(page.getByRole('button', { name: 'Start first lesson', exact: true })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Resume lesson', exact: true })).toHaveCount(0);
    expect(await page.evaluate(key => localStorage.getItem(key), resumeStorageKey)).toBe(null);
});

test('blocked storage does not prevent starting a lesson', async ({ page }) => {
    await page.addInitScript(() => {
        Object.defineProperty(window, 'localStorage', {
            get() { throw new DOMException('Storage is blocked', 'SecurityError'); },
        });
    });
    await page.goto(modulePath);
    await expect(page.getByRole('status')).toContainText('Your browser is blocking saved lessons');
    await page.getByRole('button', { name: 'Start first lesson', exact: true }).click();
    await expectLessonInView(page, 'Gain AI Visibility');
    await expect(page.locator('iframe')).toHaveCount(1);
});

test('storage write failures are reported without disrupting lesson navigation', async ({ page }) => {
    await page.addInitScript(() => {
        Storage.prototype.setItem = () => { throw new DOMException('Storage is full', 'QuotaExceededError'); };
    });
    await page.goto(modulePath);
    await page.getByRole('button', { name: 'Start first lesson', exact: true }).click();
    await expectLessonInView(page, 'Gain AI Visibility');
    await expect(page.getByRole('status')).toContainText('Your browser could not save this lesson');
    await page.getByRole('navigation', { name: 'Lesson navigation' })
        .getByRole('link', { name: /Next lesson/ }).click();
    await expectLessonInView(page, 'Registry Readiness');
});
