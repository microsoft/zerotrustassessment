import { ShieldCheck } from "lucide-react";
import { Cell, Label, Pie, PieChart } from "recharts";

import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { Separator } from "@/components/ui/separator";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { reportData } from "@/config/report-data";
import { formatNumber } from "@/lib/format-utils";

const unprotectedDescription = "Not confirmed protected by recent Microsoft Defender runtime evidence.";

interface DeviceAntivirusProtectionCardProps {
    fixedHeight?: boolean;
}

export function DeviceAntivirusProtectionCard({ fixedHeight = false }: DeviceAntivirusProtectionCardProps) {
    const rawTotalDeviceCount = reportData.TenantInfo?.TenantOverview?.DeviceCount;
    const rawProtectedDeviceCount = reportData.TenantInfo?.DeviceOverview?.DeviceAntivirusProtection?.protectedDeviceCount;
    const totalDeviceCount = Number(rawTotalDeviceCount);
    const protectedDeviceCount = Number(rawProtectedDeviceCount);
    const hasData = rawTotalDeviceCount !== null
        && rawTotalDeviceCount !== undefined
        && rawProtectedDeviceCount !== null
        && rawProtectedDeviceCount !== undefined
        && Number.isInteger(totalDeviceCount)
        && Number.isInteger(protectedDeviceCount)
        && totalDeviceCount > 0
        && protectedDeviceCount >= 0
        && protectedDeviceCount <= totalDeviceCount;
    const unprotectedDeviceCount = hasData ? totalDeviceCount - protectedDeviceCount : 0;
    const protectedPercent = hasData ? Math.round((protectedDeviceCount / totalDeviceCount) * 100) : 0;

    return (
        <Card className={`flex w-full flex-col overflow-hidden ${fixedHeight ? "h-[420px]" : "h-full min-h-[420px]"}`}>
            <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                <ShieldCheck className="pr-2 size-8" />
                <CardTitle className="text-2xl tabular-nums">Device antivirus protection</CardTitle>
            </CardHeader>
            <CardContent className="flex min-h-[250px] flex-1 items-center justify-center pb-2 pt-0">
                {!hasData ? (
                    <div className="flex h-full w-full items-center justify-center text-sm text-muted-foreground">
                        No antivirus protection data available.
                    </div>
                ) : (
                    <ChartContainer
                        config={{
                            protected: { label: "Protected", color: "hsl(142, 76%, 36%)" },
                            unprotected: { label: "Unprotected", color: "hsl(0, 84%, 60%)" },
                        }}
                        className="mx-auto h-full w-full"
                    >
                        <PieChart margin={{ top: 5, right: 5, bottom: 5, left: 5 }}>
                            <Pie
                                data={[
                                    { name: "Protected", value: protectedDeviceCount, fill: "var(--color-protected)" },
                                    { name: "Unprotected", value: unprotectedDeviceCount, fill: "var(--color-unprotected)" },
                                ]}
                                cx="50%"
                                cy="50%"
                                innerRadius={50}
                                outerRadius={100}
                                paddingAngle={2}
                                dataKey="value"
                                cornerRadius={5}
                            >
                                <Cell fill="var(--color-protected)" />
                                <Cell fill="var(--color-unprotected)" />
                                <Label
                                    position="center"
                                    content={({ viewBox }: any) => (
                                        <text x={viewBox?.cx} y={viewBox?.cy} textAnchor="middle" dominantBaseline="middle">
                                            <tspan x={viewBox?.cx} y={viewBox?.cy} className="fill-foreground text-2xl font-bold">
                                                {formatNumber(totalDeviceCount)}
                                            </tspan>
                                            <tspan x={viewBox?.cx} y={(viewBox?.cy ?? 0) + 20} className="fill-muted-foreground text-xs">
                                                devices
                                            </tspan>
                                        </text>
                                    )}
                                />
                            </Pie>
                            <ChartTooltip content={<ChartTooltipContent />} />
                        </PieChart>
                    </ChartContainer>
                )}
            </CardContent>
            <CardFooter className="flex flex-row items-center border-t p-4">
                <div className="flex w-full items-center gap-2">
                    <div className="grid flex-1 auto-rows-min gap-0.5">
                        <div className="flex items-center gap-1 text-xs text-muted-foreground">
                            <div className="h-3 w-3 rounded-sm bg-green-600" />
                            Protected
                        </div>
                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                            {hasData ? formatNumber(protectedDeviceCount) : "—"}
                            <span className="text-sm font-normal text-muted-foreground">
                                {hasData ? `${protectedPercent}%` : ""}
                            </span>
                        </div>
                    </div>
                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                    <div className="grid flex-1 auto-rows-min gap-0.5">
                        <TooltipProvider delayDuration={200}>
                            <Tooltip>
                                <TooltipTrigger asChild>
                                    <button type="button" className="flex w-fit items-center gap-1 text-xs text-muted-foreground">
                                        <div className="h-3 w-3 rounded-sm bg-red-500" />
                                        Unprotected
                                        <span className="sr-only">: {unprotectedDescription}</span>
                                    </button>
                                </TooltipTrigger>
                                <TooltipContent>{unprotectedDescription}</TooltipContent>
                            </Tooltip>
                        </TooltipProvider>
                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                            {hasData ? formatNumber(unprotectedDeviceCount) : "—"}
                            <span className="text-sm font-normal text-muted-foreground">
                                {hasData ? `${Math.round((unprotectedDeviceCount / totalDeviceCount) * 100)}%` : ""}
                            </span>
                        </div>
                    </div>
                </div>
            </CardFooter>
        </Card>
    );
}
