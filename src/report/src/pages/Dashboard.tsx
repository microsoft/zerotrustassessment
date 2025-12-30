import { MonitorSmartphone, Users, User, UserCog, Luggage, Monitor, Layers3, Building2, ShieldCheck, CircleCheckBig, Briefcase } from "lucide-react";

import {
    Bar,
    BarChart,
    Cell,
    LabelList,
    // Area,
    // AreaChart,
    // Bar,
    // BarChart,
    // CartesianGrid,
    // Label,
    // LabelList,
    // Line,
    // LineChart,
    Pie,
    PieChart,
    PolarAngleAxis,
    RadialBar,
    RadialBarChart,

    XAxis,
    YAxis,
    // Rectangle,
    // ReferenceLine,
    // XAxis,
    // YAxis,
} from "recharts"

import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
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
import { DesktopDevicesSankey } from "@/components/overview/desktop-devices-sankey";
import { MobileSankey } from "@/components/overview/mobile-sankey";
import { Separator } from "@/components/ui/separator";
import { formatNumber, metricDescriptions } from "@/lib/format-utils";

export default function Dashboard() {


    return (
        <TooltipProvider delayDuration={200}>
            {/* Tenant overview Section */}
            <div className="w-full flex max-w-7xl flex-col gap-6 mt-12">
                <div className="grid w-full gap-6 lg:grid-cols-3">
                    {/* Column 1: Tenant Information */}
                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle className="flex items-center gap-2">
                                <Building2 className="size-5" />
                                Tenant
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-4">
                                <div className="flex flex-col gap-1">
                                    <span className="text-sm text-muted-foreground">Name</span>
                                    <span className="font-medium">
                                        {reportData.TenantName || 'Not Available'}
                                    </span>
                                </div>
                                {<div className="flex flex-col gap-1">
                                    <span className="text-sm text-muted-foreground">Tenant ID</span>
                                    <span className="font-mono text-xs">
                                        {reportData.TenantId || 'Not Available'}
                                    </span>
                                </div>}
                                <div className="flex flex-col gap-1">
                                    <span className="text-sm text-muted-foreground">Primary Domain</span>
                                    <span className="font-medium">
                                        {reportData.Domain || 'Not Available'}
                                    </span>
                                </div>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Column 2: Tenant Metrics */}

                    <div className="grid gap-4 grid-cols-2 grid-rows-3">
                        {/* Users Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-blue-600 shrink-0 rounded-sm">
                                            <User className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Users</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.UserCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.UserCount?.toLocaleString() || '0'} Users</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.users}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Guests Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-indigo-600 shrink-0 rounded-sm">
                                            <Luggage className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Guests</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.GuestCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.GuestCount?.toLocaleString() || '0'} Guests</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.guests}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Groups Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-purple-600 shrink-0 rounded-sm">
                                            <Users className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Groups</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.GroupCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.GroupCount?.toLocaleString() || '0'} Groups</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.groups}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Applications Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-rose-600 shrink-0 rounded-sm">
                                            <Layers3 className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Apps</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.ApplicationCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.ApplicationCount?.toLocaleString() || '0'} Applications</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.apps}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Devices Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-orange-600 shrink-0 rounded-sm">
                                            <MonitorSmartphone className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Devices</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.DeviceCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.DeviceCount?.toLocaleString() || '0'} Devices</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.devices}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Managed Devices Metric */}
                        <Tooltip>
                            <TooltipTrigger asChild>
                                <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="text-emerald-600 shrink-0 rounded-sm">
                                            <MonitorSmartphone className="size-8" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Managed</span>
                                        <span className="text-lg font-medium">
                                            {formatNumber(reportData.TenantInfo?.TenantOverview?.ManagedDeviceCount)}
                                        </span>
                                    </div>
                                </div>
                            </TooltipTrigger>
                            <TooltipContent>
                                <div className="space-y-1">
                                    <p className="font-semibold">{reportData.TenantInfo?.TenantOverview?.ManagedDeviceCount?.toLocaleString() || '0'} Managed Devices</p>
                                    <p className="text-xs text-muted-foreground">{metricDescriptions.managed}</p>
                                </div>
                            </TooltipContent>
                        </Tooltip>

                        {/* Assessment Date Metric */}
                        {/* <div className="flex items-center gap-3 rounded-md border px-4 py-3">
                                    <Avatar className="size-8.5 rounded-sm">
                                        <AvatarFallback className="bg-primary/10 text-primary shrink-0 rounded-sm">
                                            <Globe className="size-5" />
                                        </AvatarFallback>
                                    </Avatar>
                                    <div className="flex flex-col gap-0.5">
                                        <span className="text-muted-foreground text-sm font-medium">Last Scan</span>
                                        <span className="text-sm font-medium">
                                            {reportData.ExecutedAt ? new Date(reportData.ExecutedAt).toLocaleDateString() : 'Not Available'}
                                        </span>
                                    </div>
                                </div> */}
                    </div>


                    {/* Column 3: Assessment Results */}
                    <Card /** Test summary chart   */
                        x-chunk="charts-01-chunk-5"
                    >
                        <CardHeader className="pb-3">
                            <CardTitle className="flex items-center gap-2">
                                <ShieldCheck className="size-5" />
                                Assessment
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="flex gap-6">
                            <div className="flex flex-col gap-2">
                                <div className="grid auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Identity</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.IdentityPassed}/{reportData.TestResultSummary.IdentityTotal}
                                        <span className="text-sm font-normal text-muted-foreground">
                                            tests
                                        </span>
                                    </div>
                                </div>
                                <div className="grid auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Devices</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.DevicesPassed}/{reportData.TestResultSummary.DevicesTotal}
                                        <span className="text-sm font-normal text-muted-foreground">
                                            tests
                                        </span>
                                    </div>
                                </div>
                                {/* <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Data</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        {reportData.TestResultSummary.DataPassed}/{reportData.TestResultSummary.DataTotal}
                                        <span className="text-sm font-normal text-muted-foreground">
                                            checks
                                        </span>
                                    </div>
                                </div> */}
                            </div>
                            <ChartContainer
                                config={{
                                    move: {
                                        label: "Identity",
                                        color: "hsl(var(--chart-1))",
                                    },
                                    exercise: {
                                        label: "Devices",
                                        color: "hsl(var(--chart-2))",
                                    },
                                    stand: {
                                        label: "Data",
                                        color: "hsl(var(--chart-3))",
                                    },
                                }}
                                className="mx-auto aspect-square w-full max-w-[80%]"
                            >
                                <RadialBarChart
                                    margin={{
                                        left: -10,
                                        right: -10,
                                        top: -10,
                                        bottom: -10,
                                    }}
                                    data={[
                                        // Only include Data pillar if it exists (preview mode)
                                        ...(reportData.TestResultSummary.DataPassed !== undefined && reportData.TestResultSummary.DataTotal !== undefined
                                            ? [{
                                                activity: "data",
                                                value: (reportData.TestResultSummary.DataPassed / reportData.TestResultSummary.DataTotal) * 100,
                                                fill: "var(--color-stand)",
                                            }]
                                            : []),
                                        {
                                            activity: "devices",
                                            value: (reportData.TestResultSummary.DevicesPassed / reportData.TestResultSummary.DevicesTotal) * 100,
                                            fill: "var(--color-exercise)",
                                        },
                                        {
                                            activity: "identity",
                                            value: (reportData.TestResultSummary.IdentityPassed / reportData.TestResultSummary.IdentityTotal) * 100,
                                            fill: "var(--color-move)",
                                        },
                                    ]}
                                    innerRadius="20%"
                                    barSize={24}
                                    startAngle={90}
                                    endAngle={450}
                                >
                                    <PolarAngleAxis
                                        type="number"
                                        domain={[0, 100]}
                                        dataKey="value"
                                        tick={false}
                                    />
                                    <RadialBar dataKey="value" background cornerRadius={5} />
                                </RadialBarChart>
                            </ChartContainer>
                        </CardContent>
                    </Card>
                </div>
            </div>

            {/* Identity summary */}
            <div className="mx-auto flex max-w-7xl flex-col gap-6 mt-6">
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
            <div className="flex max-w-7xl flex-col gap-6 mt-6">
                {/* <PageHeader>
                    <PageHeaderHeading>Devices</PageHeaderHeading>
                </PageHeader> */}

                <div className="grid gap-6 grid-cols-1 lg:grid-cols-3">
                    {/* Device summary chart */}
                    {reportData.TenantInfo?.DeviceOverview?.ManagedDevices ? (
                        <Card className="w-full">
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <MonitorSmartphone className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">Device summary</CardTitle>
                            </CardHeader>
                            <CardContent className="flex pb-4 h-[250px]">
                                <ChartContainer
                                    config={{
                                        value: {
                                            label: "Devices",
                                        },
                                    }}
                                    className="h-[250px] w-full"
                                >
                                    <BarChart
                                        margin={{
                                            left: 12,
                                            right: 0,
                                            top: 0,
                                            bottom: 10,
                                        }}
                                        data={[
                                            {
                                                dataKey: "Windows",
                                                value: reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.windowsCount || 0,
                                                label: `${reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.windowsCount || 0}`,
                                                fill: "hsl(var(--chart-1))",
                                            },
                                            {
                                                dataKey: "macOS",
                                                value: reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.macOSCount || 0,
                                                label: `${reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.macOSCount || 0}`,
                                                fill: "hsl(var(--chart-2))",
                                            },
                                            {
                                                dataKey: "iOS",
                                                value: reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.iosCount || 0,
                                                label: `${reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.iosCount || 0}`,
                                                fill: "hsl(var(--chart-3))",
                                            },
                                            {
                                                dataKey: "Android",
                                                value: reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.androidCount || 0,
                                                label: `${reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.androidCount || 0}`,
                                                fill: "hsl(var(--chart-5))",
                                            },
                                            {
                                                dataKey: "Linux",
                                                value: reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.linuxCount || 0,
                                                label: `${reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.deviceOperatingSystemSummary?.linuxCount || 0}`,
                                                fill: "hsl(var(--chart-4))",
                                            },
                                        ]}
                                        layout="vertical"
                                        barSize={32}
                                        barGap={2}
                                    >
                                        <XAxis type="number" dataKey="value" hide />
                                        <YAxis
                                            dataKey="dataKey"
                                            type="category"
                                            tickLine={false}
                                            tickMargin={4}
                                            axisLine={false}
                                            className=""
                                        />
                                        <ChartTooltip
                                            cursor={false}
                                            content={<ChartTooltipContent/>}
                                        />
                                        <Bar dataKey="value" radius={5}>
                                            <LabelList
                                                position="insideLeft"
                                                dataKey="label"
                                                fill="white"
                                                offset={8}
                                                fontSize={12}
                                            />
                                        </Bar>
                                    </BarChart>
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex flex-row border-t p-4">
                                <div className="flex w-full items-center gap-2">
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Desktops</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {Math.round(((reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.desktopCount || 0) /
                                                (reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.totalCount || 1)) * 100)}
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Mobiles</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {Math.round(((reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.mobileCount || 0) /
                                                (reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.totalCount || 1)) * 100)}
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
                    {(reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.totalCount || 0) > 0 &&
                        (reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.compliantDeviceCount || 0) +
                        (reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.nonCompliantDeviceCount || 0) > 0 && (
                            <Card className="w-full">
                                <CardHeader className="space-y-0 pb-2 flex-row">
                                    <CircleCheckBig className="pr-2 size-8" />
                                    <CardTitle className="text-2xl tabular-nums ">
                                        Device compliance
                                    </CardTitle>
                                </CardHeader>
                                <CardContent className="flex pb-2 h-[250px]">
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
                                                        value: reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.compliantDeviceCount || 0,
                                                        fill: "var(--color-compliant)",
                                                    },
                                                    {
                                                        name: "Non-compliant",
                                                        value: reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.nonCompliantDeviceCount || 0,
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
                                                    const compliant = reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.compliantDeviceCount || 0;
                                                    const nonCompliant = reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.nonCompliantDeviceCount || 0;
                                                    const total = compliant + nonCompliant;
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
                                                    const compliant = reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.compliantDeviceCount || 0;
                                                    const nonCompliant = reportData.TenantInfo?.DeviceOverview?.DeviceCompliance?.nonCompliantDeviceCount || 0;
                                                    const total = compliant + nonCompliant;
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

                    {/* Corporate vs Personal chart */}
                    {(reportData.TenantInfo?.DeviceOverview?.ManagedDevices?.totalCount || 0) > 0 &&
                        (reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.corporateCount || 0) +
                        (reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.personalCount || 0) > 0 && (
                            <Card className="w-full">
                                <CardHeader className="space-y-0 pb-2 flex-row">
                                    <Briefcase className="pr-2 size-8" />
                                    <CardTitle className="text-2xl tabular-nums ">
                                        Device ownership
                                    </CardTitle>
                                </CardHeader>
                                <CardContent className="flex pb-2 h-[250px]">
                                    <ChartContainer
                                        config={{
                                            corporate: {
                                                label: "Corporate",
                                                color: "hsl(217, 91%, 60%)",
                                            },
                                            personal: {
                                                label: "Personal",
                                                color: "hsl(280, 85%, 60%)",
                                            },
                                        }}
                                        className="mx-auto aspect-square w-full max-h-full"
                                    >
                                        <PieChart margin={{ top: 5, right: 5, bottom: 5, left: 5 }}>
                                            <Pie
                                                data={[
                                                    {
                                                        name: "Corporate",
                                                        value: reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.corporateCount || 0,
                                                        fill: "var(--color-corporate)",
                                                    },
                                                    {
                                                        name: "Personal",
                                                        value: reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.personalCount || 0,
                                                        fill: "var(--color-personal)",
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
                                                <Cell fill="var(--color-corporate)" />
                                                <Cell fill="var(--color-personal)" />
                                            </Pie>
                                            <ChartTooltip content={<ChartTooltipContent />} />
                                        </PieChart>
                                    </ChartContainer>
                                </CardContent>
                                <CardFooter className="flex flex-row border-t p-4">
                                    <div className="flex w-full items-center gap-2">
                                        <div className="grid flex-1 auto-rows-min gap-0.5">
                                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                <div className="w-3 h-3 rounded-sm bg-blue-500"></div>
                                                Corporate
                                            </div>
                                            <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                {(() => {
                                                    const corporate = reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.corporateCount || 0;
                                                    const personal = reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.personalCount || 0;
                                                    const total = corporate + personal;
                                                    return total > 0 ? Math.round((corporate / total) * 100) : 0;
                                                })()}
                                                <span className="text-sm font-normal text-muted-foreground">
                                                    %
                                                </span>
                                            </div>
                                        </div>
                                        <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                        <div className="grid flex-1 auto-rows-min gap-0.5">
                                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                                                <div className="w-3 h-3 rounded-sm bg-purple-500"></div>
                                                Personal
                                            </div>
                                            <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                                {(() => {
                                                    const corporate = reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.corporateCount || 0;
                                                    const personal = reportData.TenantInfo?.DeviceOverview?.DeviceOwnership?.personalCount || 0;
                                                    const total = corporate + personal;
                                                    return total > 0 ? Math.round((personal / total) * 100) : 0;
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

                                            {/* Desktop devices chart */}
                    {reportData.TenantInfo?.DeviceOverview?.DesktopDevicesSummary?.nodes && reportData.TenantInfo.DeviceOverview.DesktopDevicesSummary.nodes.length > 0 && (
                        <Card className="w-full lg:col-span-3">
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <Monitor className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">
                                    Desktop devices
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
                                    className="h-[350px] w-full"
                                >
                                    {reportData.TenantInfo?.DeviceOverview?.DesktopDevicesSummary?.nodes ? (
                                        <DesktopDevicesSankey data={reportData.TenantInfo.DeviceOverview.DesktopDevicesSummary.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex flex-row border-t p-4">
                                <div className="flex w-full items-center gap-2">
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Entra joined</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.DesktopDevicesSummary?.nodes || [];
                                                const entraJoined = nodes.find(n => n.target === "Entra joined")?.value || 0;
                                                const windowsDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "Windows")?.value || 0;
                                                const macOSDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "macOS")?.value || 0;
                                                const total = windowsDevices + macOSDevices;
                                                return Math.round((entraJoined / (total || 1)) * 100);
                                            })()}
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Entra hybrid joined</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.DesktopDevicesSummary?.nodes || [];
                                                const entraHybrid = nodes.find(n => n.target === "Entra hybrid joined")?.value || 0;
                                                const windowsDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "Windows")?.value || 0;
                                                const macOSDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "macOS")?.value || 0;
                                                const total = windowsDevices + macOSDevices;
                                                return Math.round((entraHybrid / (total || 1)) * 100);
                                            })()}
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Entra registered</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.DesktopDevicesSummary?.nodes || [];
                                                const entraRegistered = nodes.find(n => n.target === "Entra registered")?.value || 0;
                                                const windowsDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "Windows")?.value || 0;
                                                const macOSDevices = nodes.find(n => n.source === "Desktop devices" && n.target === "macOS")?.value || 0;
                                                const total = windowsDevices + macOSDevices;
                                                return Math.round((entraRegistered / (total || 1)) * 100);
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

                    {/* Mobile devices chart */}
                    {reportData.TenantInfo?.DeviceOverview?.MobileSummary?.nodes && reportData.TenantInfo?.DeviceOverview?.ManagedDevices && (
                        <Card className="w-full lg:col-span-3">
                            <CardHeader className="space-y-0 pb-2 flex-row">
                                <MonitorSmartphone className="pr-2 size-8" />
                                <CardTitle className="text-2xl tabular-nums">
                                    Mobile devices
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
                                    className="h-[350px] w-full"
                                >
                                    {reportData.TenantInfo?.DeviceOverview?.MobileSummary?.nodes ? (
                                        <MobileSankey data={reportData.TenantInfo.DeviceOverview.MobileSummary.nodes} />
                                    ) : (
                                        <div className="flex items-center justify-center h-32 text-muted-foreground">
                                            No data available
                                        </div>
                                    )}
                                </ChartContainer>
                            </CardContent>
                            <CardFooter className="flex flex-row border-t p-4">
                                <div className="flex w-full items-center gap-2">
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Android compliant</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.MobileSummary?.nodes || [];
                                                const androidCompliant = nodes.filter(n => n.source?.includes("Android") && n.target === "Compliant").reduce((sum, n) => sum + (n.value || 0), 0);
                                                const androidTotal = nodes.find(n => n.source === "Mobile devices" && n.target === "Android")?.value || 0;
                                                return androidTotal > 0 ? Math.round((androidCompliant / androidTotal) * 100) : 0;
                                            })()}
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">iOS compliant</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.MobileSummary?.nodes || [];
                                                const iosCompliant = nodes.filter(n => n.source?.includes("iOS") && n.target === "Compliant").reduce((sum, n) => sum + (n.value || 0), 0);
                                                const iosTotal = nodes.find(n => n.source === "Mobile devices" && n.target === "iOS")?.value || 0;
                                                return iosTotal > 0 ? Math.round((iosCompliant / iosTotal) * 100) : 0;
                                            })()}
                                            <span className="text-sm font-normal text-muted-foreground">
                                                %
                                            </span>
                                        </div>
                                    </div>
                                    <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                    <div className="grid flex-1 auto-rows-min gap-0.5">
                                        <div className="text-xs text-muted-foreground">Total devices</div>
                                        <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                            {(() => {
                                                const nodes = reportData.TenantInfo?.DeviceOverview?.MobileSummary?.nodes || [];
                                                const androidTotal = nodes.find(n => n.source === "Mobile devices" && n.target === "Android")?.value || 0;
                                                const iosTotal = nodes.find(n => n.source === "Mobile devices" && n.target === "iOS")?.value || 0;
                                                return androidTotal + iosTotal;
                                            })()}
                                        </div>
                                    </div>
                                </div>
                            </CardFooter>
                        </Card>
                    )}

                </div>
            </div>
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
