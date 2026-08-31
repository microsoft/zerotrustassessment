import {
    Briefcase,
    CircleCheckBig,
    Monitor,
    MonitorSmartphone,
} from "lucide-react";
import {
    Bar,
    BarChart,
    Cell,
    Label,
    LabelList,
    Pie,
    PieChart,
    XAxis,
    YAxis,
} from "recharts";

import { DesktopDevicesSankey } from "@/components/overview/desktop-devices-sankey";
import { DeviceAntivirusProtectionCard } from "@/components/overview/device-antivirus-protection";
import { MobileSankey } from "@/components/overview/mobile-sankey";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart";
import { Separator } from "@/components/ui/separator";
import { reportData } from "@/config/report-data";
import { formatNumber } from "@/lib/format-utils";
import { buildDeviceCoverageRows } from "@/lib/device-coverage";

type SankeyLink = { source: string; target: string; value: number | null };

const getFlow = (
    nodes: SankeyLink[],
    sourceMatcher: (source: string) => boolean,
    targetMatcher: (target: string) => boolean,
): number =>
    nodes
        .filter((link) => sourceMatcher(link.source) && targetMatcher(link.target))
        .reduce((sum, link) => sum + (Number(link.value) || 0), 0);

const renderNoData = (message = "No data available") => (
    <div className="flex h-full w-full items-center justify-center text-sm text-muted-foreground">
        {message}
    </div>
);

export default function DevicesInsightsAccordion() {
    const deviceOverview = reportData.TenantInfo?.DeviceOverview;
    const desktopNodes: SankeyLink[] = deviceOverview?.DesktopDevicesSummary?.nodes || [];
    const mobileNodes: SankeyLink[] = deviceOverview?.MobileSummary?.nodes || [];
    const osSummary: any = deviceOverview?.DeviceSummary?.deviceOperatingSystemSummary || deviceOverview?.ManagedDevices?.deviceOperatingSystemSummary;
    const deviceCoverageRows = buildDeviceCoverageRows(
        deviceOverview?.DeviceSummary?.deviceOperatingSystemSummary,
        deviceOverview?.DeviceSummary?.mdeSensorInstalledOperatingSystemSummary,
    );

    const windowsDeviceCount = Number(osSummary?.windowsCount) || getFlow(desktopNodes, (s) => s === "Desktop devices", (t) => t === "Windows");
    const macOSDeviceCount = Number(osSummary?.macOSCount) || getFlow(desktopNodes, (s) => s === "Desktop devices", (t) => t === "macOS");
    const iosDeviceCount = Number(osSummary?.iosCount ?? osSummary?.iOSCount) || getFlow(mobileNodes, (s) => s === "Mobile devices", (t) => t === "iOS");
    const androidDeviceCount = Number(osSummary?.androidCount) || getFlow(mobileNodes, (s) => s === "Mobile devices", (t) => t === "Android");
    const linuxDeviceCount = Number(osSummary?.linuxCount) || 0;

    const discoveredDeviceTotal = windowsDeviceCount + macOSDeviceCount + iosDeviceCount + androidDeviceCount + linuxDeviceCount;
    const managedDeviceTotal = Number(reportData.TenantInfo?.TenantOverview?.ManagedDeviceCount) || Number(deviceOverview?.ManagedDevices?.totalCount) || 0;
    const totalDevices = Number(reportData.TenantInfo?.TenantOverview?.DeviceCount) || discoveredDeviceTotal;

    const compliantDeviceCount = Number(deviceOverview?.DeviceCompliance?.compliantDeviceCount) || 0;
    const rawNonCompliantDeviceCount = Number(deviceOverview?.DeviceCompliance?.nonCompliantDeviceCount) || 0;
    const nonCompliantDeviceCount = compliantDeviceCount + rawNonCompliantDeviceCount > 0 ? rawNonCompliantDeviceCount : discoveredDeviceTotal;
    const totalComplianceDeviceCount = compliantDeviceCount + nonCompliantDeviceCount;

    const corporateCount = Number(deviceOverview?.DeviceOwnership?.corporateCount) || 0;
    const personalCount = Number(deviceOverview?.DeviceOwnership?.personalCount) || 0;
    const totalOwnershipCount = corporateCount + personalCount;

    return (
        <Card>
            <CardContent className="px-4 pb-3 pt-1">
                <Accordion type="single" collapsible defaultValue="device-insights" className="w-full">
                    <AccordionItem value="device-insights" className="border-b-0">
                        <AccordionTrigger className="py-3 hover:no-underline">
                            <div className="flex flex-1 items-center gap-3 text-left">
                                <div className="flex size-10 shrink-0 items-center justify-center rounded-md bg-muted text-foreground">
                                    <MonitorSmartphone className="size-5" />
                                </div>
                                <div className="flex flex-col gap-0.5">
                                    <span className="text-lg font-semibold leading-none">Device insights</span>
                                    <span className="text-sm font-normal text-muted-foreground">
                                        An overview of your device ownership, desktop, and mobile device posture.
                                    </span>
                                </div>
                            </div>
                        </AccordionTrigger>
                        <AccordionContent className="pb-2">
                            <div className="space-y-4">
                                <Card className="flex h-full w-full flex-col">
                                    <CardHeader className="flex flex-col space-y-1.5 px-4 pb-2 pt-4">
                                        <CardTitle className="flex items-center gap-2 text-base font-semibold">
                                            <MonitorSmartphone className="size-5" />
                                            Devices
                                        </CardTitle>
                                    </CardHeader>
                                    <CardContent className="flex flex-1 items-center px-4 pb-4 pt-0">
                                        <div className="grid w-full grid-cols-2 gap-4">
                                            <div className="flex items-center gap-3">
                                                <span className="relative flex size-[1.609rem] shrink-0 overflow-hidden rounded-sm">
                                                    <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent text-[color:var(--viz-8)]">
                                                        <MonitorSmartphone className="size-[1.515rem]" />
                                                    </span>
                                                </span>
                                                <div className="flex flex-col gap-0.5">
                                                    <span className="text-muted-foreground flex items-center gap-1 text-sm font-medium">
                                                        <span className="whitespace-nowrap">Total devices</span>
                                                    </span>
                                                    <span className="text-lg font-medium">{formatNumber(totalDevices)}</span>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-3">
                                                <span className="relative flex size-[1.609rem] shrink-0 overflow-hidden rounded-sm">
                                                    <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent text-[color:var(--viz-8)]">
                                                        <Monitor className="size-[1.515rem]" />
                                                    </span>
                                                </span>
                                                <div className="flex flex-col gap-0.5">
                                                    <span className="text-muted-foreground flex items-center gap-1 text-sm font-medium">
                                                        <span className="whitespace-nowrap">Managed devices</span>
                                                    </span>
                                                    <span className="text-lg font-medium">{formatNumber(managedDeviceTotal)}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </CardContent>
                                </Card>

                                <div className="grid grid-cols-1 gap-4 items-stretch lg:grid-cols-2">
                                    <Card className="flex h-[420px] flex-col overflow-hidden">
                                        <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                                            <MonitorSmartphone className="pr-2 size-8 shrink-0" />
                                            <CardTitle className="text-2xl tabular-nums">Device summary</CardTitle>
                                        </CardHeader>
                                        <CardContent className="flex flex-1 min-h-0 flex-col pb-2 pt-0">
                                            {deviceCoverageRows ? (
                                            <>
                                            <ChartContainer
                                                config={{
                                                    covered: { label: "MDE sensor installed", color: "hsl(240, 40%, 45%)" },
                                                    notCovered: { label: "Not covered", color: "hsl(240, 45%, 80%)" },
                                                }}
                                                className="w-full flex-1 min-h-0"
                                            >
                                                <BarChart
                                                    margin={{ left: 64, right: 64, top: 0, bottom: 0 }}
                                                    data={deviceCoverageRows}
                                                    layout="vertical"
                                                    barSize={32}
                                                    barGap={36}
                                                >
                                                    <XAxis type="number" hide />
                                                    <YAxis dataKey="os" type="category" tickLine={false} tickMargin={6} axisLine={false} />
                                                    <ChartTooltip cursor={false} content={<ChartTooltipContent />} />
                                                    <Bar dataKey="covered" stackId="deviceCoverage" fill="var(--color-covered)" radius={[5, 0, 0, 5]} />
                                                    <Bar dataKey="notCovered" stackId="deviceCoverage" fill="var(--color-notCovered)" radius={[0, 5, 5, 0]}>
                                                        <LabelList position="right" dataKey="label" offset={8} fontSize={12} fill="hsl(var(--foreground))" />
                                                    </Bar>
                                                </BarChart>
                                            </ChartContainer>
                                            <div className="flex items-center justify-center gap-4 pt-1 text-xs text-muted-foreground">
                                                <div className="flex items-center gap-1.5">
                                                    <span className="size-2.5 rounded-full" style={{ backgroundColor: 'hsl(240, 40%, 45%)' }} />
                                                    MDE sensor installed
                                                </div>
                                                <div className="flex items-center gap-1.5">
                                                    <span className="size-2.5 rounded-full" style={{ backgroundColor: 'hsl(240, 45%, 80%)' }} />
                                                    Not covered
                                                </div>
                                            </div>
                                            </>
                                            ) : renderNoData("No MDE coverage data available.")}
                                        </CardContent>
                                        <CardFooter className="flex flex-row items-center border-t p-4">
                                            <div className="flex w-full items-center gap-2">
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Desktops</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const desktops = windowsDeviceCount + macOSDeviceCount + linuxDeviceCount;
                                                            const mobiles = iosDeviceCount + androidDeviceCount;
                                                            const total = desktops + mobiles;
                                                            return total > 0 ? Math.round((desktops / total) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Mobiles</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const desktops = windowsDeviceCount + macOSDeviceCount + linuxDeviceCount;
                                                            const mobiles = iosDeviceCount + androidDeviceCount;
                                                            const total = desktops + mobiles;
                                                            return total > 0 ? Math.round((mobiles / total) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardFooter>
                                    </Card>

                                    <Card className="flex h-[420px] flex-col overflow-hidden">
                                        <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                                            <CircleCheckBig className="pr-2 size-8" />
                                            <CardTitle className="text-2xl tabular-nums">Device compliance</CardTitle>
                                        </CardHeader>
                                        <CardContent className="flex flex-1 min-h-0 items-center justify-center pb-2 pt-0">
                                            {totalComplianceDeviceCount <= 0 ? renderNoData("No compliance data available.") : (
                                                <ChartContainer
                                                    config={{
                                                        compliant: { label: "Compliant", color: "hsl(142, 76%, 36%)" },
                                                        nonCompliant: { label: "Non-compliant", color: "hsl(0, 84%, 60%)" },
                                                    }}
                                                    className="mx-auto h-full w-full"
                                                >
                                                    <PieChart margin={{ top: 5, right: 5, bottom: 5, left: 5 }}>
                                                        <Pie
                                                            data={[
                                                                { name: "Compliant", value: compliantDeviceCount, fill: "var(--color-compliant)" },
                                                                { name: "Non-compliant", value: nonCompliantDeviceCount, fill: "var(--color-nonCompliant)" },
                                                            ]}
                                                            cx="50%"
                                                            cy="50%"
                                                            innerRadius={50}
                                                            outerRadius={100}
                                                            paddingAngle={2}
                                                            dataKey="value"
                                                            cornerRadius={5}
                                                        >
                                                            <Cell fill="var(--color-compliant)" />
                                                            <Cell fill="var(--color-nonCompliant)" />
                                                            <Label
                                                                content={({ viewBox }) => {
                                                                    if (viewBox && "cx" in viewBox && "cy" in viewBox) {
                                                                        return (
                                                                            <text x={viewBox.cx} y={viewBox.cy} textAnchor="middle" dominantBaseline="middle">
                                                                                <tspan x={viewBox.cx} y={viewBox.cy} className="fill-foreground text-2xl font-bold">
                                                                                    {formatNumber(totalComplianceDeviceCount)}
                                                                                </tspan>
                                                                                <tspan x={viewBox.cx} y={(viewBox.cy || 0) + 20} className="fill-muted-foreground text-xs">
                                                                                    devices
                                                                                </tspan>
                                                                            </text>
                                                                        );
                                                                    }
                                                                    return null;
                                                                }}
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
                                                        <div className="h-3 w-3 rounded-sm" style={{ backgroundColor: 'hsl(142, 76%, 36%)' }} />
                                                        Compliant
                                                    </div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {totalComplianceDeviceCount > 0 ? Math.round((compliantDeviceCount / totalComplianceDeviceCount) * 100) : 0}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                        <div className="h-3 w-3 rounded-sm" style={{ backgroundColor: 'hsl(0, 84%, 60%)' }} />
                                                        Non-compliant
                                                    </div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {totalComplianceDeviceCount > 0 ? Math.round((nonCompliantDeviceCount / totalComplianceDeviceCount) * 100) : 0}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardFooter>
                                    </Card>
                                </div>

                                <div className="grid grid-cols-1 gap-4 items-stretch lg:grid-cols-2">
                                    <Card className="flex h-[420px] flex-col overflow-hidden">
                                        <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                                            <Briefcase className="pr-2 size-8" />
                                            <CardTitle className="text-2xl tabular-nums">Device ownership</CardTitle>
                                        </CardHeader>
                                        <CardContent className="flex flex-1 min-h-0 items-center justify-center pb-2 pt-0">
                                            {totalOwnershipCount <= 0 ? renderNoData() : (
                                                <ChartContainer
                                                    config={{
                                                        corporate: { label: "Corporate", color: "hsl(217, 91%, 60%)" },
                                                        personal: { label: "Personal", color: "hsl(280, 85%, 60%)" },
                                                    }}
                                                    className="mx-auto h-full w-full"
                                                >
                                                    <PieChart margin={{ top: 5, right: 5, bottom: 5, left: 5 }}>
                                                        <Pie
                                                            data={[
                                                                { name: "Corporate", value: corporateCount, fill: "var(--color-corporate)" },
                                                                { name: "Personal", value: personalCount, fill: "var(--color-personal)" },
                                                            ]}
                                                            cx="50%"
                                                            cy="50%"
                                                            innerRadius={50}
                                                            outerRadius={100}
                                                            paddingAngle={2}
                                                            dataKey="value"
                                                            cornerRadius={5}
                                                        >
                                                            <Cell fill="var(--color-corporate)" />
                                                            <Cell fill="var(--color-personal)" />
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
                                                        <div className="h-3 w-3 rounded-sm bg-blue-500" />
                                                        Corporate
                                                    </div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {totalOwnershipCount > 0 ? Math.round((corporateCount / totalOwnershipCount) * 100) : 0}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                        <div className="h-3 w-3 rounded-sm bg-purple-500" />
                                                        Personal
                                                    </div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {totalOwnershipCount > 0 ? Math.round((personalCount / totalOwnershipCount) * 100) : 0}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardFooter>
                                    </Card>

                                    <DeviceAntivirusProtectionCard fixedHeight />
                                </div>

                                <div className="grid grid-cols-1 gap-4 items-start lg:grid-cols-2">
                                    <Card className="w-full">
                                        <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                                            <Monitor className="pr-2 size-8" />
                                            <CardTitle className="text-2xl tabular-nums">Desktop devices</CardTitle>
                                        </CardHeader>
                                        <CardContent>
                                            <ChartContainer
                                                config={{ steps: { label: "Steps", color: "hsl(var(--chart-1))" } }}
                                                className="h-[350px] w-full"
                                            >
                                                {desktopNodes.length > 0 ? <DesktopDevicesSankey data={desktopNodes} /> : renderNoData()}
                                            </ChartContainer>
                                        </CardContent>
                                        <CardFooter className="flex flex-row border-t p-4">
                                            <div className="flex w-full items-center gap-2">
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Entra joined</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const total = windowsDeviceCount + macOSDeviceCount;
                                                            const value = desktopNodes.find((node) => node.target === "Entra joined")?.value || 0;
                                                            return total > 0 ? Math.round((value / total) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Entra hybrid joined</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const total = windowsDeviceCount + macOSDeviceCount;
                                                            const value = desktopNodes.find((node) => node.target === "Entra hybrid joined")?.value || 0;
                                                            return total > 0 ? Math.round((value / total) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Entra registered</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const total = windowsDeviceCount + macOSDeviceCount;
                                                            const value = desktopNodes.find((node) => node.target === "Entra registered")?.value || 0;
                                                            return total > 0 ? Math.round((value / total) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardFooter>
                                    </Card>

                                    <Card className="w-full">
                                        <CardHeader className="space-y-0 pb-2 flex-row pt-3">
                                            <MonitorSmartphone className="pr-2 size-8" />
                                            <CardTitle className="text-2xl tabular-nums">Mobile devices</CardTitle>
                                        </CardHeader>
                                        <CardContent>
                                            <ChartContainer
                                                config={{ steps: { label: "Steps", color: "hsl(var(--chart-1))" } }}
                                                className="h-[350px] w-full"
                                            >
                                                {mobileNodes.length > 0 ? <MobileSankey data={mobileNodes} /> : renderNoData()}
                                            </ChartContainer>
                                        </CardContent>
                                        <CardFooter className="flex flex-row border-t p-4">
                                            <div className="flex w-full items-center gap-2">
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Android compliant</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const androidCompliant = mobileNodes.filter((node) => node.source?.includes("Android") && node.target === "Compliant").reduce((sum, node) => sum + (node.value || 0), 0);
                                                            return androidDeviceCount > 0 ? Math.round((androidCompliant / androidDeviceCount) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">iOS compliant</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {(() => {
                                                            const iosCompliant = mobileNodes.filter((node) => node.source?.includes("iOS") && node.target === "Compliant").reduce((sum, node) => sum + (node.value || 0), 0);
                                                            return iosDeviceCount > 0 ? Math.round((iosCompliant / iosDeviceCount) * 100) : 0;
                                                        })()}
                                                        <span className="text-sm font-normal text-muted-foreground">%</span>
                                                    </div>
                                                </div>
                                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                                    <div className="text-xs text-muted-foreground">Total devices</div>
                                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                        {formatNumber(androidDeviceCount + iosDeviceCount)}
                                                    </div>
                                                </div>
                                            </div>
                                        </CardFooter>
                                    </Card>
                                </div>
                            </div>
                        </AccordionContent>
                    </AccordionItem>
                </Accordion>
            </CardContent>
        </Card>
    );
}
