import { ResponsiveSankey } from "@nivo/sankey";

// make sure parent container have a defined height when using
// responsive component, otherwise height will be 0 and
// no chart will be rendered.
// website examples showcase many properties,
// you'll often use just a few of them.
type SankeyNode = {
    id: string;
    nodeColor: string;
    // other properties...
};

type SankeyData = {
    nodes: SankeyNode[];
    links: {
        source: string;
        target: string;
        value: number;
    }[];
};

type SankeyLink = {
    source: string;
    target: string;
    value: number | null;
};

type SankeyInputData = {
    nodes: SankeyNode[];
    links: SankeyLink[];
};

// A Sankey link with a missing (null / non-numeric) value should not break the whole
// graph when the rest of the links are valid. For an intermediate node the inbound flow
// equals its outbound flow, so we reconstruct a missing link's value from the sum of the
// target node's outgoing links (e.g. "User sign in -> Managed" = "Managed -> Compliant" +
// "Managed -> Non-compliant"). Genuine zero values are preserved (and later filtered out),
// only truly missing values are reconstructed; leaf links that cannot be reconstructed are
// left as NaN and dropped by the downstream validity filter.
const reconstructLinkValues = (links: SankeyLink[]): { source: string; target: string; value: number }[] => {
    const toNumber = (value: number | null): number => (value == null ? NaN : Number(value));

    return links.map(link => {
        const numericValue = toNumber(link.value);
        if (Number.isFinite(numericValue)) {
            return { source: link.source, target: link.target, value: numericValue };
        }

        const targetOutflow = links.reduce((sum, candidate) => {
            if (candidate.source !== link.target) {
                return sum;
            }
            const candidateValue = toNumber(candidate.value);
            return Number.isFinite(candidateValue) && candidateValue > 0 ? sum + candidateValue : sum;
        }, 0);

        return { source: link.source, target: link.target, value: targetOutflow > 0 ? targetOutflow : NaN };
    });
};

export const ZtResponsiveSankey = ({ isDark, data }: { isDark:boolean, data: SankeyInputData }) => {
    const validNodeIds = new Set(data.nodes.map(node => node.id));
    const sanitizedLinks = reconstructLinkValues(data.links)
        .filter(link =>
            validNodeIds.has(link.source) &&
            validNodeIds.has(link.target) &&
            Number.isFinite(link.value) &&
            link.value > 0
        );

    const connectedNodeIds = new Set<string>();
    for (const link of sanitizedLinks) {
        connectedNodeIds.add(link.source);
        connectedNodeIds.add(link.target);
    }

    const filteredData: SankeyData = {
        nodes: data.nodes.filter(node => connectedNodeIds.has(node.id)),
        links: sanitizedLinks
    };

    if (filteredData.links.length === 0 || filteredData.nodes.length === 0) {
        return (
            <div className={`flex h-full min-h-[8rem] w-full items-center justify-center px-4 text-center text-sm text-muted-foreground ${isDark ? 'sankey-dark-mode' : 'sankey-light-mode'}`}>
                No data available.
            </div>
        );
    }

    const theme = {
        tooltip: {
            container: {
                background: isDark ? 'rgba(33, 33, 33, 0.95)' : 'rgba(255, 255, 255, 0.95)',
                color: isDark ? '#ffffff' : '#000000',
                border: isDark ? '1px solid #555' : '1px solid #ccc',
                borderRadius: '4px',
                boxShadow: '0 2px 8px rgba(0, 0, 0, 0.15)',
                fontSize: '12px',
                padding: '8px 12px'
            }
        },
        labels: {
            text: {
                fontSize: 12
            }
        }
    };

    return (
    <div className={`h-full w-full ${isDark ? 'sankey-dark-mode' : 'sankey-light-mode'}`}>
        <ResponsiveSankey
        data={filteredData}
        theme={theme}
        margin={{ top: 10, right: 10, bottom: 10, left: 10 }}
        align="justify"
        colors={node => node.nodeColor}
        //colors={{ scheme: 'category10' }}
        nodeOpacity={1}
        nodeHoverOthersOpacity={0.35}
        nodeThickness={18}
        nodeSpacing={24}
        nodeBorderWidth={0}
        nodeBorderColor={{
            from: 'color',
            modifiers: [
                [
                    'darker',
                    0.8
                ]
            ]
        }}
        nodeBorderRadius={3}
        linkOpacity={0.5}
        linkHoverOthersOpacity={0.1}
        linkContract={3}
        linkBlendMode={isDark ? "lighten": "multiply" }
        enableLinkGradient={true}
        labelPosition="inside"
        labelOrientation="horizontal"
        labelPadding={16}
        labelTextColor={isDark ? '#ffffff' : '#000000'}
        sort='input'
        legends={[]}
        valueFormat={value =>
            `${value}`
        }
        // legends={[
        //     {
        //         anchor: 'bottom-right',
        //         direction: 'column',
        //         translateX: 130,
        //         itemWidth: 100,
        //         itemHeight: 14,
        //         itemDirection: 'right-to-left',
        //         itemsSpacing: 2,
        //         itemTextColor: '#999',
        //         symbolSize: 14,
        //         effects: [
        //             {
        //                 on: 'hover',
        //                 style: {
        //                     itemTextColor: '#000'
        //                 }
        //             }
        //         ]
        //     }
        // ]}
        />
    </div>
)}
