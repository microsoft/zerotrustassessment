import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const buildRoot = new URL('../../src/react/build/docs/videos/', import.meta.url);
const moduleHtml = (await readFile(new URL('AIPillar/deep-dive-learning-module.html', buildRoot), 'utf8'))
    .replace(/\s+/g, ' ');
const overviewHtml = await readFile(new URL('AIPillar.html', buildRoot), 'utf8');

test('the AI Pillar overview embeds the interactive demo with a titled full-screen frame and direct link', () => {
    const demoUrl = 'https://msdemostorecdn.blob.core.windows.net/ztworkshop/ai/index.html';
    const iframe = overviewHtml.match(/<iframe\b[^>]*id="clickthru-frame"[^>]*>/)?.[0];
    assert.ok(iframe, 'Expected the interactive overview demo');
    assert.ok(iframe.includes(`src="${demoUrl}"`));
    assert.match(iframe, /title="AI Pillar - Zero Trust workshop guide"/);
    assert.match(iframe, /\ballowfullscreen=""/);
    assert.ok(overviewHtml.includes(`href="${demoUrl}" target="_blank" rel="noopener noreferrer"`));
    assert.doesNotMatch(overviewHtml, /The general overview video will be added here/);
    assert.match(overviewHtml, /href="[^"]*\/AIPillar\/deep-dive-learning-module"/);
});

test('the module has its full page title while retaining the shorter sidebar label', () => {
    assert.match(moduleHtml, /<h1\b[^>]*>AI Pillar Deep Dive Learning Module<\/h1>/);
    assert.match(moduleHtml, /<title\b[^>]*>AI Pillar Deep Dive Learning Module \| Microsoft Zero Trust<\/title>/);
    const sidebar = moduleHtml.match(/<aside\b[\s\S]*?<\/aside>/)?.[0];
    assert.ok(sidebar, 'Expected a server-rendered documentation sidebar');
    const sidebarLink = sidebar.match(/<a\b[^>]*href="[^"]*\/AIPillar\/deep-dive-learning-module"[^>]*>([\s\S]*?)<\/a>/);
    assert.equal(sidebarLink?.[1].replace(/<[^>]+>/g, ''), 'Deep Dive Learning Module');
    assert.doesNotMatch(moduleHtml, /AI PILLAR LEARNING PATH|AI Pillar Learning Path/);
});

test('the introduction explains detailed workshop delivery and links back to the overview', () => {
    assert.match(moduleHtml, /one swimlane at a time/);
    assert.match(moduleHtml, /workshop facilitators/);
    assert.match(moduleHtml, /href="[^"]*\/docs\/videos\/AIPillar">AI Pillar page<\/a>/);
    assert.match(moduleHtml, /then follow the suggested order or jump to the topic you are preparing to deliver/);
    assert.match(overviewHtml, /General Overview/);
    assert.doesNotMatch(overviewHtml, /aria-label="AI learning outline"/);
});

test('the unavailable swimlane stays in the outline without a module-wide warning', () => {
    assert.match(moduleHtml, /id="lesson-enterprise-compliance-integration"/);
    assert.match(moduleHtml, /Enterprise Compliance Integration/);
    assert.equal((moduleHtml.match(/Video not yet available/g) ?? []).length, 1);
    assert.doesNotMatch(moduleHtml, /Enterprise Compliance Integration is included in the roadmap/);
    assert.equal((moduleHtml.match(/<iframe\b/g) ?? []).length, 1);
    assert.match(moduleHtml, /src="https:\/\/www.youtube-nocookie.com\/embed\/nflmD2D9T4k"/);
});
