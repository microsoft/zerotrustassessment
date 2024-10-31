import { PageHeader, PageHeaderHeading } from "@/components/page-header";

import {
    Area,
    AreaChart,
    Bar,
    BarChart,
    CartesianGrid,
    Label,
    LabelList,
    Line,
    LineChart,
    PolarAngleAxis,
    RadialBar,
    RadialBarChart,
    Rectangle,
    ReferenceLine,
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
} from "@/components/ui/chart"
import { Separator } from "@/components/ui/separator"
import { reportData } from "@/config/report-data";
import { CaSankey } from "@/components/overview/ca-sankey";
import { AuthMethodSankey } from "@/components/overview/authMethod-sankey";

export default function Dashboard() {


    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Overview</PageHeaderHeading>
            </PageHeader>
            <div className="chart-wrapper mx-auto flex max-w-6xl flex-col flex-wrap items-start justify-center gap-6 sm:flex-row">

                <div className="grid w-full gap-6 sm:grid-cols-2 lg:max-w-[22rem] lg:grid-cols-1 xl:max-w-[25rem]">
                    <Card
                        className="lg:max-w-md" x-chunk="charts-01-chunk-0"
                    >
                        <CardHeader className="space-y-0 pb-2">
                            <CardTitle className="text-2xl tabular-nums">
                                Privileged users → Auth methods
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
                                <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsPrivilegedUsers.nodes} />
                            </ChartContainer>
                        </CardContent>
                        <CardFooter className="flex-col items-start gap-1">
                            <CardDescription>
                                {reportData.TenantInfo.OverviewAuthMethodsPrivilegedUsers.description}
                            </CardDescription>
                        </CardFooter>
                    </Card>
                    <Card
                        className="lg:max-w-md" x-chunk="charts-01-chunk-0"
                    >
                        <CardHeader className="space-y-0 pb-2">
                            <CardTitle className="text-2xl tabular-nums">
                                All users → Auth methods
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
                                <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsAllUsers.nodes} />
                            </ChartContainer>
                        </CardContent>
                        <CardFooter className="flex-col items-start gap-1">
                            <CardDescription>
                                {reportData.TenantInfo.OverviewAuthMethodsAllUsers.description}
                            </CardDescription>
                        </CardFooter>
                    </Card>
                    {/* <Card
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
                    </Card> */}
                    <Card
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
                    </Card>
                </div>
                <div className="grid w-full flex-1 gap-6 lg:max-w-[20rem]">
                <Card
                        className="lmax-w-xs" x-chunk="charts-01-chunk-0"
                    >
                        <CardHeader className="space-y-0 pb-2">
                            <CardTitle className="text-2xl tabular-nums">
                                Conditional Access - MFA
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
                                <CaSankey data={reportData.TenantInfo.OverviewCaMfaAllUsers.nodes} />
                            </ChartContainer>
                        </CardContent>
                        <CardFooter className="flex-col items-start gap-1">
                            <CardDescription>
                            {reportData.TenantInfo.OverviewCaMfaAllUsers.description}
                            </CardDescription>
                        </CardFooter>
                    </Card>
                    <Card
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
                    </Card>
                    <Card
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
                    </Card>
                    <Card
                        className="max-w-xs" x-chunk="charts-01-chunk-4"
                    >
                        <CardContent className="flex gap-4 p-4 pb-2">
                            <ChartContainer
                                config={{
                                    move: {
                                        label: "MFA",
                                        color: "hsl(var(--chart-1))",
                                    },
                                    stand: {
                                        label: "MDM",
                                        color: "hsl(var(--chart-2))",
                                    },
                                    exercise: {
                                        label: "MAM",
                                        color: "hsl(var(--chart-3))",
                                    },
                                }}
                                className="h-[140px] w-full"
                            >
                                <BarChart
                                    margin={{
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        bottom: 10,
                                    }}
                                    data={[
                                        {
                                            activity: "MFA",
                                            value: (2500 / 3500) * 100,
                                            label: "2.5k/3.5k sign-ins",
                                            fill: "var(--color-stand)",
                                        },
                                        {
                                            activity: "MDM",
                                            value: (1200 / 3500) * 100,
                                            label: "1.2k/3.5k",
                                            fill: "var(--color-exercise)",
                                        },
                                        {
                                            activity: "Defend",
                                            value: (2000 / 3500) * 100,
                                            label: "2k/3.5k",
                                            fill: "var(--color-move)",
                                        },
                                    ]}
                                    layout="vertical"
                                    barSize={32}
                                    barGap={2}
                                >
                                    <XAxis type="number" dataKey="value" hide />
                                    <YAxis
                                        dataKey="activity"
                                        type="category"
                                        tickLine={false}
                                        tickMargin={4}
                                        axisLine={false}
                                        className="capitalize"
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
                                    <div className="text-xs text-muted-foreground">MFA</div>
                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                        71
                                        <span className="text-sm font-normal text-muted-foreground">
                                            %
                                        </span>
                                    </div>
                                </div>
                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-xs text-muted-foreground">MDM</div>
                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                        34
                                        <span className="text-sm font-normal text-muted-foreground">
                                            %
                                        </span>
                                    </div>
                                </div>
                                <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-xs text-muted-foreground">Defender</div>
                                    <div className="flex items-baseline gap-1 text-2xl font-bold tabular-nums leading-none">
                                        57%
                                        <span className="text-sm font-normal text-muted-foreground">
                                            %
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </CardFooter>
                    </Card>
                </div>
                <div className="grid w-full flex-1 gap-6">
                    <Card
                        className="max-w-xs" x-chunk="charts-01-chunk-5"
                    >
                        <CardContent className="flex gap-4 p-4">
                            <div className="grid items-center gap-2">
                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Identity</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        20/32
                                        <span className="text-sm font-normal text-muted-foreground">
                                            checks
                                        </span>
                                    </div>
                                </div>
                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Devices</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        15/20
                                        <span className="text-sm font-normal text-muted-foreground">
                                            checks
                                        </span>
                                    </div>
                                </div>
                                <div className="grid flex-1 auto-rows-min gap-0.5">
                                    <div className="text-sm text-muted-foreground">Data</div>
                                    <div className="flex items-baseline gap-1 text-xl font-bold tabular-nums leading-none">
                                        8/12
                                        <span className="text-sm font-normal text-muted-foreground">
                                            checks
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <ChartContainer
                                config={{
                                    move: {
                                        label: "Move",
                                        color: "hsl(var(--chart-1))",
                                    },
                                    exercise: {
                                        label: "Exercise",
                                        color: "hsl(var(--chart-2))",
                                    },
                                    stand: {
                                        label: "Stand",
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
                                        {
                                            activity: "stand",
                                            value: (20 / 32) * 100,
                                            fill: "var(--color-stand)",
                                        },
                                        {
                                            activity: "exercise",
                                            value: (15 / 20) * 100,
                                            fill: "var(--color-exercise)",
                                        },
                                        {
                                            activity: "move",
                                            value: (8 / 12) * 100,
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
                    <Card
                        className="max-w-xs" x-chunk="charts-01-chunk-6"
                    >
                        <CardHeader className="p-4 pb-0">
                            <CardTitle>Risk Signals</CardTitle>
                            <CardDescription>
                                You're SOC team is reviewing and resolving an average of 14 risk signals per day. Good job!
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="flex flex-row items-baseline gap-4 p-4 pt-2">
                            <div className="flex items-baseline gap-2 text-3xl font-bold tabular-nums leading-none">
                                14
                                <span className="text-sm font-normal text-muted-foreground">
                                    risks/day
                                </span>
                            </div>
                            <ChartContainer
                                config={{
                                    calories: {
                                        label: "Calories",
                                        color: "hsl(var(--chart-1))",
                                    },
                                }}
                                className="ml-auto w-[64px]"
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
                                            calories: 354,
                                        },
                                        {
                                            date: "2024-01-02",
                                            calories: 514,
                                        },
                                        {
                                            date: "2024-01-03",
                                            calories: 345,
                                        },
                                        {
                                            date: "2024-01-04",
                                            calories: 734,
                                        },
                                        {
                                            date: "2024-01-05",
                                            calories: 645,
                                        },
                                        {
                                            date: "2024-01-06",
                                            calories: 456,
                                        },
                                        {
                                            date: "2024-01-07",
                                            calories: 345,
                                        },
                                    ]}
                                >
                                    <Bar
                                        dataKey="calories"
                                        fill="var(--color-calories)"
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
                    </Card>
                    <Card
                        className="max-w-xs" x-chunk="charts-01-chunk-7"
                    >
                        <CardHeader className="space-y-0 pb-0">
                            <CardDescription>Untrusted devices signing in</CardDescription>
                            <CardTitle className="flex items-baseline gap-1 text-4xl tabular-nums">
                                120
                                <span className="font-sans text-sm font-normal tracking-normal text-muted-foreground">
                                    daily avg
                                </span>

                                <span className="font-sans text-sm font-normal tracking-normal text-muted-foreground">

                                </span>
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <ChartContainer
                                config={{
                                    time: {
                                        label: "Time",
                                        color: "hsl(var(--chart-2))",
                                    },
                                }}
                            >
                                <AreaChart
                                    accessibilityLayer
                                    data={[
                                        {
                                            date: "2024-01-01",
                                            time: 8.5,
                                        },
                                        {
                                            date: "2024-01-02",
                                            time: 7.2,
                                        },
                                        {
                                            date: "2024-01-03",
                                            time: 8.1,
                                        },
                                        {
                                            date: "2024-01-04",
                                            time: 6.2,
                                        },
                                        {
                                            date: "2024-01-05",
                                            time: 5.2,
                                        },
                                        {
                                            date: "2024-01-06",
                                            time: 8.1,
                                        },
                                        {
                                            date: "2024-01-07",
                                            time: 7.0,
                                        },
                                    ]}
                                    margin={{
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                    }}
                                >
                                    <XAxis dataKey="date" hide />
                                    <YAxis domain={["dataMin - 5", "dataMax + 2"]} hide />
                                    <defs>
                                        <linearGradient id="fillTime" x1="0" y1="0" x2="0" y2="1">
                                            <stop
                                                offset="5%"
                                                stopColor="var(--color-time)"
                                                stopOpacity={0.8}
                                            />
                                            <stop
                                                offset="95%"
                                                stopColor="var(--color-time)"
                                                stopOpacity={0.1}
                                            />
                                        </linearGradient>
                                    </defs>
                                    <Area
                                        dataKey="time"
                                        type="natural"
                                        fill="url(#fillTime)"
                                        fillOpacity={0.4}
                                        stroke="var(--color-time)"
                                    />
                                    <ChartTooltip
                                        cursor={false}
                                        content={<ChartTooltipContent hideLabel />}
                                        formatter={(value) => (
                                            <div className="flex min-w-[120px] items-center text-xs text-muted-foreground">
                                                Time in bed
                                                <div className="ml-auto flex items-baseline gap-0.5 font-mono font-medium tabular-nums text-foreground">
                                                    {value}
                                                    <span className="font-normal text-muted-foreground">
                                                        hr
                                                    </span>
                                                </div>
                                            </div>
                                        )}
                                    />
                                </AreaChart>
                            </ChartContainer>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </>
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
