import { reportData } from "@/config/report-data"
import {
    computeMaturityStatsByPillar,
    computeMaturityScore,
    getCurrentMaturityLevel,
    getMaturityColor,
    interpolateGreen,
} from "@/lib/ztmm-utils"

export function MaturitySummaryTable() {
    const stats = computeMaturityStatsByPillar(reportData.Tests)
    const activePillars = stats.filter(s => s.initial.total + s.advanced.total + s.optimal.total > 0)

    if (activePillars.length === 0) return null

    const pct = (passed: number, total: number) => {
        if (total === 0) return null
        return Math.round((passed / total) * 100)
    }

    const renderCell = (passed: number, total: number) => {
        const p = pct(passed, total)
        if (p === null) return <span className="text-muted-foreground text-xs">--</span>
        return (
            <div className="flex flex-col items-center gap-1">
                <div className="w-full bg-muted rounded-full h-2">
                    <div
                        className="h-2 rounded-full"
                        style={{ width: `${p}%`, backgroundColor: interpolateGreen(p / 100) }}
                    />
                </div>
                <span className="text-xs tabular-nums">
                    {passed}/{total} ({p}%)
                </span>
            </div>
        )
    }

    return (
        <div className="overflow-x-auto">
            <table className="w-full text-sm">
                <thead>
                    <tr className="border-b">
                        <th className="text-left py-2 px-3 font-medium">Pillar</th>
                        <th className="text-center py-2 px-3 font-medium">
                            <span className="px-2 py-0.5 text-xs rounded-md bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">Initial</span>
                        </th>
                        <th className="text-center py-2 px-3 font-medium">
                            <span className="px-2 py-0.5 text-xs rounded-md bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200">Optimal</span>
                        </th>
                        <th className="text-center py-2 px-3 font-medium">
                            <span className="px-2 py-0.5 text-xs rounded-md bg-green-600 text-white dark:bg-green-700 dark:text-green-100">Advanced</span>
                        </th>
                        <th className="text-center py-2 px-3 font-medium">Score</th>
                        <th className="text-center py-2 px-3 font-medium">Current Level</th>
                    </tr>
                </thead>
                <tbody>
                    {activePillars.map((s) => {
                        const score = computeMaturityScore(s)
                        const level = getCurrentMaturityLevel(s)
                        return (
                            <tr key={s.pillar} className="border-b hover:bg-muted/50">
                                <td className="py-3 px-3 font-medium">{s.pillar}</td>
                                <td className="py-3 px-3 min-w-[120px]">{renderCell(s.initial.passed, s.initial.total)}</td>
                                <td className="py-3 px-3 min-w-[120px]">{renderCell(s.optimal.passed, s.optimal.total)}</td>
                                <td className="py-3 px-3 min-w-[120px]">{renderCell(s.advanced.passed, s.advanced.total)}</td>
                                <td className="py-3 px-3 text-center">
                                    <span className="text-lg font-bold tabular-nums">{score}</span>
                                    <span className="text-xs text-muted-foreground">/100</span>
                                </td>
                                <td className="py-3 px-3 text-center">
                                    <span className={`px-2 py-1 text-xs font-medium rounded-md ${getMaturityColor(level)}`}>
                                        {level}
                                    </span>
                                </td>
                            </tr>
                        )
                    })}
                </tbody>
            </table>
        </div>
    )
}
