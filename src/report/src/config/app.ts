interface AppConfig {
    name: string,
    github: {
        title: string,
        url: string
    },
}

export const ztAppConfig: AppConfig = {
    name: "Zero Trust Assessment",
    github: {
        title: "GitHub",
        url: "https://github.com/microsoft/zerotrustassessment",
    }
}