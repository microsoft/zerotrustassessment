import { useId, useState } from "react";
import { Gauge, ListChecks } from "lucide-react";
import { Cell, Pie, PieChart } from "recharts";
import type { CloudSecureScore, Test } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer } from "@/components/ui/chart";

const severities = [
    { label: "Critical", color: "#a4262c" },
    { label: "High", color: "#d13438" },
    { label: "Medium", color: "#f7630c" },
    { label: "Low", color: "#c19c00" },
    { label: "Unranked", color: "#737373" },
];

export function RecommendationsBySeverity({ tests }: { tests: Test[] }) {
    const recommendations = tests.filter((test) =>
        (Array.isArray(test.TestPillar) ? test.TestPillar.includes("Infrastructure") : test.TestPillar === "Infrastructure")
        && (test.TestStatus === "Failed" || test.TestStatus === "Passed")
    );
    const failed = recommendations.filter((test) => test.TestStatus === "Failed");
    const counts = severities.map((severity) => ({
        ...severity,
        count: failed.filter((test) =>
            severity.label === "Unranked"
                ? !severities.slice(0, 4).some(({ label }) => label === test.TestRisk)
                : test.TestRisk === severity.label
        ).length,
    })).filter(({ label, count }) => label !== "Unranked" || count > 0);
    const maximum = Math.max(1, ...counts.map(({ count }) => count));

    return (
        <Card className="mb-6 w-full min-w-0 overflow-hidden">
            <CardHeader className="flex-row items-start gap-3 space-y-0">
                <ListChecks className="mt-0.5 size-6 shrink-0" />
                <div className="min-w-0 space-y-1">
                    <CardTitle className="text-xl tracking-normal">Recommendations by severity</CardTitle>
                    <CardDescription>Open Microsoft Defender for Cloud recommendations in the scanned environment.</CardDescription>
                </div>
            </CardHeader>
            <CardContent>
                {recommendations.length === 0 ? (
                    <p className="flex min-h-40 items-center justify-center text-sm text-muted-foreground">No evaluated recommendations available</p>
                ) : (
                    <>
                        {failed.length === 0 && <p className="mb-4 text-sm text-muted-foreground">No open recommendations</p>}
                        <div className="space-y-3" aria-label="Open recommendations by severity">
                            {counts.map(({ label, color, count }) => (
                                <div key={label} className="grid min-h-8 grid-cols-[4.5rem_minmax(0,1fr)_4rem] items-center gap-3">
                                    <span className="text-sm text-muted-foreground">{label}</span>
                                    <div className="h-8 overflow-hidden rounded" aria-hidden="true">
                                        <div className="h-full rounded" style={{ width: `${count / maximum * 100}%`, backgroundColor: color }} />
                                    </div>
                                    <span className="text-xs tabular-nums">{count} ({failed.length > 0 ? Math.round(count / failed.length * 100) : 0}%)</span>
                                </div>
                            ))}
                        </div>
                    </>
                )}
            </CardContent>
            {recommendations.length > 0 && (
                <CardFooter className="flex flex-wrap gap-y-4 border-t px-0 py-4">
                    {counts.map(({ label, count }) => (
                        <div key={label} className="min-w-24 flex-1 border-r px-4 last:border-r-0">
                            <div className="text-xs text-muted-foreground">{label}</div>
                            <div className="text-2xl font-semibold tabular-nums">{count}</div>
                        </div>
                    ))}
                </CardFooter>
            )}
        </Card>
    );
}

export function CloudSecureScoreCard({ data }: { data?: CloudSecureScore[] | null }) {
    const [environment, setEnvironment] = useState("All");
    const selectId = useId();
    const scores = Array.isArray(data) ? data : [];
    const selected = scores.find((score) => score.environment === environment);
    const percentage = selected?.percentage;
    const available = typeof percentage === "number" && Number.isFinite(percentage) && percentage >= 0 && percentage <= 100;

    return (
        <Card className="flex h-full w-full min-w-0 flex-col">
            <CardHeader className="flex-row items-start gap-3 space-y-0">
                <Gauge className="mt-0.5 size-6 shrink-0" />
                <div className="min-w-0 space-y-1">
                    <CardTitle className="text-xl tracking-normal">Cloud secure score</CardTitle>
                    <CardDescription>Microsoft Defender for Cloud secure score</CardDescription>
                </div>
            </CardHeader>
            <CardContent className="flex flex-1 flex-col items-center gap-4">
                {scores.length > 0 && (
                    <div className="flex max-w-full items-center gap-2 text-sm">
                        <label htmlFor={selectId}>Environment</label>
                        <select id={selectId} value={environment} onChange={(event) => setEnvironment(event.target.value)} className="min-w-0 rounded-md border bg-background px-2 py-1">
                            <option value="All">All</option>
                            {scores.filter((score) => score.environment !== "All").map((score) => (
                                <option key={score.environment} value={score.environment}>{score.environment}</option>
                            ))}
                        </select>
                    </div>
                )}
                {available ? (
                    <div className="relative mx-auto aspect-square w-full max-w-[240px]" role="img" aria-label={`${environment} cloud secure score: ${percentage}%`}>
                        <ChartContainer config={{ score: { label: "Secure score", color: "#107c10" } }} className="aspect-square h-full w-full">
                            <PieChart>
                                <Pie data={[{ value: percentage }, { value: 100 - percentage }]} dataKey="value" innerRadius="65%" outerRadius="95%" startAngle={90} endAngle={-270} strokeWidth={0} isAnimationActive={false}>
                                    <Cell fill="var(--color-score)" />
                                    <Cell fill="hsl(var(--muted))" />
                                </Pie>
                            </PieChart>
                        </ChartContainer>
                        <div className="pointer-events-none absolute inset-0 flex items-center justify-center text-3xl font-semibold tabular-nums">{percentage}%</div>
                    </div>
                ) : (
                    <p className="flex min-h-48 items-center text-sm text-muted-foreground">No secure score available</p>
                )}
            </CardContent>
        </Card>
    );
}
