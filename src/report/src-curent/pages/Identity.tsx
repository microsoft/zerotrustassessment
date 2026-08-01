import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Fingerprint, Info, Layers3, Luggage, ShieldCheck, User, UserCog, Users } from "lucide-react";
import { ChartContainer } from "@/components/ui/chart";
import { AuthMethodSankey } from "@/components/overview/authMethod-sankey";
import { CaSankey } from "@/components/overview/ca-sankey";
import { CaDeviceSankey } from "@/components/overview/caDevice-sankey";

const formatMetric = (value: number | null | undefined): string => {
    const safeValue = Number(value) || 0;
    return safeValue.toLocaleString();
};

export default function Identity() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Identity</PageHeaderHeading>
            </PageHeader>

            <Card>
                <CardContent className="px-4 pb-3 pt-1">
                    <Accordion type="single" collapsible defaultValue="identity-insights" className="w-full">
                        <AccordionItem value="identity-insights" className="border-b-0">
                            <AccordionTrigger className="py-3 hover:no-underline">
                                <div className="flex items-center gap-2 text-left">
                                    <Fingerprint className="size-5" />
                                    <span className="text-base font-semibold">Identity insights</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent className="pb-2">
                                <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                                    <Card className="flex h-full flex-col">
                                        <CardHeader className="flex flex-col space-y-1.5 p-6 px-4 pt-2 pb-3">
                                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                                <User className="size-5" />
                                                Users
                                            </CardTitle>
                                        </CardHeader>
                                        <CardContent className="p-6 pt-0 flex flex-1 items-center px-4 pb-4">
                                            <div className="grid w-full gap-4 grid-cols-2">
                                                <div className="flex items-center gap-3">
                                                    <span className="relative flex shrink-0 overflow-hidden size-[1.609rem] rounded-sm">
                                                        <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent" style={{ color: "var(--viz-1)" }}>
                                                            <User className="size-[1.515rem]" />
                                                        </span>
                                                    </span>
                                                    <div className="flex flex-col gap-0.5">
                                                        <span className="text-muted-foreground text-sm font-medium">Total users</span>
                                                        <span className="text-lg font-medium tabular-nums">
                                                            {formatMetric(reportData.TenantInfo?.TenantOverview?.UserCount)}
                                                        </span>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-3">
                                                    <span className="relative flex shrink-0 overflow-hidden size-[1.609rem] rounded-sm">
                                                        <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent" style={{ color: "var(--viz-1)" }}>
                                                            <Luggage className="size-[1.515rem]" />
                                                        </span>
                                                    </span>
                                                    <div className="flex flex-col gap-0.5">
                                                        <span className="text-muted-foreground text-sm font-medium">Guest users</span>
                                                        <span className="text-lg font-medium tabular-nums">
                                                            {formatMetric(reportData.TenantInfo?.TenantOverview?.GuestCount)}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardContent>
                                    </Card>

                                    <Card className="flex h-full flex-col">
                                        <CardHeader className="flex flex-col space-y-1.5 p-6 px-4 pt-2 pb-3">
                                            <CardTitle className="text-base font-semibold flex items-center gap-2">
                                                <Users className="size-5" />
                                                Groups &amp; apps
                                            </CardTitle>
                                        </CardHeader>
                                        <CardContent className="p-6 pt-0 flex flex-1 items-center px-4 pb-4">
                                            <div className="grid w-full gap-4 grid-cols-2">
                                                <div className="flex items-center gap-3">
                                                    <span className="relative flex shrink-0 overflow-hidden size-[1.609rem] rounded-sm">
                                                        <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent" style={{ color: "var(--viz-3)" }}>
                                                            <Users className="size-[1.515rem]" />
                                                        </span>
                                                    </span>
                                                    <div className="flex flex-col gap-0.5">
                                                        <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                                            Groups
                                                            <Info className="size-3.5 shrink-0 opacity-70" />
                                                        </span>
                                                        <span className="text-lg font-medium tabular-nums">
                                                            {formatMetric(reportData.TenantInfo?.TenantOverview?.GroupCount)}
                                                        </span>
                                                    </div>
                                                </div>
                                                <div className="flex items-center gap-3">
                                                    <span className="relative flex shrink-0 overflow-hidden size-[1.609rem] rounded-sm">
                                                        <span className="flex h-full w-full items-center justify-center shrink-0 rounded-sm bg-transparent" style={{ color: "var(--viz-3)" }}>
                                                            <Layers3 className="size-[1.515rem]" />
                                                        </span>
                                                    </span>
                                                    <div className="flex flex-col gap-0.5">
                                                        <span className="text-muted-foreground text-sm font-medium flex items-center gap-1">
                                                            Apps
                                                            <Info className="size-3.5 shrink-0 opacity-70" />
                                                        </span>
                                                        <span className="text-lg font-medium tabular-nums">
                                                            {formatMetric(reportData.TenantInfo?.TenantOverview?.ApplicationCount)}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardContent>
                                    </Card>

                                    <Card className="w-full" x-chunk="charts-01-chunk-0">
                                        <CardHeader className="space-y-2 pt-3 pb-3">
                                            <div className="flex flex-row items-center gap-2">
                                                <UserCog className="size-8" />
                                                <CardTitle className="text-2xl tabular-nums">
                                                    Privileged users auth methods
                                                </CardTitle>
                                            </div>
                                            <CardDescription>
                                                {reportData.TenantInfo?.OverviewAuthMethodsPrivilegedUsers?.description || "No description available"}
                                            </CardDescription>
                                        </CardHeader>
                                        <CardContent className="pt-1 h-[360px]">
                                            <ChartContainer
                                                config={{
                                                    steps: {
                                                        label: "Steps",
                                                        color: "hsl(var(--chart-1))",
                                                    },
                                                }}
                                                className="h-[360px] w-full"
                                            >
                                                {reportData.TenantInfo?.OverviewAuthMethodsPrivilegedUsers?.nodes ? (
                                                    <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsPrivilegedUsers.nodes} />
                                                ) : (
                                                    <div className="flex items-center justify-center h-32 text-muted-foreground">No data available</div>
                                                )}
                                            </ChartContainer>
                                        </CardContent>
                                    </Card>

                                    <Card className="w-full" x-chunk="charts-01-chunk-0">
                                        <CardHeader className="space-y-2 pt-3 pb-3">
                                            <div className="flex flex-row items-center gap-2">
                                                <Users className="size-8" />
                                                <CardTitle className="text-2xl tabular-nums">
                                                    All users auth methods
                                                </CardTitle>
                                            </div>
                                            <CardDescription>
                                                {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.description || "No description available"}
                                            </CardDescription>
                                        </CardHeader>
                                        <CardContent className="pt-1 h-[360px]">
                                            <ChartContainer
                                                config={{
                                                    steps: {
                                                        label: "Steps",
                                                        color: "hsl(var(--chart-1))",
                                                    },
                                                }}
                                                className="h-[360px] w-full"
                                            >
                                                {reportData.TenantInfo?.OverviewAuthMethodsAllUsers?.nodes ? (
                                                    <AuthMethodSankey data={reportData.TenantInfo.OverviewAuthMethodsAllUsers.nodes} />
                                                ) : (
                                                    <div className="flex items-center justify-center h-32 text-muted-foreground">No data available</div>
                                                )}
                                            </ChartContainer>
                                        </CardContent>
                                    </Card>

                                    <Card className="w-full" x-chunk="charts-01-chunk-0">
                                        <CardHeader className="space-y-2 pt-3 pb-3">
                                            <div className="flex flex-row items-center gap-2">
                                                <ShieldCheck className="size-8" />
                                                <CardTitle className="text-2xl tabular-nums">
                                                    User authentication
                                                </CardTitle>
                                            </div>
                                            <CardDescription>
                                                {reportData.TenantInfo?.OverviewCaMfaAllUsers?.description || "No description available"}
                                            </CardDescription>
                                        </CardHeader>
                                        <CardContent className="pt-1 h-[360px]">
                                            <ChartContainer
                                                config={{
                                                    steps: {
                                                        label: "Steps",
                                                        color: "hsl(var(--chart-1))",
                                                    },
                                                }}
                                                className="h-[360px] w-full"
                                            >
                                                {reportData.TenantInfo?.OverviewCaMfaAllUsers?.nodes ? (
                                                    <CaSankey data={reportData.TenantInfo.OverviewCaMfaAllUsers.nodes} />
                                                ) : (
                                                    <div className="flex items-center justify-center h-32 text-muted-foreground">No data available</div>
                                                )}
                                            </ChartContainer>
                                        </CardContent>
                                    </Card>

                                    <Card className="w-full" x-chunk="charts-01-chunk-0">
                                        <CardHeader className="space-y-2 pt-3 pb-3">
                                            <div className="flex flex-row items-center gap-2">
                                                <Layers3 className="size-8" />
                                                <CardTitle className="text-2xl tabular-nums">
                                                    Device sign-ins
                                                </CardTitle>
                                            </div>
                                            <CardDescription>
                                                {reportData.TenantInfo?.OverviewCaDevicesAllUsers?.description || "No description available"}
                                            </CardDescription>
                                        </CardHeader>
                                        <CardContent className="pt-1 h-[360px]">
                                            <ChartContainer
                                                config={{
                                                    steps: {
                                                        label: "Steps",
                                                        color: "hsl(var(--chart-1))",
                                                    },
                                                }}
                                                className="h-[360px] w-full"
                                            >
                                                {reportData.TenantInfo?.OverviewCaDevicesAllUsers?.nodes ? (
                                                    <CaDeviceSankey data={reportData.TenantInfo.OverviewCaDevicesAllUsers.nodes} />
                                                ) : (
                                                    <div className="flex items-center justify-center h-32 text-muted-foreground">No data available</div>
                                                )}
                                            </ChartContainer>
                                        </CardContent>
                                    </Card>
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    </Accordion>
                </CardContent>
            </Card>

            <Card className="mt-4">
                <CardHeader>
                    <CardTitle className="mb-3">Assessment results</CardTitle>
                    <CardDescription>
                        The results presented below are based on the security principles detailed in the{" "}
                        <a
                            href="https://learn.microsoft.com/en-us/entra/fundamentals/configure-security"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary font-medium underline underline-offset-4 hover:underline"
                        >
                            Configuring Microsoft Entra for increased security
                        </a>
                        {" "}guide.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                <DataTable columns={columns} data={reportData.Tests} pillar="Identity" />
                </CardContent>
            </Card>
        </>
    )
}
