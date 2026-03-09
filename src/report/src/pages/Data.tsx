import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";

export default function Data() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Data</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle className="mb-3">Assessment results</CardTitle>
                    <CardDescription>
                        The results presented below are based on data protection principles.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                    <DataTable columns={columns} data={reportData.Tests} pillar="Data" />
                </CardContent>
            </Card>
        </>
    )
}
