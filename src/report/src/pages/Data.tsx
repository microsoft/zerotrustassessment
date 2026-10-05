import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { DlpWorkloadCoverageCard } from "@/components/overview/dlp-workload-coverage";
import { SensitivityLabelProtectionSankey } from "@/components/overview/sensitivity-label-protection-sankey";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";

export default function Data() {
    const hasSensitivityLabelProtection = Object.prototype.hasOwnProperty.call(
        reportData.TenantInfo ?? {},
        "SensitivityLabelProtection",
    );
    const hasDlpWorkloadCoverage = Object.prototype.hasOwnProperty.call(
        reportData.TenantInfo ?? {},
        "DlpWorkloadCoverage",
    );

    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Data</PageHeaderHeading>
            </PageHeader>
            {(hasSensitivityLabelProtection || hasDlpWorkloadCoverage) && (
                <div className="mb-6 grid grid-cols-1 items-stretch gap-6 lg:grid-cols-2">
                    {hasSensitivityLabelProtection && <SensitivityLabelProtectionSankey />}
                    {hasDlpWorkloadCoverage && (
                        <DlpWorkloadCoverageCard data={reportData.TenantInfo?.DlpWorkloadCoverage} />
                    )}
                </div>
            )}
            <Card>
                <CardHeader>
                    <CardTitle className="mb-3">Assessment results</CardTitle>
                    <CardDescription>
                        The results presented below are based on the security principles detailed in the{" "}
                        <a
                            href="https://learn.microsoft.com/en-us/purview/configure-security"
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-primary font-medium underline underline-offset-4 hover:underline"
                        >
                            Configuring Microsoft Purview for increased security
                        </a>
                        {" "}guide.
                    </CardDescription>
                </CardHeader>
                <CardContent className="gap-4 px-4 pb-4 pt-1">
                    <DataTable columns={columns} data={reportData.Tests} pillar="Data" />
                </CardContent>
            </Card>
        </>
    )
}
