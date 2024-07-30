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

export function DataTable<TData extends Test, TValue>({
    columns,
    data,
}: DataTableProps<TData, TValue>) {
    const [sorting, setSorting] = React.useState<SortingState>([])
    const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
    const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
    const [rowSelection, setRowSelection] = React.useState({})

    const table = useReactTable({
        data,
        columns,
        enableRowSelection: true,
        getCoreRowModel: getCoreRowModel(),
        onSortingChange: setSorting,
        getSortedRowModel: getSortedRowModel(),
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
            columnVisibility,
            rowSelection,
        },
    })

    const [sheetOpen, setSheetOpen] = React.useState(false);
    const [selectedRow, setSelectedRow] = React.useState<Test | null>(null);

    return (

        <div>
            <div className="flex items-center py-4">
                <Input
                    placeholder="Search by name..."
                    value={(table.getColumn("TestTitle")?.getFilterValue() as string) ?? ""}
                    onChange={(event) =>
                        table.getColumn("TestTitle")?.setFilterValue(event.target.value)
                    }
                    className="max-w-sm"
                />
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button variant="outline" className="ml-auto">
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
                                        {column.id}
                                    </DropdownMenuCheckboxItem>
                                )
                            })}
                    </DropdownMenuContent>
                </DropdownMenu>
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
                <SheetContent side="right" className="md:min-w-[700px] lg:min-w-[900px]">
                    <SheetHeader>
                        <SheetTitle className="text-2xl text-left">{selectedRow?.TestTitle}</SheetTitle>

                    </SheetHeader>
                    <div className="grid pt-10 gap-6">
                        <Card>
                            <CardHeader><CardTitle>
                                <div className="flex">
                                    <span className="pr-3"> Test result → </span><StatusIcon Item={selectedRow!} />
                                </div></CardTitle>

                            </CardHeader>
                            <CardContent>
                                {selectedRow?.TestResult}
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
