import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import DevicesConfig from "@/components/DevicesConfig";
import { BarChart3, Settings } from "lucide-react";
import { MaturityHeatmap } from "@/components/maturity/MaturityHeatmap";
import { MaturityStackedBar } from "@/components/maturity/MaturityStackedBar";


export default function Devices() {
    const hasZtmm = reportData.Tests.some(t => t.TestPillar === 'Devices' && t.ZtmmMaturity);

    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Devices</PageHeaderHeading>
            </PageHeader>
            <Tabs defaultValue="assessment" className="w-full">
                <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="assessment" className="flex items-center gap-2">
                        <BarChart3 className="h-4 w-4" />
                        Assessment results
                    </TabsTrigger>
                    <TabsTrigger value="config" className="flex items-center gap-2">
                        <Settings className="h-4 w-4" />
                        Config
                    </TabsTrigger>
                </TabsList>
                <TabsContent value="assessment" className="space-y-4">
                    {hasZtmm && (
                        <div className="space-y-6">
                            <Card>
                                <CardHeader className="pb-3">
                                    <CardTitle>Function Breakdown</CardTitle>
                                    <CardDescription>Passed vs. failed tests by ZTMM function</CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <MaturityStackedBar tests={reportData.Tests} pillar="Devices" className="w-full h-[300px]" />
                                </CardContent>
                            </Card>
                            <Card>
                                <CardHeader className="pb-3">
                                    <CardTitle>Maturity Heatmap</CardTitle>
                                    <CardDescription>Pass rates by ZTMM function and maturity level</CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <MaturityHeatmap tests={reportData.Tests} pillar="Devices" />
                                </CardContent>
                            </Card>
                        </div>
                    )}
                    <Card>
                        <CardHeader>
                            <CardTitle className="mb-3">Assessment results</CardTitle>
                            <CardDescription>
                                The results presented below are based on the security principles detailed in the{" "}
                                <a
                                    href="https://learn.microsoft.com/intune/intune-service/protect/zero-trust-configure-security"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-primary font-medium underline underline-offset-4 hover:underline"
                                >
                                    Configuring Microsoft Intune for increased security
                                </a>
                                {" "}guide.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="gap-4 px-4 pb-4 pt-1">
                            <DataTable columns={columns} data={reportData.Tests} pillar="Devices" />
                        </CardContent>
                    </Card>
                </TabsContent>
                <TabsContent value="config" className="space-y-4">
                    <Card>
                        <CardHeader>
                            <CardTitle className="mb-3">Device Configuration</CardTitle>
                            <CardDescription>Device configuration settings and options.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="gap-4 px-4 pb-4 pt-1">
                            <DevicesConfig />
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </>
    )
}
