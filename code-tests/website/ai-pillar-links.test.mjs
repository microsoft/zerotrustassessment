import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import { checkLinks, checkResource, createResources } from '../../src/react/scripts/check-ai-pillar-links.mjs';
import { lessons, playlistUrl, roadmapUrl } from '../../src/react/src/components/AIPillarLearning/catalog.mjs';

const overview = await readFile(new URL('../../src/react/docs/videos/AIPillar/index.mdx', import.meta.url), 'utf8');
const resources = createResources(overview);
const video = resources.find(resource => resource.videoId);

function videoResponse(id = video.videoId) {
    return Response.json({
        type: 'video',
        title: 'Training video',
        html: `<iframe src="https://www.youtube.com/embed/${id}?feature=oembed"></iframe>`,
    });
}

test('maintenance checks cover the actual demo URL, Workshop Tool, playlist, and every published video', () => {
    assert.equal(resources.length, 22);
    assert.equal(resources[0].url, 'https://msdemostorecdn.blob.core.windows.net/ztworkshop/ai/index.html');
    assert.equal(resources[1].url, roadmapUrl);
    assert.equal(resources[2].url, playlistUrl);
    assert.deepEqual(resources.filter(resource => resource.videoId).map(resource => resource.videoId),
        lessons.filter(lesson => lesson.videoId).map(lesson => lesson.videoId));
    assert.ok(!resources.some(resource => resource.name === 'Enterprise Compliance Integration'));
    assert.equal(createResources('<iframe src="https://example.com/new-demo"></iframe>')[0].url, 'https://example.com/new-demo');
    assert.throws(() => createResources('No demo'), /iframe URL was not found/);
});

test('HTML checks reject success-shaped missing-content and consent pages', async () => {
    await checkResource(resources[0], async () => new Response('<title>AI - Zero Trust workshop guide</title>'));
    await checkResource(resources[1], async () => new Response('<title>Zero Trust Workshop</title>'));
    await checkResource(resources[2], async () => new Response('<title>AI Pillar Deep Dive Training - YouTube</title>'));
    for (const html of ['<title>YouTube</title>', '<title>Before you continue</title>', '<p>Not found</p>']) {
        await assert.rejects(checkResource(resources[2], async () => new Response(html)), /Unexpected page title/);
    }
});

test('HTTP failures cancel the unread body and do not pass an availability check', async () => {
    let cancelled = false;
    const response = new Response(new ReadableStream({ cancel() { cancelled = true; } }), { status: 404 });
    await assert.rejects(checkResource(resources[0], async () => response), /HTTP 404/);
    assert.equal(cancelled, true);
});

test('video checks request bounded public metadata for the exact watch URL', async () => {
    await checkResource(video, async (url, options) => {
        const endpoint = new URL(url);
        assert.equal(endpoint.origin + endpoint.pathname, 'https://www.youtube.com/oembed');
        assert.equal(endpoint.searchParams.get('url'), video.url);
        assert.equal(endpoint.searchParams.get('format'), 'json');
        assert.ok(options.signal instanceof AbortSignal);
        return videoResponse();
    });
});

test('video checks reject missing, malformed, or mismatched metadata', async () => {
    await assert.rejects(checkResource(video, async () => Response.json({ error: 'Unavailable' })), /valid video metadata/);
    await assert.rejects(checkResource(video, async () => Response.json({ type: 'video', title: 'Video' })), /include a video embed/);
    await assert.rejects(checkResource(video, async () => videoResponse('different-id')), /match the requested video/);
    await assert.rejects(checkResource(video, async () => new Response('Not JSON')), SyntaxError);
});

test('maintenance checks report network failures and timeouts while continuing with remaining resources', async () => {
    const messages = [];
    let count = 0;
    const failed = await checkLinks(resources.slice(0, 4), {
        request: async () => {
            count++;
            if (count === 1) {
                throw new Error('Network unavailable');
            }
            if (count === 2) {
                throw new DOMException('Request timed out', 'TimeoutError');
            }
            if (count === 3) {
                return new Response('Unavailable', { status: 503 });
            }
            return videoResponse();
        },
        report: message => messages.push(message),
    });
    assert.equal(count, 4);
    assert.equal(failed, 3);
    assert.equal(messages.filter(message => message.startsWith('FAIL ')).length, 3);
    assert.ok(messages.some(message => message.includes('Network unavailable')));
    assert.ok(messages.some(message => message.includes('Request timed out')));
    assert.ok(messages.some(message => message.includes('HTTP 503')));
    assert.match(messages.at(-1), /^1\/4 checks passed/);
});

test('external checks never exceed three concurrent requests', async () => {
    let active = 0;
    let maximum = 0;
    const failed = await checkLinks(Array.from({ length: 8 }, () => video), {
        request: async () => {
            active++;
            maximum = Math.max(maximum, active);
            await Promise.resolve();
            active--;
            return videoResponse();
        },
        report: () => {},
    });
    assert.equal(failed, 0);
    assert.equal(maximum, 3);
});
