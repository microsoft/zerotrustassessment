import { useState } from "react"
import { Bot, ChevronDown, TriangleAlert } from "lucide-react"
import { Cell, Label, Pie, PieChart } from "recharts"

import { Badge } from "@/components/ui/badge"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ChartContainer, ChartTooltip, ChartTooltipContent, type ChartConfig } from "@/components/ui/chart"
import type {
  AgentOwnershipBucket,
  AgentOwnershipDistribution as AgentOwnershipDistributionData,
} from "@/config/report-data"
import { formatNumber } from "@/lib/format-utils"
import { cn } from "@/lib/utils"

const ownershipConfig = {
  ownerAndSponsor: { label: "Owner + Sponsor", color: "#107c10" },
  ownerOnly: { label: "Owner, No Sponsor", color: "#f7630c" },
  sponsorOnly: { label: "Sponsor, No Owner", color: "#d0a400" },
  neither: { label: "No Owner & No Sponsor", color: "#d13438" },
} satisfies ChartConfig

interface AgentOwnershipDistributionProps {
  data: AgentOwnershipDistributionData
}

export function AgentOwnershipDistribution({ data }: AgentOwnershipDistributionProps) {
  const [selectedBucket, setSelectedBucket] = useState<AgentOwnershipBucket | null>(null)
  const chartData: Array<{ key: AgentOwnershipBucket; value: number; fill: string }> = [
    { key: "ownerAndSponsor", value: data.ownerAndSponsor, fill: ownershipConfig.ownerAndSponsor.color },
    { key: "ownerOnly", value: data.ownerOnly, fill: ownershipConfig.ownerOnly.color },
    { key: "sponsorOnly", value: data.sponsorOnly, fill: ownershipConfig.sponsorOnly.color },
    { key: "neither", value: data.neither, fill: ownershipConfig.neither.color },
  ]
  const total = chartData.reduce((sum, item) => sum + item.value, 0)

  const toggleBucket = (bucket: AgentOwnershipBucket) => {
    if (!data.agents) return
    setSelectedBucket((current) => current === bucket ? null : bucket)
  }

  return (
    <Card className="flex h-full min-h-[410px] flex-col">
      <CardHeader className="pb-2">
        <CardTitle className="flex items-start gap-2 text-xl">
          <Bot className="mt-0.5 size-5 shrink-0" />
          <span>Agent identity accountability</span>
        </CardTitle>
        <CardDescription>Distribution of human owners and effective sponsors.</CardDescription>
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
                    <Cell
                      key={item.key}
                      fill={item.fill}
                      className={data.agents ? "cursor-pointer outline-none" : undefined}
                      opacity={selectedBucket && selectedBucket !== item.key ? 0.45 : 1}
                      onClick={() => toggleBucket(item.key)}
                    />
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
                {chartData.map((item) => {
                  const isSelected = selectedBucket === item.key
                  const agents = data.agents?.[item.key]

                  return (
                    <div key={item.key}>
                      <button
                        type="button"
                        disabled={!data.agents}
                        aria-expanded={isSelected}
                        onClick={() => toggleBucket(item.key)}
                        className={cn(
                          "grid w-full grid-cols-[12px_minmax(0,1fr)_auto_16px] items-center gap-2 rounded-sm text-left text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
                          data.agents && "hover:text-foreground",
                        )}
                      >
                        <span className="size-2.5 rounded-[3px]" style={{ backgroundColor: item.fill }} aria-hidden="true" />
                        <span className="truncate text-muted-foreground" title={ownershipConfig[item.key].label}>
                          {ownershipConfig[item.key].label}
                        </span>
                        <span className="font-medium tabular-nums">{formatNumber(item.value)}</span>
                        <ChevronDown className={cn("size-3.5 transition-transform", isSelected && "rotate-180", !data.agents && "invisible")} />
                      </button>

                      {isSelected && agents && (
                        <ul className="ml-5 mt-2 max-h-40 space-y-1 overflow-y-auto border-l pl-3 pr-1 text-xs">
                          {agents.map((agent, index) => (
                            <li key={`${agent.displayName}-${index}`} className="flex min-h-7 items-center justify-between gap-3 border-b py-1 last:border-0">
                              <span className="min-w-0 truncate" title={agent.displayName || "Unnamed agent"}>
                                {agent.displayName || "Unnamed agent"}
                              </span>
                              {!agent.accountEnabled && <Badge variant="secondary" className="shrink-0">Disabled</Badge>}
                            </li>
                          ))}
                        </ul>
                      )}
                    </div>
                  )
                })}
              </div>

              {!!data.skippedCount && (
                <div className="mt-3 flex items-start gap-2 border-t pt-3 text-xs text-muted-foreground">
                  <TriangleAlert className="mt-0.5 size-3.5 shrink-0" />
                  <span>{formatNumber(data.skippedCount)} identities excluded due to snapshot mismatch.</span>
                </div>
              )}
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
