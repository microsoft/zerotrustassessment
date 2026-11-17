import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const html = await readFile(new URL('../../src/react/build/docs/videos/DevSecOpsPillar.html', import.meta.url), 'utf8');

test('the existing DevSecOps page renders its interactive demo and accessible fallback link', () => {
    const url = 'https://msdemostorecdn.blob.core.windows.net/ztworkshop/devsecops/index.html';
    assert.match(html, /<h1\b[^>]*>DevSecOps Pillar<\/h1>/);
    const iframe = html.match(/<iframe\b[^>]*id="clickthru-frame"[^>]*>/)?.[0];
    assert.ok(iframe, 'Expected the DevSecOps demo iframe');
    assert.ok(iframe.includes(`src="${url}"`));
    assert.match(iframe, /title="DevSecOps Pillar - Zero Trust workshop guide"/);
    assert.match(iframe, /\ballowfullscreen=""/);
    assert.ok(html.includes(`href="${url}" target="_blank" rel="noopener noreferrer"`));
    assert.doesNotMatch(html, /coming soon/);
});
