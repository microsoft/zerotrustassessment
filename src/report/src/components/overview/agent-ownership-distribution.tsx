import { Bot } from "lucide-react"
import { Cell, Label, Pie, PieChart } from "recharts"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ChartContainer, ChartTooltip, ChartTooltipContent, type ChartConfig } from "@/components/ui/chart"
import { formatNumber } from "@/lib/format-utils"
import type { AgentOwnershipDistribution as AgentOwnershipDistributionData } from "@/config/report-data"

const ownershipConfig = {
  ownerAndSponsor: {
    label: "Owner + Sponsor",
    color: "#107c10",
  },
  ownerOnly: {
    label: "Owner, No Sponsor",
    color: "#f7630c",
  },
  sponsorOnly: {
    label: "Sponsor, No Owner",
    color: "#d0a400",
  },
  neither: {
    label: "No Owner & No Sponsor",
    color: "#d13438",
  },
} satisfies ChartConfig

interface AgentOwnershipDistributionProps {
  data: AgentOwnershipDistributionData
}

export function AgentOwnershipDistribution({ data }: AgentOwnershipDistributionProps) {
  const chartData = [
    { key: "ownerAndSponsor", name: ownershipConfig.ownerAndSponsor.label, value: data.ownerAndSponsor, fill: ownershipConfig.ownerAndSponsor.color },
    { key: "ownerOnly", name: ownershipConfig.ownerOnly.label, value: data.ownerOnly, fill: ownershipConfig.ownerOnly.color },
    { key: "sponsorOnly", name: ownershipConfig.sponsorOnly.label, value: data.sponsorOnly, fill: ownershipConfig.sponsorOnly.color },
    { key: "neither", name: ownershipConfig.neither.label, value: data.neither, fill: ownershipConfig.neither.color },
  ]
  const total = chartData.reduce((sum, item) => sum + item.value, 0)

  return (
    <Card className="flex h-full min-h-[410px] flex-col">
      <CardHeader className="pb-2">
        <CardTitle className="flex items-start gap-2 text-xl">
          <Bot className="mt-0.5 size-5 shrink-0" />
          <span>Distribution of human ownership</span>
        </CardTitle>
        <CardDescription>How agents map to a human owner and sponsor.</CardDescription>
      </CardHeader>
      <CardContent className="flex flex-1 flex-col px-0 pb-0">
        {total > 0 ? (
          <>
            <ChartContainer config={ownershipConfig} className="mx-auto h-[205px] w-full max-w-[300px] aspect-auto">
              <PieChart accessibilityLayer>
                <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
                <Pie
                  data={chartData}
                  dataKey="value"
                  nameKey="key"
                  innerRadius={58}
                  outerRadius={86}
                  paddingAngle={2}
                  stroke="hsl(var(--card))"
                  strokeWidth={2}
                >
                  {chartData.map((item) => (
                    <Cell key={item.key} fill={item.fill} />
                  ))}
                  <Label
                    content={({ viewBox }) => {
                      if (!viewBox || !("cx" in viewBox) || !("cy" in viewBox)) return null
                      return (
                        <text x={viewBox.cx} y={viewBox.cy} textAnchor="middle" dominantBaseline="middle">
                          <tspan x={viewBox.cx} y={viewBox.cy} className="fill-foreground text-2xl font-bold tabular-nums">
                            {formatNumber(total)}
                          </tspan>
                          <tspan x={viewBox.cx} y={(viewBox.cy || 0) + 20} className="fill-muted-foreground text-xs">
                            agents
                          </tspan>
                        </text>
                      )
                    }}
                  />
                </Pie>
              </PieChart>
            </ChartContainer>

            <div className="mt-auto border-t px-5 py-4">
              <div className="grid gap-2.5">
                {chartData.map((item) => (
                  <div key={item.key} className="grid grid-cols-[12px_minmax(0,1fr)_auto] items-center gap-2 text-xs">
                    <span className="size-2.5 rounded-[3px]" style={{ backgroundColor: item.fill }} aria-hidden="true" />
                    <span className="truncate text-muted-foreground" title={item.name}>{item.name}</span>
                    <span className="font-medium tabular-nums">{formatNumber(item.value)}</span>
                  </div>
                ))}
              </div>
            </div>
          </>
        ) : (
          <div className="flex flex-1 items-center justify-center px-6 text-center text-sm text-muted-foreground">
            No agent identities were found in the tenant.
          </div>
        )}
      </CardContent>
    </Card>
  )
}
