import { useContext } from "react";
import { Tags } from "lucide-react";
import { reportData } from "@/config/report-data";
import { ThemeProviderContext } from "@/contexts/ThemeContext";
import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";

export function SensitivityLabelProtectionSankey() {
    const theme = useContext(ThemeProviderContext);
    const isDark = theme.theme === "dark" ||
        (theme.theme === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches);
    const data = reportData.TenantInfo?.SensitivityLabelProtection;

    const total = Number(data?.totalLabelCount) || 0;
    const branches = [
        { name: "Encryption + DKE", count: Number(data?.encryptionDkeCount) || 0, color: "hsl(262, 83%, 58%)" },
        { name: "Encryption", count: Number(data?.encryptionCount) || 0, color: "hsl(217, 91%, 60%)" },
        { name: "Visual marking only", count: Number(data?.visualMarkingOnlyCount) || 0, color: "hsl(43, 96%, 56%)" },
        { name: "Classification only", count: Number(data?.classificationOnlyCount) || 0, color: "hsl(220, 9%, 55%)" },
    ];
    const encryptionPercent = total > 0
        ? Math.round(100 * (branches[0].count + branches[1].count) / total)
        : 0;
    const noEncryptionPercent = 100 - encryptionPercent;
    const source = `${total} labels`;
    const chartBranches = branches.map((branch) => ({
        ...branch,
        label: `${branch.name} · ${branch.count} (${total > 0 ? Math.round(100 * branch.count / total) : 0}%)`,
    }));

    return (
        <Card className="h-full">
            <CardHeader className="flex-row space-y-0 pb-2">
                <Tags className="size-8 pr-2" />
                <div>
                    <CardTitle className="text-2xl tabular-nums">
                        Sensitivity label protection
                    </CardTitle>
                    <CardDescription className="mt-1">
                        Strongest protection applied by configured sensitivity labels.
                    </CardDescription>
                </div>
            </CardHeader>
            <CardContent className="w-full">
                {!data ? (
                    <div className="flex h-[320px] items-center justify-center text-sm text-muted-foreground">
                        No data available.
                    </div>
                ) : total === 0 ? (
                    <div className="flex h-[320px] items-center justify-center text-2xl font-semibold tabular-nums">
                        0 labels
                    </div>
                ) : (
                    <div className="h-[320px]">
                        <ZtResponsiveSankey
                            isDark={isDark}
                            data={{
                                nodes: [
                                    { id: source, nodeColor: "hsl(142, 71%, 45%)" },
                                    ...chartBranches.map((branch) => ({ id: branch.label, nodeColor: branch.color })),
                                ],
                                links: chartBranches.map((branch) => ({
                                    source,
                                    target: branch.label,
                                    value: branch.count,
                                })),
                            }}
                        />
                    </div>
                )}
            </CardContent>
            {data && total > 0 && (
                <CardFooter className="flex flex-row border-t p-4">
                    <div className="flex w-full items-center gap-2">
                        <div className="grid flex-1 gap-0.5">
                            <div className="text-xs text-muted-foreground">Encryption</div>
                            <div className="text-2xl font-bold tabular-nums">{encryptionPercent}%</div>
                        </div>
                        <Separator orientation="vertical" className="mx-2 h-10 w-px" />
                        <div className="grid flex-1 gap-0.5">
                            <div className="text-xs text-muted-foreground">No encryption</div>
                            <div className="text-2xl font-bold tabular-nums">{noEncryptionPercent}%</div>
                        </div>
                    </div>
                </CardFooter>
            )}
        </Card>
    );
}
