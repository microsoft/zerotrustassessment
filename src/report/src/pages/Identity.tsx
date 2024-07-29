import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";

export default function Identity() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Identity</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle>Assessment results</CardTitle>
                    <CardDescription></CardDescription>
                </CardHeader>
                <CardContent className="gap-4 p-4">
                <DataTable columns={columns} data={reportData.Tests} />
                </CardContent>
            </Card>
        </>
    )
}
