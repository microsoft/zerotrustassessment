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
                <DataTable columns={columns} data={reportData.Tests} />
                </CardContent>
            </Card>
        </>
    )
}
