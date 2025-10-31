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
import { AlertTriangle, Settings, Users, Shield, Eye, Wrench, Lock, Building, Zap, Columns } from "lucide-react"

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
    pillar?: string
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
    pillar,
}: DataTableProps<TData, TValue>) {
    const [sorting, setSorting] = React.useState<SortingState>(
        pillar === "Devices"
            ? [
                { id: "TestCategory", desc: false },
                { id: "TestStatus", desc: false },
                { id: "TestTitle", desc: false }
              ]
            : []
    )
    const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
    const [globalFilter, setGlobalFilter] = React.useState("");
    const [selectedSfiPillars, setSelectedSfiPillars] = React.useState<string[]>([]);
    const [selectedRisks, setSelectedRisks] = React.useState<string[]>([]);
    const [selectedStatuses, setSelectedStatuses] = React.useState<string[]>([]);
    const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({
        // Hide TestImpact by default
        TestImpact: false,
        TestImplementationCost: false,
        // Hide TestId by default
        TestId: false,
        // Hide TestSfiPillar by default since we have toggle filters
        TestSfiPillar: false,
        // Category visible for Devices, hidden for Identity
        TestCategory: pillar === "Devices" ? true : false,
        // Optionally specify other columns here (true => visible, false => hidden)
        // TestRisk: true,
        // TestStatus: true,
    })
    const [rowSelection, setRowSelection] = React.useState({})

    // First filter by pillar if specified (for unique value calculations)
    const pillarFilteredData = React.useMemo(() => {
        if (pillar) {
            return data.filter(item =>
                item.TestPillar === pillar
            );
        }
        return data;
    }, [data, pillar]);

    // Filter the data by pillar, selected SFI pillars, risks, and statuses if any are selected
    const filteredData = React.useMemo(() => {
        let result = pillarFilteredData;

        // Filter by SFI pillars if any are selected
        if (selectedSfiPillars.length > 0) {
            result = result.filter(item =>
                item.TestSfiPillar && selectedSfiPillars.includes(item.TestSfiPillar)
            );
        }

        // Filter by risks if any are selected
        if (selectedRisks.length > 0) {
            result = result.filter(item =>
                item.TestRisk && selectedRisks.includes(item.TestRisk)
            );
        }

        // Filter by statuses if any are selected
        if (selectedStatuses.length > 0) {
            result = result.filter(item =>
                item.TestStatus && selectedStatuses.includes(item.TestStatus)
            );
        } else {
            // If no status filters are selected, exclude "Planned" items by default
            result = result.filter(item => item.TestStatus !== "Planned");
        }

        return result;
    }, [pillarFilteredData, selectedSfiPillars, selectedRisks, selectedStatuses]);

    // Get unique SFI pillars for the filter dropdown
    const uniqueSfiPillars = React.useMemo(() => {
        const pillars = pillarFilteredData
            .map(item => item.TestSfiPillar)
            .filter((pillar): pillar is string => pillar !== null && pillar !== undefined);
        return Array.from(new Set(pillars)).sort();
    }, [pillarFilteredData]);

    // Get unique risks for the filter toggles
    const uniqueRisks = React.useMemo(() => {
        const risks = pillarFilteredData
            .map(item => item.TestRisk)
            .filter((risk): risk is string => risk !== null && risk !== undefined);
        const uniqueRiskSet = Array.from(new Set(risks));
        // Custom order: High, Medium, Low
        const riskOrder = ['High', 'Medium', 'Low'];
        return uniqueRiskSet.sort((a, b) => {
            const indexA = riskOrder.indexOf(a);
            const indexB = riskOrder.indexOf(b);
            // If both are in the custom order, sort by that order
            if (indexA !== -1 && indexB !== -1) return indexA - indexB;
            // If only one is in the custom order, prioritize it
            if (indexA !== -1) return -1;
            if (indexB !== -1) return 1;
            // If neither is in the custom order, sort alphabetically
            return a.localeCompare(b);
        });
    }, [pillarFilteredData]);

    // Get unique statuses for the filter toggles
    const uniqueStatuses = React.useMemo(() => {
        const statuses = pillarFilteredData
            .map(item => item.TestStatus)
            .filter((status): status is string => status !== null && status !== undefined);
        const uniqueStatusSet = Array.from(new Set(statuses));
        // Custom order: Passed, Failed, Planned
        const statusOrder = ['Passed', 'Failed', 'Planned'];
        return uniqueStatusSet.sort((a, b) => {
            const indexA = statusOrder.indexOf(a);
            const indexB = statusOrder.indexOf(b);
            // If both are in the custom order, sort by that order
            if (indexA !== -1 && indexB !== -1) return indexA - indexB;
            // If only one is in the custom order, prioritize it
            if (indexA !== -1) return -1;
            if (indexB !== -1) return 1;
            // If neither is in the custom order, sort alphabetically
            return a.localeCompare(b);
        });
    }, [pillarFilteredData]);

    // Function to get icon for SFI pillar
    const getSfiPillarIcon = (pillar: string) => {
        if (pillar.includes("Monitor and detect")) return Eye;
        if (pillar.includes("Protect engineering")) return Wrench;
        if (pillar.includes("Protect identities")) return Lock;
        if (pillar.includes("Protect tenants")) return Building;
        if (pillar.includes("Accelerate response")) return Zap;
        return Shield; // Default icon
    };

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
                <div className="flex items-center gap-4">
                    <Input
                        placeholder="Search by name..."
                        value={globalFilter ?? ''}
                        onChange={(e) => table.setGlobalFilter(String(e.target.value))}
                        className="max-w-sm"
                    />

                    {/* Risk Filter Toggles */}
                    <div className="flex items-center gap-1">
                        <span className="text-xs font-medium text-muted-foreground mr-1">Risk:</span>
                        {uniqueRisks.map((risk) => {
                            const isSelected = selectedRisks.includes(risk);
                            const riskCount = data.filter(item => item.TestRisk === risk).length;
                            return (
                                <Button
                                    key={risk}
                                    variant={isSelected ? "default" : "outline"}
                                    size="sm"
                                    onClick={() => {
                                        if (isSelected) {
                                            setSelectedRisks(prev => prev.filter(r => r !== risk));
                                        } else {
                                            setSelectedRisks(prev => [...prev, risk]);
                                        }
                                    }}
                                    className={`text-xs h-6 px-3 py-1 rounded-full ${isSelected ? 'bg-purple-600 hover:bg-purple-700 text-white' : 'hover:bg-purple-50 hover:text-purple-700 hover:border-purple-300 dark:hover:bg-purple-950 dark:hover:text-purple-300'}`}
                                    title={`${risk} (${riskCount} tests)`}
                                >
                                    {risk}
                                </Button>
                            );
                        })}
                    </div>

                    {/* Status Filter Toggles */}
                    <div className="flex items-center gap-1">
                        <span className="text-xs font-medium text-muted-foreground mr-1">Status:</span>
                        {uniqueStatuses.map((status) => {
                            const isSelected = selectedStatuses.includes(status);
                            const statusCount = data.filter(item => item.TestStatus === status).length;

                            // Get color classes based on status type
                            const getStatusColors = (status: string, isSelected: boolean) => {
                                if (status === 'Passed') {
                                    return isSelected
                                        ? 'bg-green-600 hover:bg-green-700 text-white'
                                        : 'hover:bg-green-50 hover:text-green-700 hover:border-green-300 dark:hover:bg-green-950 dark:hover:text-green-300';
                                } else if (status === 'Failed') {
                                    return isSelected
                                        ? 'bg-red-600 hover:bg-red-700 text-white'
                                        : 'hover:bg-red-50 hover:text-red-700 hover:border-red-300 dark:hover:bg-red-950 dark:hover:text-red-300';
                                } else { // Planned and other statuses
                                    return isSelected
                                        ? 'bg-gray-600 hover:bg-gray-700 text-white'
                                        : 'hover:bg-gray-50 hover:text-gray-700 hover:border-gray-300 dark:hover:bg-gray-950 dark:hover:text-gray-300';
                                }
                            };

                            return (
                                <Button
                                    key={status}
                                    variant={isSelected ? "default" : "outline"}
                                    size="sm"
                                    onClick={() => {
                                        if (isSelected) {
                                            setSelectedStatuses(prev => prev.filter(s => s !== status));
                                        } else {
                                            setSelectedStatuses(prev => [...prev, status]);
                                        }
                                    }}
                                    className={`text-xs h-6 px-3 py-1 rounded-full ${getStatusColors(status, isSelected)}`}
                                    title={`${status} (${statusCount} tests)`}
                                >
                                    {status}
                                </Button>
                            );
                        })}
                    </div>
                </div>

                <div className="flex items-center gap-4">
                    <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                            <Button variant="outline" size="sm">
                                <Columns className="h-4 w-4" />
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

            {/* SFI Pillar Toggle Buttons */}
            <div className="mb-4">
                <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                        <span className="text-sm font-medium">Filter by SFI Pillar:</span>
                        {selectedSfiPillars.length > 0 && (
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => setSelectedSfiPillars([])}
                                className="h-6 px-2 text-xs text-muted-foreground hover:text-foreground"
                            >
                                Clear All ({selectedSfiPillars.length})
                            </Button>
                        )}
                    </div>
                    <div className="flex items-center gap-4">
                        {/* Clear all filters button */}
                        {(selectedSfiPillars.length > 0 || selectedRisks.length > 0 || selectedStatuses.length > 0) && (
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => {
                                    setSelectedSfiPillars([]);
                                    setSelectedRisks([]);
                                    setSelectedStatuses([]);
                                }}
                                className="h-6 px-2 text-xs text-muted-foreground hover:text-foreground"
                            >
                                Clear All Filters
                            </Button>
                        )}
                        <div className="text-xs text-muted-foreground">
                            Showing {filteredData.length} of {pillarFilteredData.length} tests
                        </div>
                    </div>
                </div>
                <div className="flex flex-wrap gap-2">
                    {uniqueSfiPillars.map((pillar) => {
                        const isSelected = selectedSfiPillars.includes(pillar);
                        const pillarCount = data.filter(item => item.TestSfiPillar === pillar).length;
                        const PillarIcon = getSfiPillarIcon(pillar);
                        return (
                            <Button
                                key={pillar}
                                variant={isSelected ? "default" : "outline"}
                                size="sm"
                                onClick={() => {
                                    if (isSelected) {
                                        setSelectedSfiPillars(prev => prev.filter(p => p !== pillar));
                                    } else {
                                        setSelectedSfiPillars(prev => [...prev, pillar]);
                                    }
                                }}
                                className={`text-xs max-w-96 h-auto py-1 px-4 rounded-full ${isSelected ? 'bg-blue-600 hover:bg-blue-700 text-white' : 'hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300 dark:hover:bg-blue-950 dark:hover:text-blue-300'}`}
                                title={`${pillar} (${pillarCount} tests)`} // Show full text and count on hover
                            >
                                <PillarIcon className="mr-2 h-3 w-3 flex-shrink-0" />
                                <span className="whitespace-normal text-left leading-tight">
                                    {pillar}
                                </span>
                            </Button>
                        );
                    })}
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
                <SheetContent side="right" className="md:min-w-[700px] lg:min-w-[900px] overflow-y-auto" allowMaximize>
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
                                        <Settings className="h-4 w-4 text-foreground" />
                                        <span className="font-semibold">Implementation Effort:</span>
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
