import { Network as NetworkIcon, ShieldCheck } from "lucide-react";
import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { M365ProtectionCircuitSankey } from "@/components/overview/m365-protection-circuit-sankey";
import { PrivateAccessSankey, hasPrivateAccessData } from "@/components/overview/private-access-sankey";
import { SwgDefenseLayers, hasSwgData } from "@/components/overview/swg-defense-layers";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { columns } from "@/components/test-table/columns";
import { DataTable } from "@/components/test-table/data-table";
import { reportData } from "@/config/report-data";

export default function Network() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Network</PageHeaderHeading>
            </PageHeader>
            {(hasSwgData() || hasPrivateAccessData() || reportData.TenantInfo?.OverviewM365ProtectionCircuit?.nodes) && (
                <Card className="mb-6">
                    <CardContent className="px-4 pb-3 pt-1">
                        <Accordion type="single" collapsible defaultValue="network-insights" className="w-full">
                            <AccordionItem value="network-insights" className="border-b-0">
                                <AccordionTrigger className="py-3 hover:no-underline">
                                    <div className="flex items-center gap-2 text-left">
                                        <NetworkIcon className="size-5" />
                                        <div>
                                            <div className="text-base font-semibold">Network insights</div>
                                            <div className="text-sm font-normal text-muted-foreground">
                                                Secure Web Gateway, Private Access, and Microsoft 365 protection posture.
                                            </div>
                                        </div>
                                    </div>
                                </AccordionTrigger>
                                <AccordionContent className="pb-2">
                                    {hasSwgData() && (
                                        <Card className="h-full">
                                            <CardHeader className="flex-row space-y-0 pb-2">
                                                <ShieldCheck className="size-8 pr-2" />
                                                <div>
                                                    <CardTitle className="text-2xl tabular-nums">SWG defense-in-depth</CardTitle>
                                                    <CardDescription className="mt-1">Secure Web Gateway defense layers — internet traffic inspection posture</CardDescription>
                                                </div>
                                            </CardHeader>
                                            <CardContent>
                                                <SwgDefenseLayers />
                                            </CardContent>
                                        </Card>
                                    )}
                                    {(hasPrivateAccessData() || reportData.TenantInfo?.OverviewM365ProtectionCircuit?.nodes) && (
                                        <div className="mt-6 grid grid-cols-1 items-stretch gap-6 lg:grid-cols-2">
                                            {hasPrivateAccessData() && <PrivateAccessSankey />}
                                            {reportData.TenantInfo?.OverviewM365ProtectionCircuit?.nodes && (
                                                <Card className="h-full">
                                                    <CardHeader className="flex-row space-y-0 pb-2">
                                                        <ShieldCheck className="size-8 pr-2" />
                                                        <div>
                                                            <CardTitle className="text-2xl tabular-nums">Microsoft 365 protection circuit</CardTitle>
                                                            <CardDescription className="mt-1">Global Secure Access acquisition and compliant network enforcement</CardDescription>
                                                        </div>
                                                    </CardHeader>
                                                    <CardContent className="w-full">
                                                        <M365ProtectionCircuitSankey data={reportData.TenantInfo.OverviewM365ProtectionCircuit} />
                                                    </CardContent>
                                                    <CardFooter className="text-sm text-muted-foreground">
                                                        {reportData.TenantInfo.OverviewM365ProtectionCircuit.description}
                                                    </CardFooter>
                                                </Card>
                                            )}
                                        </div>
                                    )}
                                </AccordionContent>
                            </AccordionItem>
                        </Accordion>
                    </CardContent>
                </Card>
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
