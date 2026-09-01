import { ShieldAlert, TriangleAlert } from "lucide-react";

import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import type { DlpWorkloadCoverage } from "@/config/report-data";

interface DlpWorkloadCoverageCardProps {
    data?: DlpWorkloadCoverage | null;
}

const workloadFields = [
    ["Exchange", "exchangePolicyCount"],
    ["SharePoint", "sharePointPolicyCount"],
    ["OneDrive", "oneDrivePolicyCount"],
    ["Teams", "teamsPolicyCount"],
    ["Endpoint", "endpointPolicyCount"],
    ["Copilot", "copilotPolicyCount"],
] as const;

export function DlpWorkloadCoverageCard({ data }: DlpWorkloadCoverageCardProps) {
    const counts = data
        ? workloadFields.map(([label, field]) => ({ label, value: data[field] }))
        : [];
    const hasValidData = counts.length === workloadFields.length && counts.every(({ value }) =>
        Number.isInteger(value) && value >= 0
    );

    if (!hasValidData) {
        return (
            <Card className="w-full max-w-xl">
                <CardHeader className="flex-row items-start gap-3 space-y-0">
                    <ShieldAlert className="mt-0.5 size-7 shrink-0" />
                    <div className="space-y-1">
                        <CardTitle className="text-2xl">DLP coverage by workload</CardTitle>
                        <CardDescription>Number of DLP policies targeting each workload.</CardDescription>
                    </div>
                </CardHeader>
                <CardContent>
                    <div className="flex min-h-40 items-center justify-center text-sm text-muted-foreground">
                        No data available
                    </div>
                </CardContent>
            </Card>
        );
    }

    const maximumCount = Math.max(...counts.map(({ value }) => value), 1);
    const coveredWorkloadCount = counts.filter(({ value }) => value > 0).length;
    const coveredPercent = Math.round(100 * coveredWorkloadCount / workloadFields.length);
    const notCoveredPercent = 100 - coveredPercent;
    const uncoveredWorkloads = counts
        .filter(({ value }) => value === 0)
        .map(({ label }) => label);

    return (
        <Card className="w-full max-w-xl overflow-hidden">
            <CardHeader className="flex-row items-start gap-3 space-y-0 pb-3">
                <ShieldAlert className="mt-0.5 size-7 shrink-0" />
                <div className="space-y-1">
                    <CardTitle className="text-2xl">DLP coverage by workload</CardTitle>
                    <CardDescription className="text-base">Number of DLP policies targeting each workload.</CardDescription>
                </div>
            </CardHeader>
            <CardContent className="space-y-5">
                {uncoveredWorkloads.length > 0 && (
                    <div className="flex items-start gap-3 rounded-md border border-foreground px-4 py-3 text-sm">
                        <TriangleAlert className="mt-0.5 size-5 shrink-0" />
                        <p>
                            No DLP policies cover <span className="font-semibold">{uncoveredWorkloads.join(", ")}</span>
                            {" "}- consider adding coverage.
                        </p>
                    </div>
                )}

                <div className="space-y-3" aria-label="DLP policy counts by workload">
                    {counts.map(({ label, value }) => (
                        <div className="grid min-h-8 grid-cols-[7.5rem_minmax(0,1fr)_2.5rem] items-center gap-3" key={label}>
                            <span className={`text-sm ${label === "Copilot" ? "font-semibold" : "text-muted-foreground"}`}>
                                {label}
                            </span>
                            <div className="h-8 overflow-hidden rounded-md">
                                {value > 0 && (
                                    <div
                                        className="h-full rounded-md bg-teal-600"
                                        style={{ width: `${Math.max(8, value / maximumCount * 100)}%` }}
                                    />
                                )}
                            </div>
                            <span className={`text-sm font-semibold tabular-nums ${value === 0 ? "text-red-500" : ""}`}>
                                {value}
                            </span>
                        </div>
                    ))}
                </div>
            </CardContent>
            <CardFooter className="grid grid-cols-2 border-t px-0 pb-0 pt-0">
                <div className="px-6 py-5">
                    <div className="text-sm text-muted-foreground">Covered</div>
                    <div className="text-3xl font-semibold tabular-nums">
                        {coveredPercent}<span className="ml-1 text-base font-normal text-muted-foreground">%</span>
                    </div>
                </div>
                <div className="border-l px-6 py-5">
                    <div className="text-sm text-muted-foreground">Not covered</div>
                    <div className="text-3xl font-semibold tabular-nums">
                        {notCoveredPercent}<span className="ml-1 text-base font-normal text-muted-foreground">%</span>
                    </div>
                </div>
            </CardFooter>
        </Card>
    );
}
