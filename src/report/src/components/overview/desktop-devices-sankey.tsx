import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { useContext } from 'react';
import { ThemeProviderContext } from '@/contexts/ThemeContext'
import { SankeyDataNode } from "@/config/report-data";

export const DesktopDevicesSankey = ({ data }: { data: SankeyDataNode[] }) => {
    const theme = useContext(ThemeProviderContext);

    return (
        <ZtResponsiveSankey isDark={(theme.theme === 'dark' || theme.theme === 'system' && window.matchMedia("(prefers-color-scheme: dark)").matches) ? true : false} data={{
            "nodes": [
                {
                    "id": "Desktop devices",
                    "nodeColor": "hsl(28, 100%, 53%)"
                },
                {
                    "id": "Windows",
                    "nodeColor": "hsl(35, 100%, 50%)"
                },
                {
                    "id": "macOS",
                    "nodeColor": "hsl(200, 100%, 50%)"
                },
                {
                    "id": "Entra joined",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Entra registered",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Entra hybrid joined",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Compliant",
                    "nodeColor": "hsl(99, 70%, 50%)"
                },
                {
                    "id": "Non-compliant",
                    "nodeColor": "hsl(0, 100%, 50%)"
                },
                {
                    "id": "Unmanaged",
                    "nodeColor": "hsl(220, 10%, 60%)"
                },

            ],
            "links": data
        }} />
    );
}
