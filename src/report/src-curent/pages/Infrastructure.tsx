import { ShieldCheck } from "lucide-react";
import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";
import { CloudSecureScoreCard, RecommendationsBySeverity } from "@/components/overview/infrastructure-insights";

export default function Infrastructure() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Infrastructure</PageHeaderHeading>
            </PageHeader>
            <Card className="mb-[26px]">
                <CardContent className="px-4 pb-3 pt-1">
                    <Accordion type="single" collapsible defaultValue="infrastructure-insights" className="w-full">
                        <AccordionItem value="infrastructure-insights" className="border-b-0">
                            <AccordionTrigger className="py-3 hover:no-underline">
                                <div className="flex items-center gap-2 text-left">
                                    <ShieldCheck className="size-5" />
                                    <span className="text-base font-semibold">Infrastructure insights</span>
                                </div>
                            </AccordionTrigger>
                            <AccordionContent className="pb-2">
                                <div className="grid grid-cols-1 items-stretch gap-4 lg:grid-cols-4">
                                    <div className="min-w-0 lg:col-span-3">
                                        <RecommendationsBySeverity tests={reportData.Tests} />
                                    </div>
                                    <div className="min-w-0">
                                        <CloudSecureScoreCard data={reportData.TenantInfo?.OverviewCloudSecureScore} />
                                    </div>
                                </div>
                            </AccordionContent>
                        </AccordionItem>
                    </Accordion>
                </CardContent>
            </Card>
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
