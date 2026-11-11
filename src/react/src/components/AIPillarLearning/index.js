import React, { useCallback, useEffect, useRef, useState } from 'react';
import Link from '@docusaurus/Link';
import { useHistory, useLocation } from '@docusaurus/router';
import useBrokenLinks from '@docusaurus/useBrokenLinks';
import useIsBrowser from '@docusaurus/useIsBrowser';
import { FaArrowLeft, FaArrowRight, FaChevronDown, FaExternalLinkAlt, FaLayerGroup, FaRegClock } from 'react-icons/fa';
import {
    durationLabel, findLesson, focusAreas, formatDuration, formatTotalDuration, lessonHash, lessons,
    playlistUrl, resumeStorageKey, roadmapUrl, totalDuration,
} from './catalog.mjs';
import styles from './styles.module.css';

export default function AIPillarLearning() {
    const location = useLocation();
    const isBrowser = useIsBrowser();
    const hash = isBrowser ? location.hash : '';
    const history = useHistory();
    const brokenLinks = useBrokenLinks();
    const selectedLesson = findLesson(hash);
    const heading = useRef(null);
    const lessonPanel = useRef(null);
    const [outlineExpanded, setOutlineExpanded] = useState(false);
    const [savedLesson, setSavedLesson] = useState(null);
    const [storageReady, setStorageReady] = useState(false);
    const [resumeMessage, setResumeMessage] = useState('');
    const videoCount = lessons.filter(lesson => lesson.videoId).length;
    const videoDuration = totalDuration(lessons);
    const index = lessons.indexOf(selectedLesson);
    const resumeLesson = !hash ? savedLesson : null;

    lessons.forEach(lesson => brokenLinks.collectAnchor(lessonHash(lesson).slice(1)));

    const revealLesson = useCallback(() => {
        heading.current?.focus({ preventScroll: true });
        lessonPanel.current?.scrollIntoView({ block: 'start', behavior: 'instant' });
    }, []);

    const selectLesson = lesson => {
        setOutlineExpanded(false);
        const nextHash = lessonHash(lesson);
        if (hash === nextHash) {
            revealLesson();
        } else {
            history.push({ pathname: location.pathname, search: location.search, hash: nextHash });
        }
    };

    const handleLessonLink = (event, lesson) => {
        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) {
            return;
        }
        event.preventDefault();
        selectLesson(lesson);
    };

    useEffect(() => {
        if (hash) {
            // Move focus after the browser restores the hash navigation position.
            const frame = window.requestAnimationFrame(revealLesson);
            return () => window.cancelAnimationFrame(frame);
        }
    }, [hash, revealLesson]);

    useEffect(() => {
        try {
            const savedId = window.localStorage.getItem(resumeStorageKey);
            const saved = lessons.find(lesson => lesson.id === savedId);
            if (savedId && !saved) {
                window.localStorage.removeItem(resumeStorageKey);
                setResumeMessage('Your saved lesson is no longer available. Choose any swimlane to continue.');
            }
            setSavedLesson(saved ?? null);
            setStorageReady(true);
        } catch {
            setResumeMessage('Your browser is blocking saved lessons. You can still use the full module without resume.');
        }
    }, []);

    useEffect(() => {
        if (!storageReady || !hash || !selectedLesson) {
            return;
        }
        try {
            window.localStorage.setItem(resumeStorageKey, selectedLesson.id);
            setSavedLesson(selectedLesson);
        } catch {
            setSavedLesson(null);
            setStorageReady(false);
            setResumeMessage('Your browser could not save this lesson. You can still use the full module without resume.');
        }
    }, [hash, selectedLesson, storageReady]);

    return (
        <div className={styles.module}>
            <div className={styles.overview}>
                <div className={styles.overviewHeader}>
                    <div className={styles.overviewTitle}>
                        <span className={styles.overviewIcon}><FaLayerGroup aria-hidden="true" /></span>
                        <p className={styles.eyebrow}>SWIMLANE-BY-SWIMLANE TRAINING</p>
                    </div>
                    <span className={styles.totalTime}>
                        <FaRegClock aria-hidden="true" />
                        <time dateTime={`PT${videoDuration}S`} aria-label={`${formatTotalDuration(videoDuration)} total video time`}>
                            {formatTotalDuration(videoDuration)}
                        </time>
                        <span>total video</span>
                    </span>
                </div>
                <dl className={styles.stats}>
                    <div><dt>Focus areas</dt><dd>{focusAreas.length}</dd></div>
                    <div><dt>Swimlanes</dt><dd>{lessons.length}</dd></div>
                    <div><dt>Videos</dt><dd>{videoCount}</dd></div>
                </dl>
                <div className={styles.actions}>
                    <button
                        type="button"
                        className={styles.startButton}
                        onClick={() => selectLesson(resumeLesson ?? lessons[0])}
                        aria-controls="selected-lesson-panel"
                        aria-describedby={resumeLesson ? 'resume-lesson-context' : undefined}
                    >
                        {resumeLesson ? 'Resume lesson' : 'Start first lesson'} <FaArrowRight aria-hidden="true" />
                    </button>
                    <a href={roadmapUrl} target="_blank" rel="noopener noreferrer">
                        Launch Workshop Tool <FaExternalLinkAlt aria-hidden="true" />
                        <span className={styles.srOnly}> (opens in new tab)</span>
                    </a>
                    <a href={playlistUrl} target="_blank" rel="noopener noreferrer">
                        Full playlist <FaExternalLinkAlt aria-hidden="true" />
                        <span className={styles.srOnly}> (opens in new tab)</span>
                    </a>
                </div>
                {resumeLesson && (
                    <p id="resume-lesson-context" className={styles.resumeHint}>
                        Last opened: <strong>{resumeLesson.title}</strong>. Saved only in this browser.
                    </p>
                )}
                {resumeMessage && <p className={styles.resumeHint} role="status">{resumeMessage}</p>}
            </div>

            <div className={styles.layout}>
                <nav
                    id="ai-learning-outline"
                    aria-label="AI learning outline"
                    className={`${styles.outline} ${outlineExpanded ? styles.outlineExpanded : ''}`}
                >
                    <div className={styles.mobileOutlineBar}>
                        <button
                            type="button"
                            className={styles.outlineToggle}
                            aria-expanded={outlineExpanded}
                            aria-controls="module-outline-content"
                            onClick={() => setOutlineExpanded(expanded => !expanded)}
                        >
                            {outlineExpanded ? 'Hide module outline' : 'Show module outline'}
                            <FaChevronDown aria-hidden="true" />
                        </button>
                        {selectedLesson && (
                            <p className={styles.mobileCurrent}>
                                {selectedLesson.focusArea.title}
                                <strong>{selectedLesson.title}</strong>
                            </p>
                        )}
                    </div>
                    <div id="module-outline-content" className={styles.outlineContents}>
                    <div className={styles.outlineHeader}>
                        <p className={styles.eyebrow}>EXPLORE THE MODULE</p>
                        <h2 id="learning-outline-heading">Focus areas &amp; swimlanes</h2>
                        <p>Follow the sequence or choose your topic.</p>
                    </div>
                    {focusAreas.map((area, areaIndex) => {
                        const active = selectedLesson?.focusArea.id === area.id;
                        return (
                            <details key={area.id} open={active}>
                                <summary>
                                    <span className={styles.areaNumber}>{String(areaIndex + 1).padStart(2, '0')}</span>
                                    <span className={styles.areaTitle}>
                                        {area.title}
                                        <span className={styles.lessonCount}>
                                            {area.lessons.length} {area.lessons.length === 1 ? 'swimlane' : 'swimlanes'}
                                            {' | '}<time dateTime={`PT${totalDuration(area.lessons)}S`} aria-label={`${durationLabel(totalDuration(area.lessons))} available video time`}>
                                                {formatDuration(totalDuration(area.lessons))}
                                            </time>
                                        </span>
                                    </span>
                                </summary>
                                <ul>
                                    {area.lessons.map(lesson => (
                                        <li key={lesson.id}>
                                            <Link
                                                to={lessonHash(lesson)}
                                                onClick={event => handleLessonLink(event, lesson)}
                                                aria-current={selectedLesson?.id === lesson.id ? 'step' : undefined}
                                            >
                                                {lesson.title}
                                                {lesson.videoId && (
                                                    <span className={styles.lessonCount}>
                                                        <time dateTime={`PT${lesson.durationSeconds}S`} aria-label={`Video duration: ${durationLabel(lesson.durationSeconds)}`}>
                                                            {formatDuration(lesson.durationSeconds)}
                                                        </time>
                                                    </span>
                                                )}
                                                {!lesson.videoId && (
                                                    <span className={styles.lessonCount}>Video not yet available</span>
                                                )}
                                            </Link>
                                        </li>
                                    ))}
                                </ul>
                            </details>
                        );
                    })}
                    </div>
                </nav>

                <section id="selected-lesson-panel" ref={lessonPanel} className={styles.lesson} aria-label="Selected lesson">
                    {lessons.map(lesson => (
                        <span
                            key={lesson.id}
                            id={lessonHash(lesson).slice(1)}
                            className={styles.lessonAnchor}
                            aria-hidden="true"
                        />
                    ))}
                    {!selectedLesson ? (
                        <div role="alert">
                            <h2 ref={heading} tabIndex={-1}>Lesson not found</h2>
                            <p>This lesson link is not recognized. Choose a swimlane from the AI Pillar Deep Dive Learning Module outline.</p>
                            <Link to={lessonHash(lessons[0])} onClick={event => handleLessonLink(event, lessons[0])}>Go to the first lesson</Link>
                        </div>
                    ) : (
                        <>
                            <header className={styles.lessonHeader}>
                                <span className={styles.swimlaneBadge}>
                                    Swimlane {String(index + 1).padStart(2, '0')} / {lessons.length}
                                </span>
                                {selectedLesson.videoId && (
                                    <time
                                        className={styles.lessonDuration}
                                        dateTime={`PT${selectedLesson.durationSeconds}S`}
                                        aria-label={`Video duration: ${durationLabel(selectedLesson.durationSeconds)}`}
                                    >
                                        <FaRegClock aria-hidden="true" /> {formatDuration(selectedLesson.durationSeconds)}
                                    </time>
                                )}
                                <p className={styles.focusArea}>{selectedLesson.focusArea.title}</p>
                                <h2 id="selected-lesson" ref={heading} tabIndex={-1}>
                                    {selectedLesson.title}
                                </h2>
                                <p>{selectedLesson.focusArea.introduction}</p>
                            </header>
                            {selectedLesson.videoId ? (
                                <>
                                    <p className={styles.videoHelp}>
                                        Select Play to watch the video. Then review the facilitator notes.
                                        {index < lessons.length - 1
                                            ? ' Choose Next lesson to continue.'
                                            : ' You have reached the last lesson. Revisit any swimlane using the outline.'}
                                    </p>
                                    <iframe
                                        key={selectedLesson.videoId}
                                        className={styles.player}
                                        src={`https://www.youtube-nocookie.com/embed/${selectedLesson.videoId}`}
                                        title={`${selectedLesson.title} - AI Pillar Deep Dive`}
                                        allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                        referrerPolicy="strict-origin-when-cross-origin"
                                        allowFullScreen
                                    />
                                </>
                            ) : (
                                <div className={styles.unavailable} role="note">
                                    <h3>Video not yet available</h3>
                                    <p>
                                        This swimlane is part of the module, but its training video
                                        is not yet available. Choose Next lesson to continue.
                                    </p>
                                </div>
                            )}
                            {selectedLesson.videoId && (
                                <div className={styles.workshop}>
                                    <p className={styles.eyebrow}>FACILITATOR NOTES</p>
                                    <h3>Apply this in your workshop</h3>
                                    <p>{selectedLesson.focusArea.discussion}</p>
                                    <ul>
                                        <li>Locate <strong>{selectedLesson.title}</strong> under <strong>{selectedLesson.focusArea.title}</strong> in the Workshop Tool.</li>
                                        <li>Discuss the current state, gaps, and prerequisites with your customer.</li>
                                        <li>Agree on a next action and an accountable owner for this swimlane.</li>
                                    </ul>
                                    <a href={roadmapUrl} target="_blank" rel="noopener noreferrer">
                                        Explore the AI Pillar in the Workshop Tool <FaExternalLinkAlt aria-hidden="true" />
                                        <span className={styles.srOnly}> (opens in new tab)</span>
                                    </a>
                                </div>
                            )}
                            <nav aria-label="Lesson navigation" className={styles.lessonNavigation}>
                                {index > 0 ? (
                                    <Link to={lessonHash(lessons[index - 1])} onClick={event => handleLessonLink(event, lessons[index - 1])}>
                                        <span className={styles.navLabel}><FaArrowLeft aria-hidden="true" /> Previous lesson</span>
                                        {lessons[index - 1].title}
                                    </Link>
                                ) : <span />}
                                {index < lessons.length - 1 ? (
                                    <Link to={lessonHash(lessons[index + 1])} onClick={event => handleLessonLink(event, lessons[index + 1])}>
                                        <span className={styles.navLabel}>Next lesson <FaArrowRight aria-hidden="true" /></span>
                                        {lessons[index + 1].title}
                                    </Link>
                                ) : (
                                    <div>
                                        <strong>End of the AI Pillar Deep Dive Learning Module</strong>
                                        <p>Revisit any swimlane using the outline.</p>
                                    </div>
                                )}
                            </nav>
                        </>
                    )}
                </section>
            </div>
        </div>
    );
}
