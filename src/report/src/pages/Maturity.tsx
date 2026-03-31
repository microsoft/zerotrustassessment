import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { reportData } from "@/config/report-data";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MaturityRadar } from "@/components/maturity/MaturityRadar";
import { MaturitySummaryTable } from "@/components/maturity/MaturitySummaryTable";
import { MaturityProgressionView } from "@/components/maturity/MaturityProgressionView";
import { MaturityScoreGauges } from "@/components/maturity/MaturityScoreGauges";
import { MaturityHeatmap } from "@/components/maturity/MaturityHeatmap";
import { MaturityStackedBar } from "@/components/maturity/MaturityStackedBar";
import { PILLAR_NAMES } from "@/lib/ztmm-utils";
import { Separator } from "@/components/ui/separator";

export default function Maturity() {
    const activePillars = PILLAR_NAMES.filter(pillar =>
        reportData.Tests.some(t => t.TestPillar === pillar && t.ZtmmMaturity)
    );

    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Zero Trust Maturity Model</PageHeaderHeading>
            </PageHeader>

            <div className="space-y-6">
                {/* Overview Section */}
                <div className="grid gap-6 grid-cols-1 lg:grid-cols-2">
                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle>Maturity Radar</CardTitle>
                            <CardDescription>
                                Completion percentage by maturity level across all pillars.
                                The closer the shape extends to the edge, the higher the maturity.
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <MaturityRadar className="mx-auto aspect-square w-full max-w-[450px]" />
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="pb-3">
                            <CardTitle>Maturity Scores</CardTitle>
                            <CardDescription>
                                Weighted maturity score per pillar. Initial tests count 1x, Advanced 2x, Optimal 3x.
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <MaturityScoreGauges />
                        </CardContent>
                    </Card>
                </div>

                {/* Progression and Summary */}
                <Card>
                    <CardHeader className="pb-3">
                        <CardTitle>Maturity Progression</CardTitle>
                        <CardDescription>
                            Shows progress through each maturity stage (Initial, Advanced, Optimal) per pillar.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <MaturityProgressionView />
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader className="pb-3">
                        <CardTitle>Maturity Summary</CardTitle>
                        <CardDescription>
                            Detailed breakdown of test pass rates by pillar and maturity level.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <MaturitySummaryTable />
                    </CardContent>
                </Card>

                {/* Per-Pillar Deep Dives */}
                {activePillars.map(pillar => (
                    <div key={pillar}>
                        <Separator className="my-6" />
                        <h2 className="text-xl font-bold mb-4">{pillar} Pillar</h2>
                        <div className="grid gap-6 grid-cols-1 lg:grid-cols-2">
                            <Card>
                                <CardHeader className="pb-3">
                                    <CardTitle>Function Heatmap</CardTitle>
                                    <CardDescription>
                                        Pass rates by ZTMM function and maturity level for {pillar}.
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <MaturityHeatmap tests={reportData.Tests} pillar={pillar} />
                                </CardContent>
                            </Card>

                            <Card>
                                <CardHeader className="pb-3">
                                    <CardTitle>Function Breakdown</CardTitle>
                                    <CardDescription>
                                        Stacked view of passed vs. failed tests by function for {pillar}.
                                    </CardDescription>
                                </CardHeader>
                                <CardContent>
                                    <MaturityStackedBar
                                        tests={reportData.Tests}
                                        pillar={pillar}
                                        className="w-full h-[300px]"
                                    />
                                </CardContent>
                            </Card>
                        </div>
                    </div>
                ))}
            </div>
        </>
    )
}
