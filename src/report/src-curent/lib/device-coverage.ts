import { formatNumber } from "@/lib/format-utils";

type DeviceCounts = {
    windowsCount?: number | null;
    macOSCount?: number | null;
    iosCount?: number | null;
    androidCount?: number | null;
    linuxCount?: number | null;
};

export type DeviceCoverageRow = {
    os: string;
    total: number;
    covered: number;
    notCovered: number;
    label: string;
    available: boolean;
};

export const buildDeviceCoverageRows = (
    totals: DeviceCounts | null | undefined,
    installed: DeviceCounts | null | undefined,
): DeviceCoverageRow[] | null => {
    if (!installed) return null;

    const platforms = [
        { os: "Windows", key: "windowsCount" },
        { os: "macOS", key: "macOSCount" },
        { os: "iOS/iPadOS", key: "iosCount" },
        { os: "Android", key: "androidCount" },
        { os: "Linux", key: "linuxCount" },
    ] as const;

    return platforms.map(({ os, key }) => {
        const total = Math.max(0, Number(totals?.[key]) || 0);
        const covered = Math.max(0, Number(installed[key]) || 0);
        const available = covered <= total;
        const percent = available && total > 0 ? Math.round((covered / total) * 100) : 0;

        return {
            os,
            total,
            covered: available ? covered : 0,
            notCovered: available ? total - covered : 0,
            label: available
                ? `${formatNumber(covered)}/${formatNumber(total)} (${percent}%)`
                : "Coverage unavailable",
            available,
        };
    });
};
