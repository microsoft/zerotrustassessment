import { ResponsiveSankey } from "@nivo/sankey";

// make sure parent container have a defined height when using
// responsive component, otherwise height will be 0 and
// no chart will be rendered.
// website examples showcase many properties,
// you'll often use just a few of them.
export const ZtResponsiveSankey = ({ isDark, data }: { isDark:boolean, data: any /* see data tab */ }) => (

    <ResponsiveSankey
        data={data}
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
        labelTextColor={{
            from: 'color',
            modifiers: [
                [
                    'darker',
                    1
                ]
            ]
        }}
        sort='input'
        legends={[]}
        valueFormat={value =>
            `${value} %`
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
)
