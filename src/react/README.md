# Website

This is the website code for the ZT Assessment.

Follow the instructions below to run your own instance of the Zero Trust public site. This is an easy way to make changes and test how the site will look before you commit your changes.

# Installation

There are two options here. You can use GitHub Codespaces (simple) where everything runs in the browser or you can do local dev where you install Node.js and run everything on your laptop locally.

## Codespaces (recommended for language translations)

- In GitHub select **Code** > **Codespaces** > Create a new one for the first time (or connect to an existing codespace by clicking on its name).

## Local Dev
- Install [node.js](https://nodejs.org/en/download/)

# Running ZT website

- In VS Code (Codespaces or local dev) open a new Terminal (Menu > Terminal > New Terminal)
- Type this command and hit enter → `cd ./src/react`
- ONE TIME SETUP: Run this command to install all dependencies → `npm install`
- Type this command and hit enter to launch site in English → `npm run start`
   - If you want to run the site in a different language (e.g. Japanese) → `npm run start -- --locale ja`
   - Use the right code for the language that you are testing

## Build dependency security

The [package manifest](./package.json) temporarily overrides Docusaurus's `tinypool`
dependency and webpack's `serialize-javascript` dependency to patched public releases.
These versions support Node.js 20. Revisit the overrides when upstream dependency ranges
include the fixes, and validate the full production build after changing them.

## DevSecOps pillar demo

The [DevSecOps Pillar page](./docs/videos/DevSecOpsPillar.md) preserves its
`/docs/videos/DevSecOpsPillar` route and embeds the interactive workshop demo.
Its titled, full-screen-enabled frame fits the available width without a fixed
700px minimum, and a direct new-tab link provides an alternative to the embed.
Run `npm run test:browser -- --grep "DevSecOps demo"` with the development server
running to check desktop/mobile layout and accessibility of the fallback link.
After an English production build, run
`node --test .\code-tests\website\devsecops-pillar.test.mjs` from the repository root.

## AI pillar learning module

The [AI Pillar overview](./docs/videos/AIPillar/index.mdx) keeps its existing
`/docs/videos/AIPillar` route and embeds the interactive general-overview demo
hosted at `https://msdemostorecdn.blob.core.windows.net/ztworkshop/ai/index.html`.
The titled iframe fits the available page width, supports full screen, and has
a direct new-tab link for a larger view or when embedding is unavailable.
The overview hides the right-hand table of contents to give the demo more room
and links to the Deep Dive Learning Module below the demo. Its
[page styles](./src/css/ai-pillar-overview.module.css) preserve the original
borderless demo sizing and provide understated helper text and visible focus indicators.
The Deep Dive text call to action uses larger, semibold text, an underline,
a minimum 44px target height, and a visible keyboard-focus outline without a button
box. Its light/dark colors are scoped to this link; site-wide links are unchanged.
The nested [Deep Dive Learning Module](./docs/videos/AIPillar/deep-dive-learning-module.mdx)
is available at `/docs/videos/AIPillar/deep-dive-learning-module`. Its
[lesson catalog](./src/components/AIPillarLearning/catalog.mjs) groups videos by
roadmap focus area and swimlane, not by playlist order. Update the catalog when
videos or roadmap swimlanes change; use `videoId: null` for a swimlane without a
published video. The module does not fetch YouTube metadata at runtime.
Video lengths (`durationSeconds`) were verified against the YouTube playlist on
2026-11-10. The 19 available videos total 1:34:24 (displayed as 1 hr 34 min in the
module summary); focus-area totals exclude
unpublished training. Recheck durations if a video is replaced.

Lessons can be shared using `#lesson-<lesson-id>` at the end of the module URL.
Only the selected video is embedded, with no autoplay or completion tracking.
The introduction is compact, and the mobile outline starts collapsed while showing
the current focus area and swimlane. Selecting a lesson closes the mobile outline.
Returning visitors can resume the last opened swimlane. Only its catalog ID is
stored in browser local storage under `zta-ai-pillar-last-lesson-v1`; no playback
position, completion data, or personal information is stored. An explicit lesson
URL takes precedence. Storage failures show a notice and leave the module usable.
Workshop prompts are discussion aids, not video transcripts or verified learning
outcomes.

From the repository root, run the catalog regression tests:

```powershell
node --test .\code-tests\website\ai-pillar.test.mjs
```

Use `npm run build -- --locale en` in this directory to validate the English site.
After building, run `node --test .\code-tests\website\ai-pillar-pages.test.mjs`
from the repository root to check the rendered titles, sidebar label, overview
link, and unavailable-video placement.
In the browser, check outline selection, previous/next, direct lesson links,
back/forward navigation, the missing-video state, and the mobile layout.

With the development server running, use `npm run test:browser` in this directory
for keyboard navigation, fixed-header clearance, repeatable start actions, mobile
reflow, enlarged module text, and automated WCAG A/AA checks of module-owned content.
The accessibility scan does not inspect YouTube's cross-origin player internals;
the module provides a titled embedded player and a module-level full-playlist link.
If Playwright reports that Chromium is missing, run `npx playwright install chromium`.
The start action selects the first lesson and moves focus to its heading without
autoplay. The outline and previous/next lesson controls remain keyboard accessible.
Run `npm run test:browser:production` to build the English site and run the AI pillar
browser tests against a temporary production server on port 3002. Direct-link checks cover hydration
errors, lesson focus, explicit-link precedence over saved lessons, and resume storage,
including unpublished and unknown lessons. Hash selection is deferred until after
hydration so the initial client render matches the generated first-lesson HTML.
The Workshop Tool action and facilitator-note links open the workshop tool in a
new tab. Swimlanes without a video show an availability note and lesson navigation,
but no facilitator notes. Lesson URLs remain shareable through the address bar.

Lesson selection focuses the selected level-two heading after navigation, including when the mobile
outline closes. This supplies the lesson name through focus rather than adding
a second live announcement. Browser tests verify the focus target and accessible
name; they do not replace a real screen-reader listening test. Before release,
check mobile outline selection, previous/next, and browser history with a screen
reader, confirming that the selected lesson is announced once and focus remains
usable. The final lesson points back to the outline, not to a nonexistent next lesson.

### On-demand content availability

Run `npm run check:ai-links` from this directory before publishing, after replacing
content, or during periodic maintenance. This is separate from build and regression
tests so a third-party outage does not block normal development. It reads the demo
URL from the overview and the playlist, Workshop Tool, and 19 published video links
from the catalog. Unpublished swimlanes are excluded.

The check uses at most three concurrent requests with a 15-second timeout per
request. HTML checks verify the expected page title rather than accepting any HTTP
200 page. Video checks use YouTube's public oEmbed metadata and verify the returned
embed ID. Failures are listed individually and produce a nonzero exit code.
Consent pages, renamed pages, or network restrictions need manual investigation;
a passing result does not guarantee playback, captions, embedding in every region,
or that the demo's scripts and media all work. Check those in a browser.

Run its offline regression tests from the repository root:

```powershell
node --test .\code-tests\website\ai-pillar-links.test.mjs
```
