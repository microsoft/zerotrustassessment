import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { useContext } from 'react';
import { ThemeProviderContext } from '@/contexts/ThemeContext'
import { SankeyDataNode } from "@/config/report-data";

export const CaDeviceSankey = ({ data }: { data: SankeyDataNode[] }) => {
    const theme = useContext(ThemeProviderContext);

    return (
        <ZtResponsiveSankey isDark={(theme.theme === 'dark' || theme.theme === 'system' && window.matchMedia("(prefers-color-scheme: dark)").matches) ? true : false} data={{
            "nodes": [
                {
                    "id": "User sign in",
                    "nodeColor": "hsl(28, 100%, 53%)"
                },
                {
                    "id": "Unmanaged",
                    "nodeColor": "hsl(0, 100%, 50%)"
                },
                {
                    "id": "Managed",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Non-compliant",
                    "nodeColor": "hsl(0, 100%, 50%)"
                },
                {
                    "id": "Compliant",
                    "nodeColor": "hsl(99, 70%, 50%)"
                },
            ],
            "links": data
        }} />
    );
}
