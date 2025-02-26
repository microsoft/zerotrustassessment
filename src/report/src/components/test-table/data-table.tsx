import * as React from "react"

import {
    ColumnDef,
    ColumnFiltersState,
    SortingState,
    VisibilityState,
    flexRender,
    getCoreRowModel,
    getFilteredRowModel,
    getSortedRowModel,
    useReactTable,
} from "@tanstack/react-table"

import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table"

import Markdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import { AlertTriangle, DollarSign, Users } from "lucide-react"

import { Button } from "@/components/ui/button"
import {
    DropdownMenu,
    DropdownMenuCheckboxItem,
    DropdownMenuContent,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/ui/input"

interface DataTableProps<TData extends Test, TValue> {
    columns: ColumnDef<TData, TValue>[]
    data: TData[]
}

import {
    Sheet,
    SheetContent,
    SheetHeader,
    SheetTitle,
} from "@/components/ui/sheet"
import { Test } from "@/config/report-data"
import { Card, CardContent, CardHeader, CardTitle } from "../ui/card"
import { StatusIcon } from "../status-icon"
import { Switch } from "../ui/switch"
import { Label } from "../ui/label"

export function DataTable<TData extends Test, TValue>({
    columns,
    data,
}: DataTableProps<TData, TValue>) {
    const [sorting, setSorting] = React.useState<SortingState>([])
    const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
    const [globalFilter, setGlobalFilter] = React.useState("");
    const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({
        // Hide TestImpact by default
        TestImpact: false,
        TestImplementationCost: false,
        // Hide TestId by default
        TestId: false,
        // Optionally specify other columns here (true => visible, false => hidden)
        // TestRisk: true,
        // TestStatus: true,
    })
    const [rowSelection, setRowSelection] = React.useState({})
    const [showSkipped, setShowSkipped] = React.useState(false);

    // Filter the data to exclude skipped tests unless showSkipped is true
    const filteredData = React.useMemo(() => {
        if (showSkipped) return data;
        return data.filter(item => item.TestStatus !== "Skipped");
    }, [data, showSkipped]);

    const table = useReactTable({
        data: filteredData,
        columns,
        enableRowSelection: true,
        getCoreRowModel: getCoreRowModel(),
        onSortingChange: setSorting,
        getSortedRowModel: getSortedRowModel(),
        onGlobalFilterChange: setGlobalFilter,
        onColumnFiltersChange: setColumnFilters,
        getFilteredRowModel: getFilteredRowModel(),
        onColumnVisibilityChange: setColumnVisibility,
        onRowSelectionChange: stateUpdater => {
            setRowSelection({}); // <-- First reset the current selection
            setRowSelection(stateUpdater);
        },

        state: {
            sorting,
            columnFilters,
            globalFilter,
            columnVisibility,
            rowSelection,
        },
    })

    const [sheetOpen, setSheetOpen] = React.useState(false);
    const [selectedRow, setSelectedRow] = React.useState<Test | null>(null);

    return (

        <div>
            <div className="flex items-center py-4 justify-between">
                <Input
                    placeholder="Search by name..."
                    value={globalFilter ?? ''}
                    onChange={(e) => table.setGlobalFilter(String(e.target.value))}
                    className="max-w-sm"
                />

                <div className="flex items-center gap-4">
                    <div className="flex items-center space-x-2">
                        <Switch
                            id="show-skipped"
                            checked={showSkipped}
                            onCheckedChange={setShowSkipped}
                        />
                        <Label htmlFor="show-skipped" className="text-sm whitespace-nowrap">Show all</Label>
                    </div>

                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="outline">
                                Columns
                            </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                            {table
                                .getAllColumns()
                                .filter(
                                    (column) => column.getCanHide()
                                )
                                .map((column) => {
                                    return (
                                        <DropdownMenuCheckboxItem
                                            key={column.id}
                                            className="capitalize"
                                            checked={column.getIsVisible()}
                                            onCheckedChange={(value) =>
                                                column.toggleVisibility(!!value)
                                            }
                                        >
                                            {column.columnDef.meta?.label ?? column.id}
                                        </DropdownMenuCheckboxItem>
                                    )
                                })}
                        </DropdownMenuContent>
                    </DropdownMenu>
                </div>
            </div>
            <div className="rounded-md border">
                <Table>
                    <TableHeader>
                        {table.getHeaderGroups().map((headerGroup) => (
                            <TableRow key={headerGroup.id}>
                                {headerGroup.headers.map((header) => {
                                    return (
                                        <TableHead key={header.id}>
                                            {header.isPlaceholder
                                                ? null
                                                : flexRender(
                                                    header.column.columnDef.header,
                                                    header.getContext()
                                                )}
                                        </TableHead>
                                    )
                                })}
                            </TableRow>
                        ))}
                    </TableHeader>
                    <TableBody>
                        {table.getRowModel().rows?.length ? (
                            table.getRowModel().rows.map((row) => (
                                <TableRow
                                    className="cursor-pointer"
                                    key={row.id}
                                    data-state={row.getIsSelected() && "selected"}
                                    onClick={() => {
                                        setSelectedRow(row.original);
                                        setSheetOpen(true)
                                    }}
                                >
                                    {row.getVisibleCells().map((cell) => (
                                        <TableCell key={cell.id}>
                                            {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                        </TableCell>
                                    ))}
                                </TableRow>
                            ))
                        ) : (
                            <TableRow>
                                <TableCell colSpan={columns.length} className="h-24 text-center">
                                    No results.
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </div>
            <Sheet open={sheetOpen} onOpenChange={setSheetOpen}>
                <SheetContent side="right" className="md:min-w-[700px] lg:min-w-[900px] overflow-y-auto">
                    <SheetHeader>
                        <SheetTitle className="text-2xl text-left">{selectedRow?.TestTitle}</SheetTitle>
                    </SheetHeader>
                    <div className="grid pt-10 gap-6">
                        <Card>
                            <CardHeader>
                                {/* Row of icons + labels below the title, spread out across the row */}
                                <div className="mt-2 flex w-full justify-between text-sm">
                                    {/* Risk */}
                                    <div className="flex items-center gap-2">
                                        <AlertTriangle className="h-4 w-4 text-foreground" />
                                        <span className="font-semibold">Risk:</span>
                                        <span>{selectedRow?.TestRisk ?? "N/A"}</span>
                                    </div>
                                    {/* Impact */}
                                    <div className="flex items-center gap-2">
                                        <Users className="h-4 w-4 text-foreground" />
                                        <span className="font-semibold">User Impact:</span>
                                        <span>{selectedRow?.TestImpact ?? "N/A"}</span>
                                    </div>
                                    {/* Implementation Cost */}
                                    <div className="flex items-center gap-2">
                                        <DollarSign className="h-4 w-4 text-foreground" />
                                        <span className="font-semibold">Implementation Cost:</span>
                                        <span>{selectedRow?.TestImplementationCost ?? "N/A"}</span>
                                    </div>
                                </div>
                            </CardHeader>
                        </Card>
                    </div>
                    <div className="grid pt-10 gap-6">
                        <Card>
                            <CardHeader><CardTitle>
                                <div className="flex">
                                    <span className="pr-3"> Test result → </span><StatusIcon Item={selectedRow!} />
                                </div></CardTitle>
                            </CardHeader>
                            <CardContent>
                                <Markdown className="prose max-w-fit dark:prose-invert" remarkPlugins={[remarkGfm]}>{selectedRow?.TestResult}</Markdown>
                            </CardContent>
                        </Card>

                        <Card>
                            <CardHeader><CardTitle>What was checked</CardTitle></CardHeader>
                            <CardContent>
                                <Markdown className="prose max-w-fit dark:prose-invert" remarkPlugins={[remarkGfm]}>{selectedRow?.TestDescription}</Markdown>
                            </CardContent>
                        </Card>
                    </div>
                </SheetContent>
            </Sheet>

        </div>
    )
}
