import { Icons } from "@/components/icons"
import { reportData } from "@/config/report-data"

interface NavItem {
    title: string
    to?: string
    href?: string
    disabled?: boolean
    external?: boolean
    icon?: keyof typeof Icons
    label?: string
}

interface NavItemWithChildren extends NavItem {
    items?: NavItemWithChildren[]
}

const allMenuItems: NavItemWithChildren[] = [
    {
        title: 'Overview',
        to: '',
    },
    {
        title: 'Identity',
        to: 'identity',
    },
    {
        title: 'Devices',
        to: 'devices',
    },
    // {
    //     title: 'Apps',
    //     to: 'apps',
    // },
    {
        title: 'Network',
        to: 'network',
    },
    {
        title: 'Infrastructure',
        to: 'infrastructure',
    },
    {
        title: 'Data',
        to: 'data',
    },
    {
        title: 'SecOps',
        to: 'secops',
    },
    {
        title: 'AI',
        to: 'ai',
    },
]

// Filter menu based on available data (e.g., exclude Network/Data/Infrastructure/SecOps/AI if their totals don't exist)
export const mainMenu: NavItemWithChildren[] = allMenuItems.filter(item => {
    if (item.title === 'Network') {
        // Only show Network tab if NetworkTotal exists in the report data
        return reportData.TestResultSummary?.NetworkTotal !== undefined
    }
    if (item.title === 'Data') {
        // Only show Data tab if DataTotal exists in the report data
        return reportData.TestResultSummary?.DataTotal !== undefined
    }
    if (item.title === 'Infrastructure') {
        return reportData.TestResultSummary?.InfrastructureTotal !== undefined
    }
    if (item.title === 'SecOps') {
        return reportData.TestResultSummary?.SecOpsTotal !== undefined
    }
    if (item.title === 'AI') {
        return reportData.TestResultSummary?.AITotal !== undefined
    }
    return true
})

export const sideMenu: NavItemWithChildren[] = []
