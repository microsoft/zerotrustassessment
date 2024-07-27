import { Icons } from "@/components/icons"

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

export const mainMenu: NavItemWithChildren[] = [
    {
        title: 'Dashboard',
        to: '',
    },
    {
        title: 'Dropdown',
        items: [
            {
                title: 'Sample',
                to: '/sample',
            },
            {
                title: 'Sample Dua',
                to: '/#',
            },
        ]
    },
    {
        title: 'Empty',
        to: 'empty',
    },
]

export const sideMenu: NavItemWithChildren[] = []
