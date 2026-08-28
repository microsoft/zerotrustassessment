import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { M365ProtectionCircuitSankeyData } from "@/config/report-data";
import { ThemeProviderContext } from "@/contexts/ThemeContext";
import { Badge } from "@/components/ui/badge";
import { useContext } from "react";

function getVerdictBadgeVariant(status?: string): "success" | "destructive" | "warning" | "secondary" {
    switch (status) {
        case "Passed": return "success";
        case "Failed": return "destructive";
        case "Investigate": return "warning";
        default: return "secondary";
    }
}

export const M365ProtectionCircuitSankey = ({ data }: { data: M365ProtectionCircuitSankeyData }) => {
    const theme = useContext(ThemeProviderContext);
    const isDark = theme.theme === "dark" || theme.theme === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches;

    return (
        <>
            {(data.overallStatus || data.gates?.length) && (
                <div className="mb-3 flex flex-wrap items-center gap-x-5 gap-y-2 text-sm" aria-label="Microsoft 365 protection circuit verdicts">
                    <div className="flex items-center gap-2 font-medium">
                        <span>Circuit</span>
                        <Badge variant={getVerdictBadgeVariant(data.overallStatus)}>
                            {data.overallStatus ?? "Unavailable"}
                        </Badge>
                    </div>
                    {data.gates?.map((stage) => (
                        <div key={stage.testId} className="flex items-center gap-2">
                            <span>{stage.name}</span>
                            <Badge variant={getVerdictBadgeVariant(stage.status)}>{stage.status}</Badge>
                        </div>
                    ))}
                </div>
            )}
            <div className="h-80">
                <ZtResponsiveSankey isDark={isDark} data={{
                    nodes: [
                        { id: "Total M365 traffic", nodeColor: "hsl(215, 16%, 47%)" },
                        { id: "Unprotected - not acquired", nodeColor: "hsl(0, 84%, 60%)" },
                        { id: "Acquired via Global Secure Access", nodeColor: "hsl(142, 71%, 45%)" },
                        { id: "Enforced - compliant network", nodeColor: "hsl(142, 71%, 45%)" },
                        { id: "Acquired but not enforced", nodeColor: "hsl(0, 84%, 60%)" },
                        { id: "Acquired, enforcement needs review", nodeColor: "hsl(45, 93%, 47%)" },
                        { id: "Acquisition needs review", nodeColor: "hsl(45, 93%, 47%)" },
                        { id: "Acquisition unavailable", nodeColor: "hsl(215, 16%, 47%)" },
                        { id: "Enforcement unavailable", nodeColor: "hsl(215, 16%, 47%)" },
                    ],
                    links: data.nodes,
                }} />
            </div>
        </>
    );
};
