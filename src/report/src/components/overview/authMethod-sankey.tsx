import { ZtResponsiveSankey } from "@/components/nivo/sankey";
import { useContext } from 'react';
import { ThemeProviderContext } from '@/contexts/ThemeContext'
import { SankeyDataNode } from "@/config/report-data";

export const AuthMethodSankey = ({ data }: { data: SankeyDataNode[] }) => {
    const theme = useContext(ThemeProviderContext);

    return (
        <ZtResponsiveSankey isDark={(theme.theme === 'dark' || theme.theme === 'system' && window.matchMedia("(prefers-color-scheme: dark)").matches) ? true : false} data={{
            "nodes": [
                {
                    "id": "Users",
                    "nodeColor": "hsl(28, 100%, 53%)"
                },
                {
                    "id": "No auth registered",
                    "nodeColor": "hsl(0, 100%, 50%)"
                },
                {
                    "id": "Phishable",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Phone",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Authenticator",
                    "nodeColor": "hsl(12, 76%, 61%)"
                },
                {
                    "id": "Phish resistant",
                    "nodeColor": "hsl(99, 70%, 50%)"
                },
                {
                    "id": "Passkey",
                    "nodeColor": "hsl(99, 70%, 50%)"
                },
                {
                    "id": "WHfB",
                    "nodeColor": "hsl(99, 70%, 50%)"
                },



            ],
            "links": data
        }} />
    );
}
