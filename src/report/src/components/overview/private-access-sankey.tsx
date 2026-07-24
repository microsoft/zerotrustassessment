import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { ThemeProviderContext } from "@/contexts/ThemeContext";
import { SankeyDataNode } from "@/config/report-data";
import { useContext } from "react";

export const PrivateAccessSankey = ({ data, adminAtRisk }: { data: SankeyDataNode[]; adminAtRisk: boolean }) => {
    const theme = useContext(ThemeProviderContext);
    const isDark = theme.theme === 'dark' || (theme.theme === 'system' && window.matchMedia("(prefers-color-scheme: dark)").matches);

    return (
        <ZtResponsiveSankey isDark={isDark} data={{
            nodes: [
                { id: 'Private Access apps', nodeColor: 'hsl(217, 91%, 60%)' },
                { id: 'Broad segments - at-risk (25395)', nodeColor: 'hsl(0, 72%, 51%)' },
                { id: 'Segmentation manual review (25395)', nodeColor: 'hsl(43, 96%, 56%)' },
                { id: 'Population mismatch - manual review (25396)', nodeColor: 'hsl(43, 96%, 56%)' },
                { id: 'Least-privilege segments (25395)', nodeColor: 'hsl(142, 71%, 45%)' },
                { id: 'Password-only - at-risk (25396)', nodeColor: 'hsl(0, 72%, 51%)' },
                { id: 'Authentication manual review (25396)', nodeColor: 'hsl(43, 96%, 56%)' },
                { id: 'Strong auth - Zero Trust (25396)', nodeColor: adminAtRisk ? 'hsl(28, 89%, 52%)' : 'hsl(142, 71%, 45%)' },
                { id: 'Application Administrator assignments', nodeColor: 'hsl(220, 9%, 46%)' },
                { id: 'Tenant-wide admin - at-risk (25384)', nodeColor: 'hsl(0, 72%, 51%)' },
                { id: 'App-scoped admin - Zero Trust (25384)', nodeColor: 'hsl(142, 71%, 45%)' },
            ],
            links: data,
        }} />
    );
};
