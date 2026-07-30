import { useMemo, useState } from "react";
import { Badge } from "@/components/ui/badge";
import {
    Accordion,
    AccordionContent,
    AccordionItem,
    AccordionTrigger,
} from "@/components/ui/accordion";
import { reportData, Test } from "@/config/report-data";
import { CheckCircledIcon, CrossCircledIcon, MinusCircledIcon, QuestionMarkCircledIcon } from "@radix-ui/react-icons";

const AVAILABILITY_IDS = ["25533"];
const APPGW_WAF_IDS = ["25541", "26879", "26881", "26882", "27015", "27016", "27017"];
const FRONTDOOR_IDS = ["25543", "26880", "26883", "26884", "27018", "27019", "27020", "27024"];
const OUTBOUND_IDS = ["25535", "25537", "25539", "25550"];
const ALL_SPEC_IDS = [...AVAILABILITY_IDS, ...APPGW_WAF_IDS, ...FRONTDOOR_IDS, ...OUTBOUND_IDS];

type PlaneStatus = "pass" | "partial" | "fail" | "na";

interface GroupResult {
    passed: number;
    failed: number;
    investigate: number;
    applicableTotal: number;
    status: PlaneStatus;
    tests: Test[];
}

function calcStatus(passed: number, failed: number, investigate: number, applicableTotal: number): PlaneStatus {
    if (applicableTotal === 0) return "na";
    if (failed > 0) return passed > 0 ? "partial" : "fail";
    if (investigate > 0) return "partial";
    return passed === applicableTotal ? "pass" : "partial";
}

function computeGroup(specIds: string[]): GroupResult {
    const tests = reportData.Tests.filter((test) => specIds.includes(String(test.TestId)));
    const passed = tests.filter((test) => test.TestStatus === "Passed").length;
    const failed = tests.filter((test) => test.TestStatus === "Failed" || test.TestStatus === "Error").length;
    const investigate = tests.filter((test) => test.TestStatus === "Investigate").length;
    const applicableTotal = passed + failed + investigate;

    return { passed, failed, investigate, applicableTotal, status: calcStatus(passed, failed, investigate, applicableTotal), tests };
}

export function hasAzureNetSecData(): boolean {
    return reportData.Tests.some((test) => ALL_SPEC_IDS.includes(String(test.TestId)));
}

function getStatusBadgeVariant(status: PlaneStatus): "success" | "destructive" | "warning" | "secondary" {
    switch (status) {
        case "pass": return "success";
        case "partial": return "warning";
        case "fail": return "destructive";
        default: return "secondary";
    }
}

function getStatusLabel(status: PlaneStatus): string {
    switch (status) {
        case "pass": return "Pass";
        case "partial": return "Partial";
        case "fail": return "Fail";
        default: return "N/A";
    }
}

function getPlaneFill(status: PlaneStatus): string {
    switch (status) {
        case "pass": return "#22C55E";
        case "partial": return "#EAB308";
        case "fail": return "#EF4444";
        default: return "#9CA3AF";
    }
}

function getTestStatusIcon(testStatus: string) {
    switch (testStatus) {
        case "Passed":
            return <CheckCircledIcon className="size-4 shrink-0 text-teal-600" />;
        case "Failed":
        case "Error":
            return <CrossCircledIcon className="size-4 shrink-0 text-rose-500" />;
        case "Investigate":
            return <QuestionMarkCircledIcon className="size-4 shrink-0 text-amber-500" />;
        case "Skipped":
        case "Planned":
        case "NotApplicable":
        default:
            return <MinusCircledIcon className="size-4 shrink-0 text-muted-foreground" />;
    }
}

export function AzureNetSecPlanes() {
    const [hoveredPlane, setHoveredPlane] = useState<number | null>(null);
    const centerY = 220;
    const {
        av, ag, fd, out,
        inbPassed, inbFailed, inbInvestigate, inbApplicableTotal, inbStatus,
    } = useMemo(() => {
        const av = computeGroup(AVAILABILITY_IDS);
        const ag = computeGroup(APPGW_WAF_IDS);
        const fd = computeGroup(FRONTDOOR_IDS);
        const out = computeGroup(OUTBOUND_IDS);

        const inbPassed = ag.passed + fd.passed;
        const inbFailed = ag.failed + fd.failed;
        const inbInvestigate = ag.investigate + fd.investigate;
        const inbApplicableTotal = ag.applicableTotal + fd.applicableTotal;
        const inbStatus = calcStatus(inbPassed, inbFailed, inbInvestigate, inbApplicableTotal);

        return {
            av, ag, fd, out,
            inbPassed, inbFailed, inbInvestigate, inbApplicableTotal, inbStatus,
        };
    }, []);

    const planes = [
        { id: 1, name: "Availability protection", summary: "Azure DDoS Protection", result: av, tests: av.tests, rx: 195, ry: 195 },
        { id: 2, name: "Inbound application protection", summary: "Application Gateway WAF and Front Door WAF", result: { passed: inbPassed, failed: inbFailed, investigate: inbInvestigate, applicableTotal: inbApplicableTotal, status: inbStatus }, tests: [...ag.tests, ...fd.tests], rx: 140, ry: 140 },
        { id: 3, name: "Outbound and east-west protection", summary: "Azure Firewall", result: out, tests: out.tests, rx: 88, ry: 88 },
    ];
    const applicablePlanes = planes.filter((plane) => plane.result.status !== "na");
    const failingPlanes = applicablePlanes.filter((plane) => plane.result.status === "fail" || plane.result.status === "partial");
    const allPlanesPass = applicablePlanes.length > 0 && applicablePlanes.every((plane) => plane.result.status === "pass");

    return (
        <div className="flex flex-col gap-4">
            <div className="flex flex-col items-center gap-6 lg:flex-row lg:items-start">
                <div className="flex-shrink-0">
                    <svg width="420" height="440" viewBox="0 0 420 440" className="max-w-full h-auto" aria-label="Azure network security defense planes">
                        {planes.map((plane) => {
                            const isHovered = hoveredPlane === plane.id;
                            const percentage = plane.result.applicableTotal > 0 ? Math.round((plane.result.passed / plane.result.applicableTotal) * 100) : 0;
                            const labelY = centerY - plane.ry + (plane.id === 1 ? 30 : 25);
                            const fill = getPlaneFill(plane.result.status);

                            return (
                                <g key={plane.id} className="cursor-pointer" opacity={hoveredPlane !== null && !isHovered ? 0.65 : 1} onMouseEnter={() => setHoveredPlane(plane.id)} onMouseLeave={() => setHoveredPlane(null)}>
                                    <ellipse cx="210" cy={centerY} rx={plane.rx} ry={plane.ry} fill={fill} stroke={isHovered ? "#ffffff" : "rgba(255,255,255,0.35)"} strokeWidth={isHovered ? 3 : 1.5} />
                                    <text x="210" y={labelY} textAnchor="middle" fill="#ffffff" fontSize={plane.id === 1 ? 14 : 12} fontWeight="600">
                                        {plane.name}
                                    </text>
                                    <text x="210" y={labelY + 18} textAnchor="middle" fill="#ffffff" fontSize="12">
                                        {plane.result.applicableTotal === 0 ? "No applicable results" : `${plane.result.passed}/${plane.result.applicableTotal} passing (${percentage}%)`}
                                    </text>
                                </g>
                            );
                        })}
                    </svg>
                </div>

                <div className="w-full min-w-0 flex-1 lg:pt-8">
                    <div className="mb-3 flex items-center gap-2">
                        <Badge variant={applicablePlanes.length === 0 ? "secondary" : allPlanesPass ? "success" : "destructive"}>
                            {applicablePlanes.length === 0
                                ? "No applicable plane results"
                                : allPlanesPass
                                    ? "All applicable defense planes pass"
                                    : `${failingPlanes.length} of ${applicablePlanes.length} applicable defense planes have issues`}
                        </Badge>
                    </div>
                    <Accordion type="multiple" className="w-full">
                        {planes.map((plane) => (
                            <AccordionItem key={plane.id} value={`plane-${plane.id}`} className="mb-1 rounded-md border px-3">
                                <AccordionTrigger className="py-2 hover:no-underline">
                                    <div className="grid w-full grid-cols-[1rem_minmax(0,1fr)_5rem_2rem] items-center gap-3 text-left">
                                        <span className="w-4 shrink-0 text-xs font-mono text-muted-foreground">{plane.id}</span>
                                        <span className="min-w-0 text-sm font-medium">{plane.name}</span>
                                        <Badge variant={getStatusBadgeVariant(plane.result.status)} className="w-16 justify-center justify-self-end">{getStatusLabel(plane.result.status)}</Badge>
                                        <span className="text-right text-xs tabular-nums text-muted-foreground">{plane.result.applicableTotal === 0 ? "N/A" : `${plane.result.passed}/${plane.result.applicableTotal}`}</span>
                                    </div>
                                </AccordionTrigger>
                                <AccordionContent>
                                    <p className="mb-2 text-xs text-muted-foreground">{plane.summary}</p>
                                    {plane.tests.length === 0 ? (
                                        <p className="py-1 text-xs italic text-muted-foreground">No applicable test results were included in the report.</p>
                                    ) : (
                                        <div className="space-y-1 py-1">
                                            {plane.tests.map((test) => (
                                                <div key={test.TestId} className="flex items-center gap-2 py-1 text-xs">
                                                    {getTestStatusIcon(test.TestStatus)}
                                                    <span className="font-mono text-muted-foreground">{test.TestId}</span>
                                                    <span className="flex-1">{test.TestTitle}</span>
                                                    <span className="shrink-0 text-muted-foreground">{test.TestStatus}</span>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                </AccordionContent>
                            </AccordionItem>
                        ))}
                    </Accordion>
                </div>
            </div>
        </div>
    );
}
