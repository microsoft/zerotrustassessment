import { ColumnDef } from "@tanstack/react-table"
import { Test } from "@/config/report-data"
import { ArrowUpDown } from "lucide-react"
import { Button } from "../ui/button"
import { impacts } from "./data-icons"
import { StatusIcon } from "../status-icon"

export const columns: ColumnDef<Test>[] = [
    {
        accessorKey: "TestId",
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    ID
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        meta: {
            label: "ID"
        }
    },
    {
        accessorKey: "TestTitle",
        meta: { label: "Name" },
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
        accessorKey: "TestCategory",
        meta: { label: "Category" },
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Category
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            const category = row.getValue("TestCategory") as string;
            if (!category) {
                return (
                    <div className="flex items-center">
                        <span className="text-muted-foreground">N/A</span>
                    </div>
                );
            }
            return (
                <div className="flex items-center">
                    <span>{category}</span>
                </div>
            )
        },
    },
    {
        accessorKey: "TestSfiPillar",
        meta: { label: "SFI Pillar" },
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    SFI Pillar
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            const sfiPillar = row.getValue("TestSfiPillar") as string;
            if (!sfiPillar) {
                return (
                    <div className="flex items-center">
                        <span className="text-muted-foreground">N/A</span>
                    </div>
                );
            }
            return (
                <div className="flex items-center">
                    <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-md">
                        {sfiPillar}
                    </span>
                </div>
            )
        },
    },
    {
        accessorKey: "TestImpact",
        meta: { label: "User Impact" },
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    User Impact
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
                    <span>{impact.label}</span>
                </div>
            )
        },
    },
    {
        accessorKey: "TestImplementationCost",
        meta: { label: "Implementation Effort" },
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Imp. Effort
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            const impact = impacts.find(
                (impact) => impact.value === row.getValue("TestImplementationCost")
            )

            if (!impact) {
                return null
            }

            return (
                <div className="flex items-center">
                    <span>{impact.label}</span>
                </div>
            )
        },
    },
    {
        accessorKey: "TestRisk",
        meta: { label: "Risk" },
        header: ({ column }) => {
            return (
                <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
                    Risk
                    <ArrowUpDown className="ml-2 h-4 w-4" />
                </Button>
            )
        },
        cell: ({ row }) => {
            const impact = impacts.find(
                (impact) => impact.value === row.getValue("TestRisk")
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
        meta: { label: "Status" },
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
