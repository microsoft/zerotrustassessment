import { reportData } from "@/config/report-data"
import {
    computeMaturityStatsByPillar,
    computeMaturityScore,
    getMaturityChartColor,
} from "@/lib/ztmm-utils"
import {
    RadialBarChart,
    RadialBar,
    PolarAngleAxis,
} from "recharts"
import { ChartContainer } from "@/components/ui/chart"

export function MaturityScoreGauges() {
    const stats = computeMaturityStatsByPillar(reportData.Tests)
    const activePillars = stats.filter(s => s.initial.total + s.advanced.total + s.optimal.total > 0)

    if (activePillars.length === 0) return null

    return (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {activePillars.map((s) => {
                const score = computeMaturityScore(s)
                const color = score >= 70 ? getMaturityChartColor('Advanced')
                    : score >= 40 ? getMaturityChartColor('Optimal')
                    : getMaturityChartColor('Initial')

                return (
                    <div key={s.pillar} className="flex flex-col items-center gap-1">
                        <ChartContainer
                            config={{
                                score: { label: s.pillar, color: color },
                            }}
                            className="w-full aspect-square max-w-[140px]"
                        >
                            <RadialBarChart
                                data={[{ value: score, fill: color }]}
                                startAngle={180}
                                endAngle={0}
                                innerRadius="70%"
                                outerRadius="100%"
                                barSize={12}
                            >
                                <PolarAngleAxis
                                    type="number"
                                    domain={[0, 100]}
                                    dataKey="value"
                                    tick={false}
                                />
                                <RadialBar dataKey="value" background cornerRadius={6} />
                                <text
                                    x="50%"
                                    y="50%"
                                    textAnchor="middle"
                                    dominantBaseline="middle"
                                    className="fill-foreground text-2xl font-bold"
                                >
                                    {score}
                                </text>
                            </RadialBarChart>
                        </ChartContainer>
                        <span className="text-sm font-medium -mt-4">{s.pillar}</span>
                    </div>
                )
            })}
        </div>
    )
}
