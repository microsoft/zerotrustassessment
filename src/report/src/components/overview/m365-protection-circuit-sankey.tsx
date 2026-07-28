import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { SankeyDataNode } from "@/config/report-data";
import { ThemeProviderContext } from "@/contexts/ThemeContext";
import { useContext } from "react";

export const M365ProtectionCircuitSankey = ({ data }: { data: SankeyDataNode[] }) => {
    const theme = useContext(ThemeProviderContext);
    const isDark = theme.theme === "dark" || theme.theme === "system" && window.matchMedia("(prefers-color-scheme: dark)").matches;

    return (
        <ZtResponsiveSankey isDark={isDark} data={{
            nodes: [
                { id: "Total M365 traffic", nodeColor: "hsl(215, 16%, 47%)" },
                { id: "Unprotected - not acquired (25376)", nodeColor: "hsl(0, 84%, 60%)" },
                { id: "Acquired via Global Secure Access (25376)", nodeColor: "hsl(142, 71%, 45%)" },
                { id: "Enforced - compliant network (25379)", nodeColor: "hsl(142, 71%, 45%)" },
                { id: "Acquired but not enforced (25379)", nodeColor: "hsl(0, 84%, 60%)" },
                { id: "Acquired, enforcement needs review (25379)", nodeColor: "hsl(45, 93%, 47%)" },
                { id: "Acquisition needs review (25376)", nodeColor: "hsl(45, 93%, 47%)" },
                { id: "Acquisition not applicable (25376)", nodeColor: "hsl(215, 16%, 47%)" },
                { id: "Enforcement not applicable (25379)", nodeColor: "hsl(215, 16%, 47%)" },
            ],
            links: data,
        }} />
    );
};
