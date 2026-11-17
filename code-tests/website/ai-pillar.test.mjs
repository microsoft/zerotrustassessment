import assert from 'node:assert/strict';
import test from 'node:test';
import {
    findLesson,
    durationLabel,
    formatDuration,
    formatTotalDuration,
    focusAreas,
    lessonHash,
    lessons,
    totalDuration,
} from '../../src/react/src/components/AIPillarLearning/catalog.mjs';

test('the roadmap contains seven focus areas, twenty swimlanes, and nineteen unique videos', () => {
    assert.equal(focusAreas.length, 7);
    assert.equal(lessons.length, 20);
    const videos = lessons.filter(lesson => lesson.videoId);
    assert.equal(videos.length, 19);
    assert.equal(new Set(videos.map(lesson => lesson.videoId)).size, 19);
    assert.equal(new Set(lessons.map(lesson => lesson.id)).size, 20);
    for (const lesson of videos) {
        assert.match(lesson.videoId, /^[A-Za-z0-9_-]{11}$/);
    }
});

test('lessons follow roadmap order rather than playlist order', () => {
    assert.deepEqual(focusAreas.map(area => area.lessons.length), [1, 3, 2, 3, 4, 5, 2]);
    assert.deepEqual(lessons.slice(0, 4).map(lesson => lesson.id), [
        'gain-ai-visibility',
        'registry-readiness',
        'agent-registry-operations',
        'workload-id-migration',
    ]);
    assert.equal(lessons.at(-1).id, 'ai-threat-detection-response');
    for (const lesson of lessons) {
        assert.ok(lesson.focusArea.lessons.some(item => item.id === lesson.id));
    }
});

test('every swimlane has a stable, resolvable deep link', () => {
    assert.equal(findLesson(''), lessons[0]);
    for (const lesson of lessons) {
        assert.equal(findLesson(lessonHash(lesson)), lesson);
        assert.match(lessonHash(lesson), /^#lesson-[a-z0-9-]+$/);
    }
});

test('unknown or malformed lesson links do not silently select a different lesson', () => {
    for (const hash of ['#lesson-missing', '#lesson-%', '#registry-readiness', '#lesson-']) {
        assert.equal(findLesson(hash), undefined);
    }
});

test('the missing video remains a navigable swimlane between MCP governance and validation', () => {
    const unavailable = lessons.filter(lesson => !lesson.videoId);
    assert.equal(unavailable.length, 1);
    assert.equal(unavailable[0].id, 'enterprise-compliance-integration');
    const index = lessons.indexOf(unavailable[0]);
    assert.equal(lessons[index - 1].id, 'mcp-server-governance');
    assert.equal(lessons[index + 1].id, 'security-validation');
    assert.equal(findLesson(lessonHash(unavailable[0])), unavailable[0]);
});

test('verified video durations total 1 hour, 34 minutes, 24 seconds and exclude unpublished training', () => {
    for (const lesson of lessons) {
        if (lesson.videoId) {
            assert.ok(Number.isInteger(lesson.durationSeconds) && lesson.durationSeconds > 0);
        } else {
            assert.equal(lesson.durationSeconds, undefined);
        }
    }
    assert.deepEqual(focusAreas.map(area => totalDuration(area.lessons)), [945, 1256, 1144, 377, 906, 638, 398]);
    assert.equal(totalDuration(lessons), 5664);
    assert.equal(totalDuration(lessons.filter(lesson => !lesson.videoId)), 0);
});

test('video durations keep seconds and hours accurate in visual and accessible labels', () => {
    for (const [seconds, expected] of [[0, '0:00'], [28, '0:28'], [945, '15:45'], [3600, '1:00:00'], [5664, '1:34:24']]) {
        assert.equal(formatDuration(seconds), expected);
    }
    assert.equal(durationLabel(945), '15 min 45 sec');
    assert.equal(durationLabel(5664), '1 hr 34 min 24 sec');
});

test('the module total displays hours and minutes without seconds', () => {
    assert.equal(formatTotalDuration(5664), '1 hr 34 min');
    assert.equal(formatTotalDuration(3600), '1 hr 0 min');
    assert.equal(formatTotalDuration(3540), '59 min');
    assert.equal(formatTotalDuration(0), '0 min');
});
