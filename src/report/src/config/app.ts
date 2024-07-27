interface AppConfig {
    name: string,
    github: {
        title: string,
        url: string
    },
}

export const appConfig: AppConfig = {
    name: "Zero Trust Assessment",
    github: {
        title: "GitHub",
        url: "https://github.com/microsoft/zerotrustassessment",
    }
}
