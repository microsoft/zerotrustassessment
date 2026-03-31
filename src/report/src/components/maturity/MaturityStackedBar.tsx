import { Test } from "@/config/report-data"
import { computeMaturityStatsByFunction, getMaturityChartColor, getMaturityChartColorLight } from "@/lib/ztmm-utils"
import {
    Bar,
    BarChart,
    XAxis,
    YAxis,
    CartesianGrid,
    Legend,
} from "recharts"
import {
    ChartContainer,
    ChartTooltip,
    ChartTooltipContent,
} from "@/components/ui/chart"

interface MaturityStackedBarProps {
    tests: Test[]
    pillar?: string
    className?: string
}

export function MaturityStackedBar({ tests, pillar, className }: MaturityStackedBarProps) {
    const stats = computeMaturityStatsByFunction(tests, pillar)

    if (stats.length === 0) return null

    const chartData = stats.map(s => ({
        name: s.functionName,
        'Initial Passed': s.initial.passed,
        'Initial Failed': s.initial.total - s.initial.passed,
        'Optimal Passed': s.optimal.passed,
        'Optimal Failed': s.optimal.total - s.optimal.passed,
        'Advanced Passed': s.advanced.passed,
        'Advanced Failed': s.advanced.total - s.advanced.passed,
    }))

    return (
        <ChartContainer
            config={{
                'Initial Passed': { label: 'Initial Passed', color: getMaturityChartColor('Initial') },
                'Initial Failed': { label: 'Initial Failed', color: getMaturityChartColorLight('Initial') },
                'Optimal Passed': { label: 'Optimal Passed', color: getMaturityChartColor('Optimal') },
                'Optimal Failed': { label: 'Optimal Failed', color: getMaturityChartColorLight('Optimal') },
                'Advanced Passed': { label: 'Advanced Passed', color: getMaturityChartColor('Advanced') },
                'Advanced Failed': { label: 'Advanced Failed', color: getMaturityChartColorLight('Advanced') },
            }}
            className={className}
        >
            <BarChart
                data={chartData}
                margin={{ top: 10, right: 10, left: 10, bottom: 0 }}
                layout="vertical"
            >
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" />
                <YAxis
                    type="category"
                    dataKey="name"
                    width={120}
                    tick={{ fontSize: 11 }}
                />
                <ChartTooltip
                    content={<ChartTooltipContent />}
                />
                <Legend wrapperStyle={{ fontSize: '11px' }} />
                <Bar dataKey="Initial Passed" stackId="initial" fill={getMaturityChartColor('Initial')} />
                <Bar dataKey="Initial Failed" stackId="initial" fill={getMaturityChartColorLight('Initial')} fillOpacity={0.5} />
                <Bar dataKey="Optimal Passed" stackId="optimal" fill={getMaturityChartColor('Optimal')} />
                <Bar dataKey="Optimal Failed" stackId="optimal" fill={getMaturityChartColorLight('Optimal')} fillOpacity={0.5} />
                <Bar dataKey="Advanced Passed" stackId="advanced" fill={getMaturityChartColor('Advanced')} />
                <Bar dataKey="Advanced Failed" stackId="advanced" fill={getMaturityChartColorLight('Advanced')} fillOpacity={0.5} />
            </BarChart>
        </ChartContainer>
    )
}
