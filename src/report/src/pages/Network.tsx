import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { MaturityHeatmap } from "@/components/maturity/MaturityHeatmap";
import { MaturityStackedBar } from "@/components/maturity/MaturityStackedBar";

export default function Network() {
    const hasZtmm = reportData.Tests.some(t => t.TestPillar === 'Network' && t.ZtmmMaturity);

    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Network</PageHeaderHeading>
            </PageHeader>

            {hasZtmm && (
                <div className="space-y-6 mb-6">
                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle>Function Breakdown</CardTitle>
                            <CardDescription>Passed vs. failed tests by ZTMM function</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <MaturityStackedBar tests={reportData.Tests} pillar="Network" className="w-full h-[300px]" />
                        </CardContent>
                    </Card>
                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle>Maturity Heatmap</CardTitle>
                            <CardDescription>Pass rates by ZTMM function and maturity level</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <MaturityHeatmap tests={reportData.Tests} pillar="Network" />
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
                            href="https://learn.microsoft.com/en-us/entra/fundamentals/configure-security"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary font-medium underline underline-offset-4 hover:underline"
                        >
                            Configuring Microsoft Entra and Azure for increased security
                        </a>
                        {" "}guide.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                    <DataTable columns={columns} data={reportData.Tests} pillar="Network" />
                </CardContent>
            </Card>
        </>
    )
}
