import { useContext } from "react";
import { ShieldCheck } from "lucide-react";
import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { ThemeProviderContext } from "@/contexts/ThemeContext";
import { reportData } from "@/config/report-data";
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";

/** Returns true when the Private Access checks produced funnel data. */
export function hasPrivateAccessData(): boolean {
    const nodes = reportData.TenantInfo?.OverviewPrivateAccess?.nodes;
    return Array.isArray(nodes) && nodes.length > 0;
}

export function PrivateAccessSankey() {
    const theme = useContext(ThemeProviderContext);
    const isDark = theme.theme === "dark" || (theme.theme === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches);

    const privateAccess = reportData.TenantInfo?.OverviewPrivateAccess;
    if (!privateAccess?.nodes?.length) {
        return null;
    }

    const atRisk = "hsl(0, 72%, 51%)";
    const review = "hsl(43, 96%, 56%)";
    const zeroTrust = "hsl(142, 71%, 45%)";
    // Gray marks a gate that produced no verdict, so its width is unknown rather than zero
    const unavailable = "hsl(220, 9%, 65%)";

    return (
        <Card className="h-full">
            <CardHeader className="space-y-0 pt-3 pb-3 flex-row">
                <ShieldCheck className="pr-2 size-8" />
                <div>
                    <CardTitle className="text-2xl tabular-nums">
                        Private Access Zero Trust posture
                    </CardTitle>
                    <CardDescription className="mt-1">
                        Segmentation and strong authentication are app-denominated; administration is a separate assignment band.
                    </CardDescription>
                </div>
            </CardHeader>
            <CardContent className="h-[420px] w-full">
                <ZtResponsiveSankey
                    isDark={isDark}
                    data={{
                        nodes: [
                            { id: "Private Access apps", nodeColor: "hsl(217, 91%, 60%)" },
                            { id: "Broad segments - at-risk", nodeColor: atRisk },
                            { id: "Segmentation manual review", nodeColor: review },
                            { id: "Segmentation unavailable", nodeColor: unavailable },
                            { id: "Least-privilege segments", nodeColor: zeroTrust },
                            { id: "Password-only - at-risk", nodeColor: atRisk },
                            { id: "Authentication manual review", nodeColor: review },
                            { id: "Authentication unavailable", nodeColor: unavailable },
                            // Tenant-wide admin makes the terminal Zero Trust set only conditionally trustworthy
                            { id: "Strong auth - Zero Trust", nodeColor: privateAccess.adminAtRisk ? "hsl(28, 89%, 52%)" : zeroTrust },
                            { id: "Application Administrator assignments", nodeColor: "hsl(220, 9%, 46%)" },
                            { id: "Tenant-wide admin - at-risk", nodeColor: atRisk },
                            { id: "App-scoped admin - at-risk", nodeColor: atRisk },
                            { id: "App-scoped admin - Zero Trust", nodeColor: zeroTrust },
                        ],
                        links: privateAccess.nodes,
                    }}
                />
            </CardContent>
            <CardFooter className="flex-col items-start gap-1">
                <CardDescription>{privateAccess.description}</CardDescription>
                {privateAccess.adminAtRisk && (
                    <CardDescription className="text-amber-700 dark:text-amber-400">
                        Over-privileged Application Administrator assignments can weaken segmentation and authentication for every Private Access app.
                    </CardDescription>
                )}
                {privateAccess.degraded && (
                    <CardDescription className="text-amber-700 dark:text-amber-400">
                        One or more Private Access checks produced no result, so the gray flows are unknown rather than zero.
                    </CardDescription>
                )}
                {privateAccess.populationMismatch && (
                    <CardDescription className="text-amber-700 dark:text-amber-400">
                        The segmentation and authentication checks reported different Private Access app populations; unmatched apps require review.
                    </CardDescription>
                )}
            </CardFooter>
        </Card>
    );
}
