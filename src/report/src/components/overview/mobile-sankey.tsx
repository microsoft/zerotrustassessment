import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { useContext } from 'react';
import { ThemeProviderContext } from '@/contexts/ThemeContext'
import { SankeyDataNode } from "@/config/report-data";

export const MobileSankey = ({ data }: { data: SankeyDataNode[] }) => {
    const theme = useContext(ThemeProviderContext);

    return (
        <ZtResponsiveSankey isDark={(theme.theme === 'dark' || theme.theme === 'system' && window.matchMedia("(prefers-color-scheme: dark)").matches) ? true : false} data={{
            "nodes": [
                {
                    "id": "Mobile devices",
                    "nodeColor": "hsl(28, 100%, 53%)"
                },
                {
                    "id": "Android",
                    "nodeColor": "hsl(35, 100%, 50%)"
                },
                {
                    "id": "iOS",
                    "nodeColor": "hsl(210, 100%, 50%)"
                },
                {
                    "id": "Android (Company)",
                    "nodeColor": "hsl(30, 100%, 45%)"
                },
                {
                    "id": "Android (Personal)",
                    "nodeColor": "hsl(40, 100%, 55%)"
                },
                {
                    "id": "iOS (Company)",
                    "nodeColor": "hsl(210, 100%, 45%)"
                },
                {
                    "id": "iOS (Personal)",
                    "nodeColor": "hsl(210, 100%, 55%)"
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
