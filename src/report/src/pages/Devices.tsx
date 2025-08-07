import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";


export default function Devices() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Devices</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle className="mb-3">Assessment results</CardTitle>
                    <CardDescription>Review the checks below for the assessment of your Intune and devices related configuration.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                <DataTable columns={columns} data={reportData.Tests} pillar="Devices" />
                </CardContent>
            </Card>
        </>
    )
}
