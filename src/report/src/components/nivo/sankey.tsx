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
    links: any[]; // replace with the actual type of links
};

export const ZtResponsiveSankey = ({ isDark, data }: { isDark:boolean, data: SankeyData }) => {
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
        data={data}
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
