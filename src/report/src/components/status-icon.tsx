import { Test } from "@/config/report-data"
import { statuses } from "./test-table/data-icons"
import { Badge } from "./ui/badge"

interface StatusIconProps {
    Item: Test
}

export function StatusIcon({ Item }: StatusIconProps) {
    const status = statuses.find(
        (status) => status.value === Item.TestStatus
    )
    if (!status) {
        return null
    }

    return (
        <div className="flex items-center">
            <Badge variant={status.variant as "default" | "destructive" | "secondary" | "outline" | "warning" | null | undefined}>
                <span>{status.label}</span>
            </Badge>
        </div>
    )
}
