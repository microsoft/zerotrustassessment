import {
    Radar,
    RadarChart,
    PolarGrid,
    PolarAngleAxis,
    PolarRadiusAxis,
} from "recharts"
import {
    ChartContainer,
    ChartTooltip,
    ChartTooltipContent,
} from "@/components/ui/chart"
import { reportData } from "@/config/report-data"
import { computeMaturityStatsByPillar, getMaturityChartColor } from "@/lib/ztmm-utils"

interface MaturityRadarProps {
    className?: string
}

export function MaturityRadar({ className }: MaturityRadarProps) {
    const stats = computeMaturityStatsByPillar(reportData.Tests)

    const radarData = stats
        .filter(s => s.initial.total + s.advanced.total + s.optimal.total > 0)
        .map(s => ({
            pillar: s.pillar,
            Initial: s.initial.total > 0 ? Math.round((s.initial.passed / s.initial.total) * 100) : 0,
            Advanced: s.advanced.total > 0 ? Math.round((s.advanced.passed / s.advanced.total) * 100) : 0,
            Optimal: s.optimal.total > 0 ? Math.round((s.optimal.passed / s.optimal.total) * 100) : 0,
        }))

    if (radarData.length === 0) return null

    return (
        <ChartContainer
            config={{
                Initial: { label: "Initial", color: getMaturityChartColor('Initial') },
                Optimal: { label: "Optimal", color: getMaturityChartColor('Optimal') },
                Advanced: { label: "Advanced", color: getMaturityChartColor('Advanced') },
            }}
            className={className}
        >
            <RadarChart data={radarData} cx="50%" cy="50%" outerRadius="70%">
                <PolarGrid />
                <PolarAngleAxis dataKey="pillar" className="text-xs" />
                <PolarRadiusAxis angle={90} domain={[0, 100]} tick={false} />
                <Radar
                    name="Initial"
                    dataKey="Initial"
                    stroke={getMaturityChartColor('Initial')}
                    fill={getMaturityChartColor('Initial')}
                    fillOpacity={0.15}
                    strokeWidth={2}
                />
                <Radar
                    name="Optimal"
                    dataKey="Optimal"
                    stroke={getMaturityChartColor('Optimal')}
                    fill={getMaturityChartColor('Optimal')}
                    fillOpacity={0.15}
                    strokeWidth={2}
                />
                <Radar
                    name="Advanced"
                    dataKey="Advanced"
                    stroke={getMaturityChartColor('Advanced')}
                    fill={getMaturityChartColor('Advanced')}
                    fillOpacity={0.15}
                    strokeWidth={2}
                />
                <ChartTooltip
                    content={
                        <ChartTooltipContent
                            labelFormatter={(label) => `${label} Pillar`}
                            formatter={(value, name) => [
                                `${value}%`,
                                `${name}`,
                            ]}
                        />
                    }
                />
            </RadarChart>
        </ChartContainer>
    )
}
