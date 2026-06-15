import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, it } from "vitest";

import { ZtResponsiveSankey, type SankeyData } from "@/components/nivo/sankey";

function renderComponent(data: SankeyData, isDark = false) {
  return renderToStaticMarkup(
    React.createElement(ZtResponsiveSankey, {
      isDark,
      data,
    })
  );
}

describe("ZtResponsiveSankey", () => {
  it("renders the empty state when there are no links", () => {
    const markup = renderComponent({
      nodes: [
        {
          id: "A",
          nodeColor: "hsl(28, 100%, 53%)",
        },
        {
          id: "B",
          nodeColor: "hsl(28, 100%, 53%)",
        },
      ],
      links: [],
    });

    expect(markup).toContain("No data available.");
    expect(markup).toContain("sankey-light-mode");
  });

  it("renders a Sankey chart with real Nivo components when connected nodes and links exist", () => {
    const renderChart = () =>
      renderComponent(
        {
          nodes: [
            {
              id: "Users",
              nodeColor: "hsl(28, 100%, 53%)",
            },
            {
              id: "MFA",
              nodeColor: "hsl(200, 100%, 42%)",
            },
          ],
          links: [
            {
              source: "Users",
              target: "MFA",
              value: 12,
            },
          ],
        },
        true
      );

    expect(renderChart).not.toThrow();
    const markup = renderChart();
    expect(markup).toContain("sankey-dark-mode");
    expect(markup).not.toContain("No data available.");
  });
});
