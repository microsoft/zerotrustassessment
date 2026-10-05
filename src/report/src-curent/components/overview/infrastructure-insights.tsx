import { useId, useState } from "react";
import { Gauge } from "lucide-react";
import { Cell, Pie, PieChart } from "recharts";
import type { CloudSecureScore } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer } from "@/components/ui/chart";

export { RecommendationsBySeverity } from "../../../src/components/overview/infrastructure-insights";

export function CloudSecureScoreCard({ data }: { data?: CloudSecureScore[] | null }) {
    const [environment, setEnvironment] = useState("All");
    const selectId = useId();
    const scores = Array.isArray(data) ? data.filter((score) =>
        typeof score.percentage === "number" && Number.isFinite(score.percentage) && score.percentage >= 0 && score.percentage <= 100
    ) : [];
    const selected = scores.find((score) => score.environment === environment) ?? scores[0];
    const percentage = selected?.percentage;

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
                        <select id={selectId} value={selected?.environment} onChange={(event) => setEnvironment(event.target.value)} className="min-w-0 rounded-md border bg-background px-2 py-1">
                            {scores.map((score) => (
                                <option key={score.environment} value={score.environment}>{score.environment}</option>
                            ))}
                        </select>
                    </div>
                )}
                {typeof percentage === "number" ? (
                    <div className="relative mx-auto aspect-square w-full max-w-[240px]" role="img" aria-label={`${selected.environment} cloud secure score: ${percentage}%`}>
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