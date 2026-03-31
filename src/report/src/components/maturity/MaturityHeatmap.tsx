import { Test } from "@/config/report-data"
import { computeMaturityStatsByFunction, getMaturityChartColor, interpolateGreen } from "@/lib/ztmm-utils"

interface MaturityHeatmapProps {
    tests: Test[]
    pillar?: string
}

export function MaturityHeatmap({ tests, pillar }: MaturityHeatmapProps) {
    const stats = computeMaturityStatsByFunction(tests, pillar)

    if (stats.length === 0) return null

    const getCellStyle = (passed: number, total: number): React.CSSProperties => {
        if (total === 0) return {}
        const pct = passed / total
        return {
            backgroundColor: interpolateGreen(pct),
            color: pct >= 0.45 ? 'white' : 'inherit',
        }
    }

    const getCellClass = (total: number): string => {
        if (total === 0) return 'bg-muted'
        return ''
    }

    return (
        <div className="overflow-x-auto">
            <table className="w-full text-sm">
                <thead>
                    <tr className="border-b">
                        <th className="text-left py-2 px-3 font-medium">Function</th>
                        <th className="text-center py-2 px-3 font-medium w-28">
                            <div className="flex items-center justify-center gap-1">
                                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: getMaturityChartColor('Initial') }} />
                                Initial
                            </div>
                        </th>
                        <th className="text-center py-2 px-3 font-medium w-28">
                            <div className="flex items-center justify-center gap-1">
                                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: getMaturityChartColor('Optimal') }} />
                                Optimal
                            </div>
                        </th>
                        <th className="text-center py-2 px-3 font-medium w-28">
                            <div className="flex items-center justify-center gap-1">
                                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: getMaturityChartColor('Advanced') }} />
                                Advanced
                            </div>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {stats.map((s) => (
                        <tr key={s.functionId} className="border-b">
                            <td className="py-2 px-3">
                                <span className="text-xs text-muted-foreground mr-1">{s.functionId}</span>
                                {s.functionName}
                            </td>
                            <td className="py-2 px-2">
                                {s.initial.total > 0 ? (
                                    <div
                                        className={`text-center rounded-md py-1.5 text-xs font-medium ${getCellClass(s.initial.total)}`}
                                        style={getCellStyle(s.initial.passed, s.initial.total)}
                                    >
                                        {s.initial.passed}/{s.initial.total}
                                    </div>
                                ) : (
                                    <div className="text-center text-muted-foreground text-xs">--</div>
                                )}
                            </td>
                            <td className="py-2 px-2">
                                {s.optimal.total > 0 ? (
                                    <div
                                        className={`text-center rounded-md py-1.5 text-xs font-medium ${getCellClass(s.optimal.total)}`}
                                        style={getCellStyle(s.optimal.passed, s.optimal.total)}
                                    >
                                        {s.optimal.passed}/{s.optimal.total}
                                    </div>
                                ) : (
                                    <div className="text-center text-muted-foreground text-xs">--</div>
                                )}
                            </td>
                            <td className="py-2 px-2">
                                {s.advanced.total > 0 ? (
                                    <div
                                        className={`text-center rounded-md py-1.5 text-xs font-medium ${getCellClass(s.advanced.total)}`}
                                        style={getCellStyle(s.advanced.passed, s.advanced.total)}
                                    >
                                        {s.advanced.passed}/{s.advanced.total}
                                    </div>
                                ) : (
                                    <div className="text-center text-muted-foreground text-xs">--</div>
                                )}
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            {/* Legend */}
            <div className="flex items-center gap-2 pt-3 justify-center text-xs text-muted-foreground">
                <span>0%</span>
                <div
                    className="w-32 h-3 rounded-sm"
                    style={{ background: `linear-gradient(to right, ${interpolateGreen(0)}, ${interpolateGreen(0.5)}, ${interpolateGreen(1)})` }}
                />
                <span>100% passed</span>
            </div>
        </div>
    )
}
