import { MonitorSmartphone, Users, User, UserCog, Building2, ShieldCheck, Bot, Info, CircleCheckBig } from "lucide-react";

import {
    Bar,
    BarChart,
    Cell,
    LabelList,
    Pie,
    PieChart,
    XAxis,
    YAxis,
} from "recharts"

import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card"
import {
    ChartContainer,
    ChartTooltip,
    ChartTooltipContent,
    // ChartTooltip,
    // ChartTooltipContent,
} from "@/components/ui/chart"
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip"
// import { Separator } from "@/components/ui/separator"
import { reportData } from "@/config/report-data";
import { CaSankey } from "@/components/overview/ca-sankey";
import { CaDeviceSankey } from "@/components/overview/caDevice-sankey";
import { AuthMethodSankey } from "@/components/overview/authMethod-sankey";
import { SwgDefenseLayers, hasSwgData } from "@/components/overview/swg-defense-layers";
import { PrivateAccessSankey, hasPrivateAccessData } from "@/components/overview/private-access-sankey";
import { AzureNetSecPlanes, hasAzureNetSecData } from "@/components/overview/azure-netsec-planes";
import { AgentOwnershipDistribution } from "@/components/overview/agent-ownership-distribution";
import { DeviceAntivirusProtectionCard } from "@/components/overview/device-antivirus-protection";
import { Separator } from "@/components/ui/separator";
import { formatNumber } from "@/lib/format-utils";
import { buildDeviceCoverageRows } from "@/lib/device-coverage";

export default function Dashboard() {
    // Helper function to calculate percentage with proper number coercion
    const calculatePercentage = (passed: any, total: any): string => {
        const passedNum = Number(passed) || 0;
        const totalNum = Number(total) || 0;
        if (totalNum === 0) return '0%';
        return `${(passedNum / totalNum) * 100}%`;
    };

    const formatOptionalMetric = (value: number | null | undefined): string =>
        value === null || value === undefined ? '—' : formatNumber(value);

    const deviceOverview = reportData.TenantInfo?.DeviceOverview;
    const desktopNodes = deviceOverview?.DesktopDevicesSummary?.nodes || [];
    const mobileNodes = deviceOverview?.MobileSummary?.nodes || [];
    const osSummary: any = deviceOverview?.DeviceSummary?.deviceOperatingSystemSummary || deviceOverview?.ManagedDevices?.deviceOperatingSystemSummary;
    const deviceCoverageRows = buildDeviceCoverageRows(
        deviceOverview?.DeviceSummary?.deviceOperatingSystemSummary,
        deviceOverview?.DeviceSummary?.mdeSensorInstalledOperatingSystemSummary,
    );

    const getFlow = (
        nodes: { source: string; target: string; value: number | null }[],
        sourceMatcher: (source: string) => boolean,
        targetMatcher: (target: string) => boolean,
    ) =>
        nodes
            .filter((link) => sourceMatcher(link.source) && targetMatcher(link.target))
            .reduce((sum, link) => sum + (Number(link.value) || 0), 0);

    const hasAllDeviceOsData = (() => {
        const windows = Number(osSummary?.windowsCount) || 0;
        const macOS = Number(osSummary?.macOSCount) || 0;
        const ios = Number(osSummary?.iosCount ?? osSummary?.iOSCount) || 0;
        const android = Number(osSummary?.androidCount) || 0;
        const linux = Number(osSummary?.linuxCount) || 0;

        return windows + macOS + ios + android + linux > 0;
    })();

    const windowsDeviceCount = hasAllDeviceOsData
        ? (Number(osSummary?.windowsCount) || 0)
        : getFlow(desktopNodes, (s) => s === "Desktop devices", (t) => t === "Windows");
    const macOSDeviceCount = hasAllDeviceOsData
        ? (Number(osSummary?.macOSCount) || 0)
        : getFlow(desktopNodes, (s) => s === "Desktop devices", (t) => t === "macOS");
    const iosDeviceCount = hasAllDeviceOsData
        ? (Number(osSummary?.iosCount ?? osSummary?.iOSCount) || 0)
        : getFlow(mobileNodes, (s) => s === "Mobile devices", (t) => t === "iOS");
    const androidDeviceCount = hasAllDeviceOsData
        ? (Number(osSummary?.androidCount) || 0)
        : getFlow(mobileNodes, (s) => s === "Mobile devices", (t) => t === "Android");
    const linuxDeviceCount = hasAllDeviceOsData
        ? (Number(osSummary?.linuxCount) || 0)
        : 0;
    const discoveredDeviceTotal = windowsDeviceCount + macOSDeviceCount + iosDeviceCount + androidDeviceCount + linuxDeviceCount;
    const deviceCompliance = deviceOverview?.DeviceCompliance;
    const rawCompliantDeviceCount = Number(deviceCompliance?.compliantDeviceCount) || 0;
    const rawNonCompliantDeviceCount = Number(deviceCompliance?.nonCompliantDeviceCount) || 0;
    const hasComplianceTotals = rawCompliantDeviceCount + rawNonCompliantDeviceCount > 0;
    const compliantDeviceCount = hasComplianceTotals ? rawCompliantDeviceCount : 0;
    const nonCompliantDeviceCount = hasComplianceTotals ? rawNonCompliantDeviceCount : discoveredDeviceTotal;
    const totalComplianceDeviceCount = compliantDeviceCount + nonCompliantDeviceCount;

    return (
        <TooltipProvider delayDuration={200}>
            <div className="w-full flex flex-col gap-6 mt-8">
                {/* Tenant Info - Single Line Horizontal */}
                <Card>
                    <CardHeader className="flex flex-row space-y-0 pb-2 pl-6 pr-12 pt-4 items-center gap-8">
                        <div className="flex items-center gap-2 shrink-0">
                            <Building2 className="size-5 shrink-0" />
                            <CardTitle className="text-lg">Tenant info</CardTitle>
                        </div>
                        <div className="flex items-center gap-6 flex-1 min-w-0">
                            <div className="flex items-center gap-2 min-w-0">
                                <span className="text-sm text-muted-foreground shrink-0">Name</span>
                                <span className="font-medium truncate">{reportData.TenantName || 'Not Available'}</span>
                            </div>
                            <div className="flex items-center gap-2 min-w-0">
                                <span className="text-sm text-muted-foreground shrink-0">Tenant ID</span>
                                <span className="font-mono text-xs truncate">{reportData.TenantId || 'Not Available'}</span>
                            </div>
                            <div className="flex items-center gap-2 min-w-0">
                                <span className="text-sm text-muted-foreground shrink-0">Primary Domain</span>
                                <span className="font-medium truncate">{reportData.Domain || 'Not Available'}</span>
                            </div>
                        </div>
                    </CardHeader>
                </Card>

                {/* Metrics Grid - Full Width - 4 Columns */}
                <div className="grid grid-cols-4 gap-4">
                    {/* Users Card */}
                    <Card className="flex h-full flex-col">
                        <CardHeader className="pb-2 pt-4 px-4">
                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                <User className="size-5" />
                                Users
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="flex-1 flex items-center pt-0 pb-4 px-4">
                            <div className="grid w-full gap-4 grid-cols-2">
                                <div className="flex items-center gap-3">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                            Total users
                                        </span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.UserCount)}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                            Guest users
                                        </span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.GuestCount)}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Devices Card */}
                    <Card className="flex h-full flex-col">
                        <CardHeader className="pb-2 pt-4 px-4">
                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                <MonitorSmartphone className="size-5" />
                                Devices
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="flex-1 flex items-center pt-0 pb-4 px-4">
                            <div className="grid w-full gap-4 grid-cols-2">
                                <div className="flex items-center gap-3">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">
                                            Total devices
                                        </span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.DeviceCount)}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">
                                            Managed
                                        </span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.ManagedDeviceCount)}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Groups & Apps Card */}
                    <Card className="flex h-full flex-col">
                        <CardHeader className="pb-2 pt-4 px-4">
                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                <Users className="size-5" />
                                Groups &amp; apps
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="flex-1 flex items-center pt-0 pb-4 px-4">
                            <div className="grid w-full gap-4 grid-cols-2">
                                <Tooltip>
                                    <TooltipTrigger asChild>
                                        <div className="cursor-pointer">
                                            <div className="flex items-center gap-3">
                                                <div className="flex flex-col gap-0.5">
                                                    <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                                        Groups
                                                        <Info className="size-3.5 shrink-0 opacity-70" />
                                                    </span>
                                                    <span className="text-lg font-medium">
                                                        {formatNumber(reportData.TenantInfo?.TenantOverview?.GroupCount)}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </TooltipTrigger>
                                    <TooltipContent>
                                        <p className="text-xs">Microsoft Entra ID groups</p>
                                    </TooltipContent>
                                </Tooltip>
                                <Tooltip>
                                    <TooltipTrigger asChild>
                                        <div className="cursor-pointer">
                                            <div className="flex items-center gap-3">
                                                <div className="flex flex-col gap-0.5">
                                                    <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                                        Apps
                                                        <Info className="size-3.5 shrink-0 opacity-70" />
                                                    </span>
                                                    <span className="text-lg font-medium">
                                                        {formatNumber(reportData.TenantInfo?.TenantOverview?.ApplicationCount)}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </TooltipTrigger>
                                    <TooltipContent>
                                        <p className="text-xs">Enterprise applications</p>
                                    </TooltipContent>
                                </Tooltip>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Agents Card */}
                    <Card className="flex h-full flex-col">
                        <CardHeader className="pb-2 pt-4 px-4">
                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                <Bot className="size-5" />
                                Agents
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="flex-1 flex items-center pt-0 pb-4 px-4">
                            <div className="grid w-full gap-4 grid-cols-2">
                                <div className="flex items-center gap-3">
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">
                                            Total agents
                                        </span>
                                        <span className="text-lg font-medium">
                                            {formatOptionalMetric(reportData.TenantInfo?.AgentOverview?.TotalAgents)}
                                        </span>
                                    </div>
                                </div>
                                <Tooltip>
                                    <TooltipTrigger asChild>
                                        <div className="cursor-pointer">
                                            <div className="flex items-center gap-3">
                                                <div className="flex flex-col gap-0.5">
                                                    <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                                        Active users
                                                        <Info className="size-3.5 shrink-0 opacity-70" />
                                                    </span>
                                                    <span className="text-lg font-medium">
                                                        {formatOptionalMetric(reportData.TenantInfo?.AgentOverview?.ActiveUsers)}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </TooltipTrigger>
                                    <TooltipContent>
                                        <p className="text-xs">Unique users interacting with agents in the last 30 days</p>
                                    </TooltipContent>
                                </Tooltip>
                            </div>
                        </CardContent>
                    </Card>
                </div>

                {/* Assessment Results - Full Width */}
                <Card x-chunk="charts-01-chunk-5">
                    <CardHeader className="pb-2 pt-6 px-4">
                        <CardTitle className="text-2xl font-semibold flex items-center gap-2">
                            <ShieldCheck className="size-5" />
                            Assessment
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="pt-0 pl-11 pr-4 pb-6">
                        <div className="grid grid-cols-2 gap-x-8 gap-y-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-7">
                            {/* Identity */}
                            <div className="flex flex-col gap-1.5">
                                <div className="text-sm text-muted-foreground">Identity</div>
                                <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                    {reportData.TestResultSummary.IdentityPassed}/{reportData.TestResultSummary.IdentityTotal}
                                    <span className="text-sm font-normal text-muted-foreground">tests</span>
                                </div>
                                <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                    <div
                                        className="h-full rounded-full"
                                        style={{
                                            width: calculatePercentage(reportData.TestResultSummary.IdentityPassed, reportData.TestResultSummary.IdentityTotal),
                                            backgroundColor: 'rgb(15, 108, 189)',
                                        }}
                                    />
                                </div>
                            </div>

                            {/* Devices */}
                            <div className="flex flex-col gap-1.5">
                                <div className="text-sm text-muted-foreground">Devices</div>
                                <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                    {reportData.TestResultSummary.DevicesPassed}/{reportData.TestResultSummary.DevicesTotal}
                                    <span className="text-sm font-normal text-muted-foreground">tests</span>
                                </div>
                                <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                    <div
                                        className="h-full rounded-full"
                                        style={{
                                            width: calculatePercentage(reportData.TestResultSummary.DevicesPassed, reportData.TestResultSummary.DevicesTotal),
                                            backgroundColor: 'rgb(15, 108, 189)',
                                        }}
                                    />
                                </div>
                            </div>

                            {/* Data */}
                            {reportData.TestResultSummary.DataPassed !== undefined && (
                                <div className="flex flex-col gap-1.5">
                                    <div className="text-sm text-muted-foreground">Data</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.DataPassed}/{reportData.TestResultSummary.DataTotal}
                                        <span className="text-sm font-normal text-muted-foreground">tests</span>
                                    </div>
                                    <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                        <div
                                            className="h-full rounded-full"
                                            style={{
                                                width: calculatePercentage(reportData.TestResultSummary.DataPassed, reportData.TestResultSummary.DataTotal),
                                                backgroundColor: 'rgb(15, 108, 189)',
                                            }}
                                        />
                                    </div>
                                </div>
                            )}

                            {/* Network */}
                            {reportData.TestResultSummary.NetworkPassed !== undefined && (
                                <div className="flex flex-col gap-1.5">
                                    <div className="text-sm text-muted-foreground">Network</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.NetworkPassed}/{reportData.TestResultSummary.NetworkTotal}
                                        <span className="text-sm font-normal text-muted-foreground">tests</span>
                                    </div>
                                    <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                        <div
                                            className="h-full rounded-full"
                                            style={{
                                                width: calculatePercentage(reportData.TestResultSummary.NetworkPassed, reportData.TestResultSummary.NetworkTotal),
                                                backgroundColor: 'rgb(15, 108, 189)',
                                            }}
                                        />
                                    </div>
                                </div>
                            )}

                            {/* Infrastructure */}
                            {reportData.TestResultSummary.InfrastructurePassed !== undefined && (
                                <div className="flex flex-col gap-1.5">
                                    <div className="text-sm text-muted-foreground">Infrastructure</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.InfrastructurePassed}/{reportData.TestResultSummary.InfrastructureTotal}
                                        <span className="text-sm font-normal text-muted-foreground">tests</span>
                                    </div>
                                    <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                        <div
                                            className="h-full rounded-full"
                                            style={{
                                                width: calculatePercentage(reportData.TestResultSummary.InfrastructurePassed, reportData.TestResultSummary.InfrastructureTotal),
                                                backgroundColor: 'rgb(15, 108, 189)',
                                            }}
                                        />
                                    </div>
                                </div>
                            )}

                            {/* SecOps */}
                            {reportData.TestResultSummary.SecOpsPassed !== undefined && (
                                <div className="flex flex-col gap-1.5">
                                    <div className="text-sm text-muted-foreground">SecOps</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.SecOpsPassed}/{reportData.TestResultSummary.SecOpsTotal}
                                        <span className="text-sm font-normal text-muted-foreground">tests</span>
                                    </div>
                                    <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                        <div
                                            className="h-full rounded-full"
                                            style={{
                                                width: calculatePercentage(reportData.TestResultSummary.SecOpsPassed, reportData.TestResultSummary.SecOpsTotal),
                                                backgroundColor: 'rgb(15, 108, 189)',
                                            }}
                                        />
                                    </div>
                                </div>
                            )}

                            {/* AI */}
                            {reportData.TestResultSummary.AIPassed !== undefined && (
                                <div className="flex flex-col gap-1.5">
                                    <div className="text-sm text-muted-foreground">AI</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.AIPassed}/{reportData.TestResultSummary.AITotal}
                                        <span className="text-sm font-normal text-muted-foreground">tests</span>
                                    </div>
                                    <div className="h-1 w-full max-w-[120px] overflow-hidden rounded-full bg-muted">
                                        <div
                                            className="h-full rounded-full"
                                            style={{
                                                width: calculatePercentage(reportData.TestResultSummary.AIPassed, reportData.TestResultSummary.AITotal),
                                                backgroundColor: 'rgb(15, 108, 189)',
                                            }}
                                        />
                                    </div>
                                </div>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="flex flex-col">
            {/* Identity summary */}
            <div className="order-2 mx-auto flex w-full max-w-7xl flex-col gap-6 mt-6">
                <div className="grid gap-6 grid-cols-1 lg:grid-cols-2">

                    <div className="grid w-full gap-6 lg:col-span-1">
                        {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.nodes ? (
                        <Card
                            className="w-full" x-chunk="charts-01-chunk-0"
                        >
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <UserCog className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">
                                    Privileged users auth methods
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Steps",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                >
                                    {reportData.TenantInfo?.OverviewAuthMethodsPrivilegedUsers?.nodes ? (
                                        <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsPrivilegedUsers.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex-col items-start gap-1">
                                <CardDescription>
                                    {reportData.TenantInfo?.OverviewAuthMethodsPrivilegedUsers?.description || "No description available"}
                                </CardDescription>
                            </CardFooter>
                        </Card>
                        ) : null}

                        {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.nodes ? (
                        <Card
                            className="w-full" x-chunk="charts-01-chunk-0"
                        >
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <Users className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">
                                    All users auth methods
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Steps",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                >
                                    {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.nodes ? (
                                        <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsAllUsers.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex-col items-start gap-1">
                                <CardDescription>
                                    {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.description || "No description available"}
                                </CardDescription>
                            </CardFooter>
                        </Card>
                        ) : null}
                        {/* {<Card
                            className="lg:max-w-md" x-chunk="charts-01-chunk-0"
                        >
                            <CardHeader className="space-y-0 pb-2">
                                <CardDescription>Defender for Office 365</CardDescription>
                                <CardTitle className="text-4xl tabular-nums">
                                    1,284{" "}
                                    <span className="font-sans text-sm font-normal tracking-normal text-muted-foreground">
                                        phishing blocks
                                    </span>
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Blocks",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                >
                                    <BarChart
                                        accessibilityLayer
                                        margin={{
                                            left: -4,
                                            right: -4,
                                        }}
                                        data={[
                                            {
                                                date: "2024-01-01",
                                                steps: 2000,
                                            },
                                            {
                                                date: "2024-01-02",
                                                steps: 2100,
                                            },
                                            {
                                                date: "2024-01-03",
                                                steps: 2200,
                                            },
                                            {
                                                date: "2024-01-04",
                                                steps: 1300,
                                            },
                                            {
                                                date: "2024-01-05",
                                                steps: 1400,
                                            },
                                            {
                                                date: "2024-01-06",
                                                steps: 2500,
                                            },
                                            {
                                                date: "2024-01-07",
                                                steps: 1600,
                                            },
                                        ]}
                                    >
                                        <Bar
                                            dataKey="steps"
                                            fill="var(--color-steps)"
                                            radius={5}
                                            fillOpacity={0.6}
                                            activeBar={<Rectangle fillOpacity={0.8} />}
                                        />
                                        <XAxis
                                            dataKey="date"
                                            tickLine={false}
                                            axisLine={false}
                                            tickMargin={4}
                                            tickFormatter={(value) => {
                                                return new Date(value).toLocaleDateString("en-US", {
                                                    weekday: "short",
                                                })
                                            }}
                                        />
                                        <ChartTooltip
                                            defaultIndex={2}
                                            content={
                                                <ChartTooltipContent
                                                    hideIndicator
                                                    labelFormatter={(value) => {
                                                        return new Date(value).toLocaleDateString("en-US", {
                                                            day: "numeric",
                                                            month: "long",
                                                            year: "numeric",
                                                        })
                                                    }}
                                                />
                                            }
                                            cursor={false}
                                        />
                                        <ReferenceLine
                                            y={1200}
                                            stroke="hsl(var(--muted-foreground))"
                                            strokeDasharray="3 3"
                                            strokeWidth={1}
                                        >
                                            <Label
                                                position="insideBottomLeft"
                                                value="Average Blocks"
                                                offset={10}
                                                fill="hsl(var(--foreground))"
                                            />
                                            <Label
                                                position="insideTopLeft"
                                                value="1,284"
                                                className="text-lg"
                                                fill="hsl(var(--foreground))"
                                                offset={10}
                                                startOffset={100}
                                            />
                                        </ReferenceLine>
                                    </BarChart>
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex-col items-start gap-1">
                                <CardDescription>
                                    Over the past 7 days, Defender has blocked {" "}
                                    <span className="font-medium text-foreground">13,305</span> phishing attempts.
                                </CardDescription>
                            </CardFooter>
                        </Card>} */}
                        {/* <Card
                        className="flex flex-col lg:max-w-md" x-chunk="charts-01-chunk-1"
                    >
                        <CardHeader className="flex flex-row items-center gap-4 space-y-0 pb-2 [&>div]:flex-1">
                            <div>
                                <CardDescription>Purview</CardDescription>
                                <CardTitle className="flex items-baseline gap-1 text-4xl tabular-nums">
                                    62
                                    <span className="text-sm font-normal tracking-normal text-muted-foreground">
                                        labels
                                    </span>
                                </CardTitle>
                            </div>
                            <div>
                                <CardDescription>Defender IoT</CardDescription>
                                <CardTitle className="flex items-baseline gap-1 text-4xl tabular-nums">
                                    35
                                    <span className="text-sm font-normal tracking-normal text-muted-foreground">
                                        blocks
                                    </span>
                                </CardTitle>
                            </div>
                        </CardHeader>
                        <CardContent className="flex flex-1 items-center">
                            <ChartContainer
                                config={{
                                    resting: {
                                        label: "Resting",
                                        color: "hsl(var(--chart-1))",
                                    },
                                }}
                                className="w-full"
                            >
                                <LineChart
                                    accessibilityLayer
                                    margin={{
                                        left: 14,
                                        right: 14,
                                        top: 10,
                                    }}
                                    data={[
                                        {
                                            date: "2024-01-01",
                                            resting: 62,
                                        },
                                        {
                                            date: "2024-01-02",
                                            resting: 72,
                                        },
                                        {
                                            date: "2024-01-03",
                                            resting: 35,
                                        },
                                        {
                                            date: "2024-01-04",
                                            resting: 62,
                                        },
                                        {
                                            date: "2024-01-05",
                                            resting: 52,
                                        },
                                        {
                                            date: "2024-01-06",
                                            resting: 62,
                                        },
                                        {
                                            date: "2024-01-07",
                                            resting: 70,
                                        },
                                    ]}
                                >
                                    <CartesianGrid
                                        strokeDasharray="4 4"
                                        vertical={false}
                                        stroke="hsl(var(--muted-foreground))"
                                        strokeOpacity={0.5}
                                    />
                                    <YAxis hide domain={["dataMin - 10", "dataMax + 10"]} />
                                    <XAxis
                                        dataKey="date"
                                        tickLine={false}
                                        axisLine={false}
                                        tickMargin={8}
                                        tickFormatter={(value) => {
                                            return new Date(value).toLocaleDateString("en-US", {
                                                weekday: "short",
                                            })
                                        }}
                                    />
                                    <Line
                                        dataKey="resting"
                                        type="natural"
                                        fill="var(--color-resting)"
                                        stroke="var(--color-resting)"
                                        strokeWidth={2}
                                        dot={false}
                                        activeDot={{
                                            fill: "var(--color-resting)",
                                            stroke: "var(--color-resting)",
                                            r: 4,
                                        }}
                                    />
                                    <ChartTooltip
                                        content={
                                            <ChartTooltipContent
                                                indicator="line"
                                                labelFormatter={(value) => {
                                                    return new Date(value).toLocaleDateString("en-US", {
                                                        day: "numeric",
                                                        month: "long",
                                                        year: "numeric",
                                                    })
                                                }}
                                            />
                                        }
                                        cursor={false}
                                    />
                                </LineChart>
                            </ChartContainer>
                        </CardContent>
                    </Card> */}
                    </div>
                    <div className="grid w-full gap-6 lg:col-span-1">
                        {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.nodes ? (
                        <Card
                            className="lmax-w-xs" x-chunk="charts-01-chunk-0"
                        >
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <User className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">
                                    User authentication
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Steps",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                >
                                    {reportData.TenantInfo?.OverviewCaMfaAllUsers?.nodes ? (
                                        <CaSankey data={reportData.TenantInfo.OverviewCaMfaAllUsers.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex-col items-start gap-1">
                                <CardDescription>
                                    {reportData.TenantInfo?.OverviewCaMfaAllUsers?.description || "No description available"}
                                </CardDescription>
                            </CardFooter>
                        </Card>
                        ) : null}

                        {reportData.TenantInfo?.OverviewAuthMethodsPrivilegedUsers?.nodes ? (
                        <Card
                            className="lmax-w-xs" x-chunk="charts-01-chunk-0"
                        >
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <MonitorSmartphone className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums ">
                                    Device sign-ins
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Steps",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                >
                                    {reportData.TenantInfo?.OverviewCaDevicesAllUsers?.nodes ? (
                                        <CaDeviceSankey data={reportData.TenantInfo.OverviewCaDevicesAllUsers.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex-col items-start gap-1">
                                <CardDescription>
                                    {reportData.TenantInfo?.OverviewCaDevicesAllUsers?.description || "No description available"}
                                </CardDescription>
                            </CardFooter>
                        </Card>
                        ) : null}
                        {/* {<Card
                            className="max-w-xs" x-chunk="charts-01-chunk-2"
                        >
                            <CardHeader>
                                <CardTitle>Passwordless Progress</CardTitle>
                                <CardDescription>
                                    You average more passwordless sign-ins this month compared to the last.
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="grid gap-4">
                                <div className="grid auto-rows-min gap-2">
                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                        453
                                        <span className="text-sm font-normal text-muted-foreground">
                                            sign-ins/day
                                        </span>
                                    </div>
                                    <ChartContainer
                                        config={{
                                            steps: {
                                                label: "Steps",
                                                color: "hsl(var(--chart-1))",
                                            },
                                        }}
                                        className="aspect-auto h-[32px] w-full"
                                    >
                                        <BarChart
                                            accessibilityLayer
                                            layout="vertical"
                                            margin={{
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                            }}
                                            data={[
                                                {
                                                    date: "Jul 2024",
                                                    steps: 12435,
                                                },
                                            ]}
                                        >
                                            <Bar
                                                dataKey="steps"
                                                fill="var(--color-steps)"
                                                radius={4}
                                                barSize={32}
                                            >
                                                <LabelList
                                                    position="insideLeft"
                                                    dataKey="date"
                                                    offset={8}
                                                    fontSize={12}
                                                    fill="white"
                                                />
                                            </Bar>
                                            <YAxis dataKey="date" type="category" tickCount={1} hide />
                                            <XAxis dataKey="steps" type="number" hide />
                                        </BarChart>
                                    </ChartContainer>
                                </div>
                                <div className="grid auto-rows-min gap-2">
                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                        314
                                        <span className="text-sm font-normal text-muted-foreground">
                                            sign-ins/day
                                        </span>
                                    </div>
                                    <ChartContainer
                                        config={{
                                            steps: {
                                                label: "Steps",
                                                color: "hsl(var(--muted))",
                                            },
                                        }}
                                        className="aspect-auto h-[32px] w-full"
                                    >
                                        <BarChart
                                            accessibilityLayer
                                            layout="vertical"
                                            margin={{
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 0,
                                            }}
                                            data={[
                                                {
                                                    date: "Jun 2024",
                                                    steps: 10103,
                                                },
                                            ]}
                                        >
                                            <Bar
                                                dataKey="steps"
                                                fill="var(--color-steps)"
                                                radius={4}
                                                barSize={32}
                                            >
                                                <LabelList
                                                    position="insideLeft"
                                                    dataKey="date"
                                                    offset={8}
                                                    fontSize={12}
                                                    fill="hsl(var(--muted-foreground))"
                                                />
                                            </Bar>
                                            <YAxis dataKey="date" type="category" tickCount={1} hide />
                                            <XAxis dataKey="steps" type="number" hide />
                                        </BarChart>
                                    </ChartContainer>
                                </div>
                            </CardContent>
                        </Card>} */}
                        {/* {<Card
                            className="max-w-xs" x-chunk="charts-01-chunk-3"
                        >
                            <CardHeader className="p-4 pb-0">
                                <CardTitle>Defender Actions</CardTitle>
                                <CardDescription>
                                    Over the last 7 days, your workbook actions have been triggered over 130 times
                                    per day.
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="flex flex-row items-baseline gap-4 p-4 pt-0">
                                <div className="flex items-baseline gap-1 text-3xl font-bold tabular-nums leading-none">
                                    130
                                    <span className="text-sm font-normal text-muted-foreground">
                                        triggers/day
                                    </span>
                                </div>
                                <ChartContainer
                                    config={{
                                        steps: {
                                            label: "Steps",
                                            color: "hsl(var(--chart-1))",
                                        },
                                    }}
                                    className="ml-auto w-[72px]"
                                >
                                    <BarChart
                                        accessibilityLayer
                                        margin={{
                                            left: 0,
                                            right: 0,
                                            top: 0,
                                            bottom: 0,
                                        }}
                                        data={[
                                            {
                                                date: "2024-01-01",
                                                steps: 2000,
                                            },
                                            {
                                                date: "2024-01-02",
                                                steps: 2100,
                                            },
                                            {
                                                date: "2024-01-03",
                                                steps: 2200,
                                            },
                                            {
                                                date: "2024-01-04",
                                                steps: 1300,
                                            },
                                            {
                                                date: "2024-01-05",
                                                steps: 1400,
                                            },
                                            {
                                                date: "2024-01-06",
                                                steps: 2500,
                                            },
                                            {
                                                date: "2024-01-07",
                                                steps: 1600,
                                            },
                                        ]}
                                    >
                                        <Bar
                                            dataKey="steps"
                                            fill="var(--color-steps)"
                                            radius={2}
                                            fillOpacity={0.2}
                                            activeIndex={6}
                                            activeBar={<Rectangle fillOpacity={0.8} />}
                                        />
                                        <XAxis
                                            dataKey="date"
                                            tickLine={false}
                                            axisLine={false}
                                            tickMargin={4}
                                            hide
                                        />
                                    </BarChart>
                                </ChartContainer>
                            </CardContent>
                        </Card>} */}
                    </div>
                </div>
            </div>

            {/* Devices Section */}
            <div className="order-1 mx-auto flex w-full max-w-7xl flex-col gap-6 mt-6">
                {/* <PageHeader>
                    <PageHeaderHeading>Devices</PageHeaderHeading>
                </PageHeader> */}

                <div className="grid gap-6 grid-cols-1 lg:grid-cols-3">
                    {/* Device summary chart */}
                    {reportData.TenantInfo?.DeviceOverview ? (
                        <Card className="flex h-full w-full flex-col">
                            <CardHeader className="space-y-2 pb-3 pt-3">
                                <div className="flex flex-row items-start gap-2">
                                    <MonitorSmartphone className="size-8 shrink-0" />
                                    <div className="flex flex-col gap-1">
                                        <CardTitle className="text-2xl tabular-nums">Device summary</CardTitle>
                                        <CardDescription>
                                            {deviceOverview?.DeviceSummary?.description || "Total devices and Microsoft Defender for Endpoint sensor coverage by OS."}
                                        </CardDescription>
                                    </div>
                                </div>
                            </CardHeader>
                            <CardContent className="flex h-[480px] flex-1 flex-col pb-2 pt-0">
                                {deviceCoverageRows ? (
                                <>
                                <ChartContainer
                                    config={{
                                        covered: { label: "MDE sensor installed", color: "hsl(240, 40%, 45%)" },
                                        notCovered: { label: "Not covered", color: "hsl(240, 45%, 80%)" },
                                    }}
                                    className="min-h-[250px] w-full flex-1"
                                >
                                    <BarChart
                                        margin={{ left: 64, right: 64, top: 0, bottom: 0 }}
                                        data={deviceCoverageRows}
                                        layout="vertical"
                                        barSize={32}
                                        barGap={36}
                                    >
                                        <XAxis type="number" hide />
                                        <YAxis
                                            dataKey="os"
                                            type="category"
                                            tickLine={false}
                                            tickMargin={6}
                                            axisLine={false}
                                        />
                                        <ChartTooltip cursor={false} content={<ChartTooltipContent />} />
                                        <Bar dataKey="covered" stackId="deviceCoverage" fill="var(--color-covered)" radius={[5, 0, 0, 5]} />
                                        <Bar dataKey="notCovered" stackId="deviceCoverage" fill="var(--color-notCovered)" radius={[0, 5, 5, 0]}>
                                            <LabelList
                                                position="right"
                                                dataKey="label"
                                                offset={8}
                                                fontSize={12}
                                                fill="hsl(var(--foreground))"
                                            />
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
                                ) : (
                                    <div className="flex flex-1 items-center justify-center text-sm text-muted-foreground">
                                        No MDE coverage data available.
                                    </div>
                                )}
                            </CardContent>
                            <CardFooter className="flex flex-row border-t p-4">
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
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
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
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </CardFooter>
                        </Card>
                    ) : null}

                    {/* Device compliance chart */}
                    {reportData.TenantInfo?.DeviceOverview?.DeviceCompliance && (
                            <Card className="w-full">
                                <CardHeader className="space-y-0 pb-2 flex-row">
                                    <CircleCheckBig className="pr-2 size-8" />
                                    <CardTitle className="text-2xl tabular-nums ">
                                        Device compliance
                                    </CardTitle>
                                </CardHeader>
                                <CardContent className="flex pb-2 h-[250px]">
                                    {(() => {
                                        const compliant = compliantDeviceCount;
                                        const nonCompliant = nonCompliantDeviceCount;
                                        const total = totalComplianceDeviceCount;

                                        if (total <= 0) {
                                            return (
                                                <div className="flex h-[250px] w-full items-center justify-center text-sm text-muted-foreground">
                                                    No compliance data available.
                                                </div>
                                            );
                                        }

                                        return (
                                            <ChartContainer
                                                config={{
                                                    compliant: {
                                                        label: "Compliant",
                                                        color: "hsl(142, 76%, 36%)",
                                                    },
                                                    nonCompliant: {
                                                        label: "Non-compliant",
                                                        color: "hsl(0, 84%, 60%)",
                                                    },
                                                }}
                                                className="mx-auto aspect-square w-full max-h-full"
                                            >
                                                <PieChart margin={{ top: 5, right: 5, bottom: 5, left: 5 }}>
                                                    <Pie
                                                        data={[
                                                            {
                                                                name: "Compliant",
                                                                value: compliant,
                                                                fill: "var(--color-compliant)",
                                                            },
                                                            {
                                                                name: "Non-compliant",
                                                                value: nonCompliant,
                                                                fill: "var(--color-nonCompliant)",
                                                            },
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
                                                    </Pie>
                                                    <ChartTooltip content={<ChartTooltipContent />} />
                                                </PieChart>
                                            </ChartContainer>
                                        );
                                    })()}
                                </CardContent>
                                <CardFooter className="flex flex-row border-t p-4">
                                    <div className="flex w-full items-center gap-2">
                                        <div className="grid flex-1 auto-rows-min gap-0.5">
                                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                <div className="w-3 h-3 rounded-sm bg-green-600"></div>
                                                Compliant
                                            </div>
                                            <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                {(() => {
                                                    const compliant = compliantDeviceCount;
                                                    const total = totalComplianceDeviceCount;
                                                    return total > 0 ? Math.round((compliant / total) * 100) : 0;
                                                })()}
                                                <span className="text-sm font-normal text-muted-foreground">
                                                    %
                                                </span>
                                            </div>
                                        </div>
                                        <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                        <div className="grid flex-1 auto-rows-min gap-0.5">
                                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                <div className="w-3 h-3 rounded-sm bg-red-500"></div>
                                                Non-compliant
                                            </div>
                                            <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                {(() => {
                                                    const nonCompliant = nonCompliantDeviceCount;
                                                    const total = totalComplianceDeviceCount;
                                                    return total > 0 ? Math.round((nonCompliant / total) * 100) : 0;
                                                })()}
                                                <span className="text-sm font-normal text-muted-foreground">
                                                    %
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </CardFooter>
                            </Card>
                        )}

                    <DeviceAntivirusProtectionCard />

                </div>
            </div>
            </div>

            {/* AI overview */}
            {reportData.TenantInfo?.AgentOwnershipDistribution && (
                <div className="mx-auto mt-6 grid w-full max-w-7xl grid-cols-1 gap-6 lg:grid-cols-2">
                    <AgentOwnershipDistribution data={reportData.TenantInfo.AgentOwnershipDistribution} />
                </div>
            )}

            {/* Network overview */}
            {(() => {
                const swg = hasSwgData();
                const privateAccess = hasPrivateAccessData();
                if (!swg && !privateAccess) return null;

                return (
                    <div className="mx-auto mt-6 grid w-full max-w-7xl grid-cols-1 items-stretch gap-6 lg:grid-cols-2">
                        {swg && (
                            <Card className="h-full">
                                <CardHeader className="flex-row space-y-0 pb-2">
                                    <ShieldCheck className="size-8 pr-2" />
                                    <div>
                                        <CardTitle className="text-2xl tabular-nums">
                                            SWG defense-in-depth
                                        </CardTitle>
                                        <CardDescription className="mt-1">
                                            Secure Web Gateway defense layers — internet traffic inspection posture
                                        </CardDescription>
                                    </div>
                                </CardHeader>
                                <CardContent>
                                    <SwgDefenseLayers stacked />
                                </CardContent>
                            </Card>
                        )}
                        {privateAccess && <PrivateAccessSankey />}
                    </div>
                );
            })()}

            {/* Network - Azure Network Security Defense Planes Section */}
            {hasAzureNetSecData() && (
            <div className="flex max-w-7xl flex-col gap-6 mt-6">
                <Card>
                    <CardHeader className="space-y-0 pb-2 flex-row">
                        <ShieldCheck className="pr-2 size-8" />
                        <div>
                            <CardTitle className="text-2xl tabular-nums">
                                Azure network security
                            </CardTitle>
                            <CardDescription className="mt-1">
                                Defense plane posture — availability, inbound, and outbound protection.
                            </CardDescription>
                        </div>
                    </CardHeader>
                    <CardContent>
                        <AzureNetSecPlanes />
                    </CardContent>
                </Card>
            </div>
            )}
        </TooltipProvider>
    )
}

// const MyCustomComponent = (props: any) => {
//     return <path fill={props.payload.color} fill-opacity="0.1" stroke={props.payload.stroke} stroke-width="2" x={props.x} y={props.y} width="10"
//         height={props.height} radius="0" className="recharts-rectangle recharts-sankey-node"
//         d={`M ${props.x},${props.y} h ${props.width} v ${props.height} h -${props.width} Z`} />
// }
// const MyCustomLinkComponent = (props: any) => {
//     console.log('props', props)
//     return <path
//         d={`
//         M${props.sourceX},${props.sourceY}
//         C${props.sourceControlX},${props.sourceY} ${props.targetControlX},${props.targetY} ${props.targetX},${props.targetY}
//       `}
//         stroke={props.payload.color}
//         strokeWidth={props.linkWidth}
//         {...props}
//     />
// }
