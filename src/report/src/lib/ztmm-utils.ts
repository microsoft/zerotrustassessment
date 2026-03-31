import { Test } from "@/config/report-data";

// Maturity levels in order (lowest to highest)
export const MATURITY_LEVELS = ['Initial', 'Optimal', 'Advanced'] as const;
export type MaturityLevel = typeof MATURITY_LEVELS[number];

// Pillar names
export const PILLAR_NAMES = ['Identity', 'Devices', 'Network', 'Data'] as const;
export type PillarName = typeof PILLAR_NAMES[number];

/**
 * Returns Tailwind CSS classes for a maturity level badge.
 */
export function getMaturityColor(maturity: string): string {
    switch (maturity) {
        case 'Initial':
            return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
        case 'Optimal':
            return 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200';
        case 'Advanced':
            return 'bg-green-600 text-white dark:bg-green-700 dark:text-green-100';
        default:
            return 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200';
    }
}

/**
 * Returns the hex color for a maturity level (for charts).
 */
export function getMaturityChartColor(maturity: string): string {
    switch (maturity) {
        case 'Initial':
            return '#eab308'; // yellow-500
        case 'Optimal':
            return '#f97316'; // orange-500
        case 'Advanced':
            return '#16a34a'; // green-600
        default:
            return '#6b7280'; // gray-500
    }
}

/**
 * Returns a lighter tint hex color for a maturity level (for "failed" portions in charts).
 */
export function getMaturityChartColorLight(maturity: string): string {
    switch (maturity) {
        case 'Initial':
            return '#fde047'; // yellow-300
        case 'Optimal':
            return '#fdba74'; // orange-300
        case 'Advanced':
            return '#86efac'; // green-300
        default:
            return '#9ca3af'; // gray-400
    }
}

/**
 * Computes maturity statistics for a set of tests, grouped by pillar.
 */
export interface MaturityStats {
    pillar: string;
    initial: { passed: number; total: number };
    advanced: { passed: number; total: number };
    optimal: { passed: number; total: number };
}

export function computeMaturityStatsByPillar(tests: Test[]): MaturityStats[] {
    const pillars = PILLAR_NAMES as readonly string[];

    return pillars.map(pillar => {
        const pillarTests = tests.filter(t => t.TestPillar === pillar && t.ZtmmMaturity);
        const stats: MaturityStats = {
            pillar,
            initial: { passed: 0, total: 0 },
            advanced: { passed: 0, total: 0 },
            optimal: { passed: 0, total: 0 },
        };

        for (const test of pillarTests) {
            const level = test.ZtmmMaturity?.toLowerCase() as 'initial' | 'advanced' | 'optimal';
            if (level && stats[level]) {
                stats[level].total++;
                if (test.TestStatus === 'Passed') {
                    stats[level].passed++;
                }
            }
        }

        return stats;
    });
}

/**
 * Computes maturity stats grouped by ZTMM function within a given pillar.
 */
export interface FunctionMaturityStats {
    functionId: string;
    functionName: string;
    initial: { passed: number; total: number };
    advanced: { passed: number; total: number };
    optimal: { passed: number; total: number };
}

export function computeMaturityStatsByFunction(tests: Test[], pillar?: string): FunctionMaturityStats[] {
    const filtered = pillar ? tests.filter(t => t.TestPillar === pillar) : tests;
    const functionMap = new Map<string, FunctionMaturityStats>();

    for (const test of filtered) {
        if (!test.ZtmmFunction || !test.ZtmmFunctionName || !test.ZtmmMaturity) continue;

        const key = test.ZtmmFunction;
        if (!functionMap.has(key)) {
            functionMap.set(key, {
                functionId: test.ZtmmFunction,
                functionName: test.ZtmmFunctionName,
                initial: { passed: 0, total: 0 },
                advanced: { passed: 0, total: 0 },
                optimal: { passed: 0, total: 0 },
            });
        }

        const stat = functionMap.get(key)!;
        const level = test.ZtmmMaturity.toLowerCase() as 'initial' | 'advanced' | 'optimal';
        if (stat[level]) {
            stat[level].total++;
            if (test.TestStatus === 'Passed') {
                stat[level].passed++;
            }
        }
    }

    return Array.from(functionMap.values()).sort((a, b) => a.functionId.localeCompare(b.functionId));
}

/**
 * Calculate overall maturity score for a pillar (0-100).
 * Weighted: Initial=1pt, Optimal=2pts, Advanced=3pts.
 */
export function computeMaturityScore(stats: MaturityStats): number {
    const totalWeight =
        stats.initial.total * 1 +
        stats.optimal.total * 2 +
        stats.advanced.total * 3;

    if (totalWeight === 0) return 0;

    const earnedWeight =
        stats.initial.passed * 1 +
        stats.optimal.passed * 2 +
        stats.advanced.passed * 3;

    return Math.round((earnedWeight / totalWeight) * 100);
}

/**
 * Determine the "current maturity level" string based on completion thresholds.
 * Order: Initial (lowest) → Optimal → Advanced (highest).
 * - Advanced if >= 80% of Advanced tests passed
 * - Optimal if >= 80% of Optimal tests passed
 * - Initial if >= 80% of Initial tests passed
 * - "Below Initial" otherwise
 */
export function getCurrentMaturityLevel(stats: MaturityStats): string {
    const threshold = 0.8;

    const initialPct = stats.initial.total > 0 ? stats.initial.passed / stats.initial.total : 0;
    const advancedPct = stats.advanced.total > 0 ? stats.advanced.passed / stats.advanced.total : 0;
    const optimalPct = stats.optimal.total > 0 ? stats.optimal.passed / stats.optimal.total : 0;

    if (stats.advanced.total > 0 && advancedPct >= threshold) return 'Advanced';
    if (stats.optimal.total > 0 && optimalPct >= threshold) return 'Optimal';
    if (stats.initial.total > 0 && initialPct >= threshold) return 'Initial';
    return 'Below Initial';
}

/**
 * Determine the maturity level based on pass-rate distribution.
 * - Default = Initial
 * - If %Optimal > %Initial → Optimal
 * - If %Advanced > %Optimal AND %Optimal > %Initial → Advanced
 * - If %Advanced > %Optimal BUT %Optimal ≤ %Initial → Optimal (capped)
 */
export function determineMaturityLevel(stats: MaturityStats): MaturityLevel {
    const pctInitial = stats.initial.total > 0 ? stats.initial.passed / stats.initial.total : 0;
    const pctOptimal = stats.optimal.total > 0 ? stats.optimal.passed / stats.optimal.total : 0;
    const pctAdvanced = stats.advanced.total > 0 ? stats.advanced.passed / stats.advanced.total : 0;

    if (pctAdvanced > pctOptimal && pctOptimal > pctInitial) return 'Advanced';
    if (pctAdvanced > pctOptimal && pctOptimal <= pctInitial) return 'Optimal';
    if (pctOptimal > pctInitial) return 'Optimal';
    return 'Initial';
}

/**
 * Determine overall tenant maturity by aggregating all pillar stats.
 */
export function determineOverallMaturityLevel(allStats: MaturityStats[]): MaturityLevel {
    const totals = {
        initial: { passed: 0, total: 0 },
        optimal: { passed: 0, total: 0 },
        advanced: { passed: 0, total: 0 },
    };
    for (const s of allStats) {
        totals.initial.passed += s.initial.passed;
        totals.initial.total += s.initial.total;
        totals.optimal.passed += s.optimal.passed;
        totals.optimal.total += s.optimal.total;
        totals.advanced.passed += s.advanced.passed;
        totals.advanced.total += s.advanced.total;
    }
    return determineMaturityLevel({ pillar: 'Overall', ...totals });
}

/**
 * Interpolate between orange-100 (#ffedd5) and orange-700 (#c2410c)
 * based on a 0-1 ratio. Returns an rgb() CSS string.
 * Used for continuous heatmap / progress bar gradients.
 */
export function interpolateGreen(ratio: number): string {
    const t = Math.max(0, Math.min(1, ratio));
    const r = Math.round(0xff + (0xc2 - 0xff) * t);
    const g = Math.round(0xed + (0x41 - 0xed) * t);
    const b = Math.round(0xd5 + (0x0c - 0xd5) * t);
    return `rgb(${r}, ${g}, ${b})`;
}
