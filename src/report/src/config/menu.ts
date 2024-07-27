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
    {
        title: 'Apps',
        to: 'apps',
    },
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
    // {
    //     title: 'Dropdown',
    //     items: [
    //         {
    //             title: 'Sample',
    //             to: '/sample',
    //         },
    //         {
    //             title: 'Sample Dua',
    //             to: '/#',
    //         },
    //     ]
    // },
]

export const sideMenu: NavItemWithChildren[] = []
