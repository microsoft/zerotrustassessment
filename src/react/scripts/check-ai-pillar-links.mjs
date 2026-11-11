import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { lessons, playlistUrl, roadmapUrl } from '../src/components/AIPillarLearning/catalog.mjs';

export function createResources(overviewMdx) {
    const demoUrl = overviewMdx.match(/<iframe\b[^>]*\bsrc="(https:\/\/[^"]+)"/)?.[1];
    if (!demoUrl) {
        throw new Error('The overview demo iframe URL was not found. Update the link check for the new page structure.');
    }
    return [
        { name: 'Overview demo', url: demoUrl, expectedTitle: /AI.*Zero Trust workshop guide/i },
        { name: 'Workshop Tool', url: roadmapUrl, expectedTitle: /Zero Trust Workshop/i },
        { name: 'Training playlist', url: playlistUrl, expectedTitle: /AI Pillar.*Deep Dive/i },
        ...lessons.filter(lesson => lesson.videoId).map(lesson => ({
            name: lesson.title,
            url: `https://www.youtube.com/watch?v=${lesson.videoId}`,
            videoId: lesson.videoId,
        })),
    ];
}

export async function checkResource(resource, request = fetch) {
    const requestUrl = resource.videoId
        ? `https://www.youtube.com/oembed?url=${encodeURIComponent(resource.url)}&format=json`
        : resource.url;
    const response = await request(requestUrl, { signal: AbortSignal.timeout(15000) });
    if (!response.ok) {
        await response.body?.cancel();
        throw new Error(`HTTP ${response.status}`);
    }
    if (resource.videoId) {
        const metadata = await response.json();
        if (metadata.type !== 'video' || typeof metadata.title !== 'string' || !metadata.title.trim()) {
            throw new Error('YouTube did not return valid video metadata.');
        }
        const embedSrc = typeof metadata.html === 'string'
            ? metadata.html.match(/<iframe\b[^>]*\bsrc="([^"]+)"/)?.[1]
            : undefined;
        if (!embedSrc) {
            throw new Error('YouTube metadata did not include a video embed.');
        }
        const embed = new URL(embedSrc);
        if (embed.hostname !== 'www.youtube.com' || embed.pathname !== `/embed/${resource.videoId}`) {
            throw new Error('YouTube metadata did not match the requested video.');
        }
    } else {
        const html = await response.text();
        const title = html.match(/<title\b[^>]*>([\s\S]*?)<\/title>/i)?.[1];
        if (!title || !resource.expectedTitle.test(title)) {
            throw new Error('Unexpected page title. Check for removed content, consent pages, or renamed resources.');
        }
    }
}

export async function checkLinks(resources, { request = fetch, report = console.log } = {}) {
    let failed = 0;
    for (let offset = 0; offset < resources.length; offset += 3) {
        const batch = resources.slice(offset, offset + 3);
        const results = await Promise.allSettled(batch.map(resource => checkResource(resource, request)));
        results.forEach((result, index) => {
            const resource = batch[index];
            if (result.status === 'fulfilled') {
                report(`PASS ${resource.name}: ${resource.url}`);
            } else {
                failed++;
                const error = result.reason;
                const detail = error instanceof Error ? error.message : String(error);
                const code = error instanceof Error && error.cause?.code ? ` (${error.cause.code})` : '';
                report(`FAIL ${resource.name}: ${resource.url} - ${detail}${code}`);
            }
        });
    }
    report(`${resources.length - failed}/${resources.length} checks passed. Video checks use public metadata, not playback.`);
    return failed;
}

if (process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url) {
    try {
        const overview = await readFile(new URL('../docs/videos/AIPillar/index.mdx', import.meta.url), 'utf8');
        const failed = await checkLinks(createResources(overview));
        process.exitCode = failed ? 1 : 0;
    } catch (error) {
        console.error('AI Pillar link check could not run:', error);
        process.exitCode = 1;
    }
}
