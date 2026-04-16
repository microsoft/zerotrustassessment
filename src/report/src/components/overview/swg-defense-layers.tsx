import { useMemo, useState } from "react";
import { reportData, Test } from "@/config/report-data";
import { Badge } from "@/components/ui/badge";
import {
    Accordion,
    AccordionContent,
    AccordionItem,
    AccordionTrigger,
} from "@/components/ui/accordion";
import { CheckCircledIcon, CrossCircledIcon, QuestionMarkCircledIcon } from "@radix-ui/react-icons";

interface LayerDefinition {
    id: number;
    name: string;
    shortName: string;
    specIds: string[];
}

const DEFENSE_LAYERS: LayerDefinition[] = [
    {
        id: 1,
        name: "Context-aware network security",
        shortName: "Context-aware\nnetwork security",
        specIds: ["25406", "25407", "25410"],
    },
    {
        id: 2,
        name: "TLS inspection, WCF, & TI filtering",
        shortName: "Web content and\nthreat intelligence filtering",
        specIds: ["25411", "27001", "27002", "27003", "27004", "25408", "25409", "27000", "25412"],
    },
    {
        id: 3,
        name: "AI Gateway, content filtering & DLP",
        shortName: "Content filtering\nand network DLP",
        specIds: ["25415", "25413"],
    },
    {
        id: 4,
        name: "Cloud firewall",
        shortName: "Cloud\nfirewall",
        specIds: ["25416"],
    },
    {
        id: 5,
        name: "Advanced threat protection",
        shortName: "Advanced threat\nprotection",
        specIds: [],
    },
];

type LayerStatus = "pass" | "partial" | "fail" | "na";

interface LayerResult {
    layer: LayerDefinition;
    status: LayerStatus;
    passed: number;
    failed: number;
    total: number;
    tests: Test[];
}

function getLayerStatus(layer: LayerDefinition): LayerResult {
    if (layer.specIds.length === 0) {
        return { layer, status: "na", passed: 0, failed: 0, total: 0, tests: [] };
    }

    const matchedTests = layer.specIds
        .map((id) => reportData.Tests.find((t) => t.TestId === id))
        .filter((t): t is Test => t !== undefined);

    if (matchedTests.length === 0) {
        return { layer, status: "na", passed: 0, failed: 0, total: layer.specIds.length, tests: [] };
    }

    const passed = matchedTests.filter((t) => t.TestStatus === "Passed").length;
    const skipped = matchedTests.filter((t) => t.TestStatus === "Skipped" || t.TestStatus === "Planned").length;
    const failed = matchedTests.length - passed - skipped;

    if (passed === 0 && failed === 0) {
        return { layer, status: "na", passed, failed, total: matchedTests.length, tests: matchedTests };
    }

    let status: LayerStatus;
    if (failed === 0) {
        status = "pass";
    } else if (passed === 0) {
        status = "fail";
    } else {
        status = "partial";
    }

    return { layer, status, passed, failed, total: matchedTests.length, tests: matchedTests };
}

// Color palettes per status — each layer gets a distinct shade (muted tones for readability)
const STATUS_FILLS: Record<LayerStatus, string[]> = {
    pass:    ["#2d6b5e", "#3a8574", "#4f9e8c", "#78baa9", "#a4d4c7"], // muted teal dark→light
    partial: ["#73612f", "#8d7a45", "#a6935f", "#beac7e", "#d6c7a3"], // muted amber dark→light
    fail:    ["#7a4d5a", "#946471", "#ab7f8d", "#c19eab", "#d7bfc8"], // muted rose dark→light
    na:      ["#454554", "#5c5c6a", "#777787", "#9c9caa", "#c0c0cc"], // soft slate dark→light
};

function getStatusLabel(status: LayerStatus): string {
    switch (status) {
        case "pass": return "Pass";
        case "partial": return "Partial";
        case "fail": return "Fail";
        case "na": return "N/A";
    }
}

function getStatusBadgeVariant(status: LayerStatus): "success" | "destructive" | "warning" | "secondary" {
    switch (status) {
        case "pass": return "success";
        case "partial": return "warning";
        case "fail": return "destructive";
        default: return "secondary";
    }
}

function getTestStatusIcon(testStatus: string) {
    switch (testStatus) {
        case "Passed":
            return <CheckCircledIcon className="text-teal-600 size-4" />;
        case "Failed":
        case "Error":
            return <CrossCircledIcon className="text-rose-500/80 size-4" />;
        default:
            return <QuestionMarkCircledIcon className="text-amber-500/80 size-4" />;
    }
}

function isForwardingProfileFailed(results: LayerResult[]): boolean {
    const layer1 = results.find((r) => r.layer.id === 1);
    if (!layer1) return false;
    const forwardingTest = layer1.tests.find((t) => t.TestId === "25406");
    return forwardingTest !== undefined && forwardingTest.TestStatus !== "Passed";
}

export function SwgDefenseLayers() {
    const [hoveredLayer, setHoveredLayer] = useState<number | null>(null);

    const layerResults = useMemo(() => {
        return DEFENSE_LAYERS.map((layer) => getLayerStatus(layer));
    }, []);

    const hasSwgTests = useMemo(() => {
        const allSpecIds = DEFENSE_LAYERS.flatMap((l) => l.specIds);
        return reportData.Tests.some((t) => allSpecIds.includes(t.TestId));
    }, []);

    if (!hasSwgTests) {
        return null;
    }

    const forwardingFailed = isForwardingProfileFailed(layerResults);
    const activeLayers = layerResults.filter((r) => r.layer.specIds.length > 0);
    const failingLayers = activeLayers.filter((r) => r.status === "fail" || r.status === "partial");
    const overallPass = failingLayers.length === 0 && activeLayers.some((r) => r.status === "pass");

    // SVG concentric ellipses with 3D perspective — each inner layer shifts down
    const centerX = 210;
    const centerY = 220;
    const layerDims = [
        { rx: 195, ry: 195, dy: 0 },    // Layer 1 - outermost
        { rx: 158, ry: 155, dy: 14 },   // Layer 2
        { rx: 122, ry: 118, dy: 26 },   // Layer 3
        { rx: 88,  ry: 84,  dy: 36 },   // Layer 4
        { rx: 58,  ry: 55,  dy: 44 },   // Layer 5 - innermost
    ];

    return (
        <div className="flex flex-col gap-4">
            <div className="flex flex-col lg:flex-row gap-6 items-center">
                <div className="flex-shrink-0">
                    <svg
                        width="420"
                        height="440"
                        viewBox="0 0 420 440"
                        className="max-w-full h-auto"
                    >
                        {/* Render layers from outermost to innermost */}
                        {layerDims.map((dims, i) => {
                            const result = layerResults[i];
                            const isHovered = hoveredLayer === i;
                            const fill = STATUS_FILLS[result.status][i];
                            const cy = centerY + dims.dy;

                            // Label centered vertically in the top arc band of each ring
                            const lines = result.layer.shortName.split("\n");
                            const thisTop = centerY + dims.dy - dims.ry;
                            const nextTop = i < layerDims.length - 1
                                ? centerY + layerDims[i + 1].dy - layerDims[i + 1].ry
                                : cy; // innermost: center of ellipse
                            const bandHeight = nextTop - thisTop;
                            // Scale font size to fit the band
                            const fontSize = i <= 1 ? 14 : i <= 3 ? 12 : 13;
                            const lineHeight = fontSize + 4;
                            const textBlockHeight = lines.length * lineHeight;
                            // Center the text block vertically within the band
                            const bandMidY = thisTop + bandHeight / 2;
                            const firstLineY = bandMidY - (textBlockHeight / 2) + fontSize;

                            return (
                                <g
                                    key={i}
                                    onMouseEnter={() => setHoveredLayer(i)}
                                    onMouseLeave={() => setHoveredLayer(null)}
                                    className="cursor-pointer"
                                    opacity={hoveredLayer !== null && hoveredLayer !== i ? 0.65 : 1}
                                >
                                    <ellipse
                                        cx={centerX}
                                        cy={cy}
                                        rx={dims.rx}
                                        ry={dims.ry}
                                        fill={fill}
                                        stroke={isHovered ? "#ffffff" : "rgba(255,255,255,0.25)"}
                                        strokeWidth={isHovered ? 3 : 1.5}
                                    />
                                    {lines.map((line, lineIdx) => (
                                        <text
                                            key={lineIdx}
                                            x={centerX}
                                            y={firstLineY + lineIdx * lineHeight}
                                            textAnchor="middle"
                                            fill={i === layerDims.length - 1 ? "#52525b" : "#ffffff"}
                                            fontSize={fontSize}
                                            fontWeight="600"
                                        >
                                            {line}
                                        </text>
                                    ))}
                                </g>
                            );
                        })}

                        {/* Forwarding profile warning */}
                        {forwardingFailed && (
                            <text
                                x={centerX}
                                y={435}
                                textAnchor="middle"
                                fill="#946471"
                                fontSize="11"
                                fontWeight="600"
                            >
                                ⚠ Forwarding profile disabled — all layers effectively inactive
                            </text>
                        )}
                    </svg>
                </div>

                {/* Layer detail accordion */}
                <div className="flex-1 w-full min-w-0">
                    <div className="space-y-1">
                        <div className="flex items-center gap-2 mb-3">
                            {overallPass ? (
                                <Badge variant="success">All layers passing</Badge>
                            ) : (
                                <Badge variant="destructive">
                                    {failingLayers.length} of {activeLayers.length} active layers have issues
                                </Badge>
                            )}
                        </div>
                        <Accordion type="multiple" className="w-full">
                            {layerResults.map((result) => (
                                <AccordionItem
                                    key={result.layer.id}
                                    value={`layer-${result.layer.id}`}
                                    className="border rounded-md mb-1 px-3"
                                >
                                    <AccordionTrigger className="py-2 hover:no-underline">
                                        <div className="flex items-center gap-3 w-full">
                                            <span className="text-xs font-mono text-muted-foreground w-4">
                                                {result.layer.id}
                                            </span>
                                            <span className="text-sm font-medium flex-1 text-left">
                                                {result.layer.name}
                                            </span>
                                            <Badge
                                                variant={getStatusBadgeVariant(result.status)}
                                                className="mr-2"
                                            >
                                                {getStatusLabel(result.status)}
                                            </Badge>
                                            <span className="text-xs text-muted-foreground tabular-nums whitespace-nowrap">
                                                {result.passed}/{result.total}
                                            </span>
                                        </div>
                                    </AccordionTrigger>
                                    <AccordionContent>
                                        {result.tests.length === 0 ? (
                                            <p className="text-xs text-muted-foreground italic py-1">
                                                No test data available for this layer.
                                            </p>
                                        ) : (
                                            <div className="space-y-1 py-1">
                                                {result.tests.map((test) => (
                                                    <div
                                                        key={test.TestId}
                                                        className="flex items-center gap-2 text-xs py-0.5"
                                                    >
                                                        {getTestStatusIcon(test.TestStatus)}
                                                        <span className="text-muted-foreground font-mono">
                                                            {test.TestId}
                                                        </span>
                                                        <span className="flex-1 truncate">
                                                            {test.TestTitle}
                                                        </span>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                        {forwardingFailed && result.layer.id > 1 && (
                                            <p className="text-xs text-rose-500/80 mt-1">
                                                ⚠ This layer is effectively inactive because the Internet Access forwarding profile (25406) is not enabled.
                                            </p>
                                        )}
                                    </AccordionContent>
                                </AccordionItem>
                            ))}
                        </Accordion>
                    </div>
                </div>
            </div>
        </div>
    );
}
