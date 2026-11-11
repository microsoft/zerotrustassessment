export const roadmapUrl = 'https://zerotrust.microsoft.com/';
export const playlistUrl = 'https://www.youtube.com/playlist?list=PLczzfanha1vc';
export const resumeStorageKey = 'zta-ai-pillar-last-lesson-v1';

export const focusAreas = [
    {
        id: 'discover-ai',
        title: 'Discover AI Agents, Apps, and Workloads',
        introduction: 'Start with visibility into the AI services and agents used across the organization.',
        discussion: 'Where are AI agents, apps, and workloads discovered today, and who owns the inventory?',
        lessons: [
            { id: 'gain-ai-visibility', title: 'Gain AI Visibility', videoId: 'nflmD2D9T4k', durationSeconds: 945 },
        ],
    },
    {
        id: 'register-agents',
        title: 'Register all agents',
        introduction: 'Explore agent registration, ongoing registry operations, and identity migration.',
        discussion: 'How are agents approved, registered, assigned owners, and managed throughout their lifecycle?',
        lessons: [
            { id: 'registry-readiness', title: 'Registry Readiness', videoId: 'B_Ecumz451U', durationSeconds: 424 },
            { id: 'agent-registry-operations', title: 'Agent Registry Operations', videoId: 'RkTaet71ZaU', durationSeconds: 443 },
            { id: 'workload-id-migration', title: 'Workload ID Migration to Agent ID', videoId: 'P34pqLKWH88', durationSeconds: 389 },
        ],
    },
    {
        id: 'secure-ai-authentication',
        title: 'Secure AI Authentication and Access',
        introduction: 'Consider how agent identities authenticate, receive access, and remain governed.',
        discussion: 'How are agent permissions granted, reviewed, and removed when ownership or business needs change?',
        lessons: [
            { id: 'access', title: 'Access', videoId: '_Ja51-0LVy0', durationSeconds: 900 },
            { id: 'identity-governance', title: 'Identity Governance', videoId: 'oUBW4DYVnvA', durationSeconds: 244 },
        ],
    },
    {
        id: 'secure-ai-network',
        title: 'Secure AI Network Access',
        introduction: 'Explore network readiness, destination controls, and prompt and content protection.',
        discussion: 'Which network paths, AI destinations, and prompt inspection controls apply to agent traffic?',
        lessons: [
            { id: 'network-security-readiness', title: 'Network Security Readiness', videoId: 'TrskCxNNgiE', durationSeconds: 187 },
            { id: 'web-destination-control', title: 'Web & Destination Control', videoId: 'TAO6uk2ksMU', durationSeconds: 58 },
            { id: 'prompt-content-protection', title: 'Prompt & Content Protection', videoId: '9ZhoV8dzZBc', durationSeconds: 132 },
        ],
    },
    {
        id: 'secure-ai-data',
        title: 'Secure AI Data Access',
        introduction: 'Explore data access readiness, AI usage monitoring, and controls for data loss and insider risk.',
        discussion: 'What sensitive data can AI access, and how are oversharing, data loss, and risky usage addressed?',
        lessons: [
            { id: 'data-access-readiness', title: 'Data Access Readiness', videoId: 'tCgBYrQqI-8', durationSeconds: 348 },
            { id: 'ai-data-usage-monitoring', title: 'AI Data Usage Monitoring', videoId: '6fKLT6O4NLE', durationSeconds: 143 },
            { id: 'data-loss-prevention', title: 'Data Loss Prevention', videoId: 'CghlABVbgRY', durationSeconds: 348 },
            { id: 'insider-risk-management', title: 'Insider Risk Management', videoId: 'g0aKWuu_ktY', durationSeconds: 67 },
        ],
    },
    {
        id: 'build-agents-securely',
        title: 'Build Agents Securely',
        introduction: 'Explore security requirements for agent development, platforms, MCP servers, and validation.',
        discussion: 'Which security requirements and approval gates must an agent meet before deployment?',
        lessons: [
            { id: 'agent-development-readiness', title: 'Agent Development Readiness', videoId: '8i4C3zs_a6Y', durationSeconds: 455 },
            { id: 'agent-platform-controls', title: 'Agent Platform Controls', videoId: 'dJ_2CdPKxiA', durationSeconds: 28 },
            { id: 'mcp-server-governance', title: 'MCP Server Governance', videoId: 'JbYr5ijo9Hc', durationSeconds: 64 },
            { id: 'enterprise-compliance-integration', title: 'Enterprise Compliance Integration', videoId: null },
            { id: 'security-validation', title: 'Security Validation', videoId: 'pZzzoluFlt0', durationSeconds: 91 },
        ],
    },
    {
        id: 'ai-threat-protection',
        title: 'AI Threat Protection, Detection, & Response',
        introduction: 'Explore AI risk assessment and the processes for detecting and responding to AI threats.',
        discussion: 'How are AI risks prioritized, and who investigates and responds to AI-related alerts?',
        lessons: [
            { id: 'assess-ai-risk', title: 'Assess AI Risk', videoId: 'wTVTWFVBV48', durationSeconds: 244 },
            { id: 'ai-threat-detection-response', title: 'AI Threat Detection & Response', videoId: 'E149ztL7OwY', durationSeconds: 154 },
        ],
    },
];

export const lessons = focusAreas.flatMap(area =>
    area.lessons.map(lesson => ({ ...lesson, focusArea: area })),
);

export function lessonHash(lesson) {
    return `#lesson-${lesson.id}`;
}

export function findLesson(hash) {
    return hash ? lessons.find(lesson => lessonHash(lesson) === hash) : lessons[0];
}

export function totalDuration(items) {
    return items.filter(lesson => lesson.videoId).reduce((total, lesson) => total + lesson.durationSeconds, 0);
}

export function formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor(seconds / 60) % 60;
    const remainder = String(seconds % 60).padStart(2, '0');
    return hours
        ? `${hours}:${String(minutes).padStart(2, '0')}:${remainder}`
        : `${minutes}:${remainder}`;
}

export function durationLabel(seconds) {
    const hours = Math.floor(seconds / 3600);
    return `${hours ? `${hours} hr ` : ''}${Math.floor(seconds / 60) % 60} min ${seconds % 60} sec`;
}

export function formatTotalDuration(seconds) {
    const minutes = Math.floor(seconds / 60);
    return minutes >= 60
        ? `${Math.floor(minutes / 60)} hr ${minutes % 60} min`
        : `${minutes} min`;
}
