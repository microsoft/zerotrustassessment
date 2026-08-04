import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";

export default function Infrastructure() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Infrastructure</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle className="mb-3">Assessment results</CardTitle>
                    <CardDescription>
                        The results below are based on Microsoft Defender for Cloud recommendations identified in the scanned environment. You must apply the following tag to each Azure subscription which you want to be included in the scan: ZeroTrustAssessment:Infrastructure.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                    <DataTable columns={columns} data={reportData.Tests} pillar="Infrastructure" />
                </CardContent>
            </Card>
        </>
    )
}
