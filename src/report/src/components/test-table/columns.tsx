import { ColumnDef } from "@tanstack/react-table"
import { Test } from "@/config/report-data"
import { ArrowUpDown, MoreHorizontal } from "lucide-react"
import { Button } from "../ui/button"
import { Badge } from "../ui/badge"
import { impacts, statuses } from "./data-icons"
import { StatusIcon } from "../status-icon"

export const columns: ColumnDef<Test>[] = [
    {
        accessorKey: "TestTitle",
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Name
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
    },
    {
        accessorKey: "TestImpact",
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Impact
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            const impact = impacts.find(
                (impact) => impact.value === row.getValue("TestImpact")
            )

            if (!impact) {
                return null
            }

            return (
                <div className="flex items-center">
                    {impact.icon && (
                        <impact.icon className="mr-2 h-4 w-4 text-muted-foreground" />
                    )}
                    <span>{impact.label}</span>
                </div>
            )
        },
    },
    {
        accessorKey: "TestStatus",
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Status
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            return (
                <StatusIcon Item={row.original} />
            )
        },
    },

]
