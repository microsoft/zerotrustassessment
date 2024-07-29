import { ColumnDef } from "@tanstack/react-table"
import { Test } from "@/config/report-data"

export const columns: ColumnDef<Test>[] = [
  {
    accessorKey: "TestStatus",
    header: "Status",
  },
  {
    accessorKey: "TestTitle",
    header: "Check",
  },
  {
    accessorKey: "TestImpact",
    header: "Impact",
  },
]
