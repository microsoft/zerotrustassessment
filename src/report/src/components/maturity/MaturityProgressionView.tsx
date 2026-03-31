import { reportData } from "@/config/report-data"
import {
    computeMaturityStatsByPillar,
    getMaturityChartColor,
} from "@/lib/ztmm-utils"

export function MaturityProgressionView() {
    const stats = computeMaturityStatsByPillar(reportData.Tests)
    const activePillars = stats.filter(s => s.initial.total + s.advanced.total + s.optimal.total > 0)

    if (activePillars.length === 0) return null

    return (
        <div className="space-y-4">
            {activePillars.map((s) => {
                const initialPct = s.initial.total > 0 ? Math.round((s.initial.passed / s.initial.total) * 100) : 0
                const advancedPct = s.advanced.total > 0 ? Math.round((s.advanced.passed / s.advanced.total) * 100) : 0
                const optimalPct = s.optimal.total > 0 ? Math.round((s.optimal.passed / s.optimal.total) * 100) : 0

                return (
                    <div key={s.pillar} className="space-y-1.5">
                        <div className="flex items-center justify-between">
                            <span className="text-sm font-medium">{s.pillar}</span>
                        </div>
                        <div className="flex gap-1 h-7">
                            {/* Initial segment */}
                            <div className="flex-1 relative rounded-l-md overflow-hidden bg-muted">
                                <div
                                    className="absolute inset-y-0 left-0 rounded-l-md transition-all"
                                    style={{
                                        width: `${initialPct}%`,
                                        backgroundColor: getMaturityChartColor('Initial'),
                                        opacity: 0.8,
                                    }}
                                />
                                <div className="absolute inset-0 flex items-center justify-center text-xs font-medium">
                                    <span className={initialPct > 40 ? 'text-white' : ''}>
                                        Initial {initialPct}%
                                    </span>
                                </div>
                            </div>
                            {/* Optimal segment */}
                            <div className="flex-1 relative overflow-hidden bg-muted">
                                <div
                                    className="absolute inset-y-0 left-0 transition-all"
                                    style={{
                                        width: `${optimalPct}%`,
                                        backgroundColor: getMaturityChartColor('Optimal'),
                                        opacity: 0.8,
                                    }}
                                />
                                <div className="absolute inset-0 flex items-center justify-center text-xs font-medium">
                                    <span className={optimalPct > 40 ? 'text-white' : ''}>
                                        Optimal {optimalPct}%
                                    </span>
                                </div>
                            </div>
                            {/* Advanced segment */}
                            <div className="flex-1 relative rounded-r-md overflow-hidden bg-muted">
                                <div
                                    className="absolute inset-y-0 left-0 rounded-r-md transition-all"
                                    style={{
                                        width: `${advancedPct}%`,
                                        backgroundColor: getMaturityChartColor('Advanced'),
                                        opacity: 0.8,
                                    }}
                                />
                                <div className="absolute inset-0 flex items-center justify-center text-xs font-medium">
                                    <span className={advancedPct > 40 ? 'text-white' : ''}>
                                        Advanced {advancedPct}%
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                )
            })}

            {/* Legend */}
            <div className="flex gap-4 pt-2 justify-center">
                {(['Initial', 'Optimal', 'Advanced'] as const).map(level => (
                    <div key={level} className="flex items-center gap-1.5">
                        <div
                            className="w-3 h-3 rounded-sm"
                            style={{ backgroundColor: getMaturityChartColor(level) }}
                        />
                        <span className="text-xs text-muted-foreground">{level}</span>
                    </div>
                ))}
            </div>
        </div>
    )
}
