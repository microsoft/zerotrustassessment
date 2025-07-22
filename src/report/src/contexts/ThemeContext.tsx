import { createContext, useEffect, useState } from "react"

type ThemeProviderProps = {
    children: React.ReactNode
    defaultTheme?: string
    storageKey?: string
}

export type ThemeProviderState = {
    theme: string
    setTheme: (theme: string) => void
}

const initialState = {
    theme: "system",
    setTheme: () => null,
}

export const ThemeProviderContext = createContext<ThemeProviderState>(initialState)

export function ThemeProvider({
    children,
    defaultTheme = "system",
    storageKey = "shadcn-ui-theme",
    ...props
}: ThemeProviderProps) {
    const [theme, setTheme] = useState(
        () => localStorage.getItem(storageKey) ?? defaultTheme
    )

    useEffect(() => {
        const root = window.document.documentElement

        root.classList.remove("light", "dark")

        if (theme === "system") {
            const systemTheme = window.matchMedia("(prefers-color-scheme: dark)")
                .matches
                ? "dark"
                : "light"

            root.classList.add(systemTheme)
            return
        }

        root.classList.add(theme)
    }, [theme])

    // Listen for system theme changes when using system theme
    useEffect(() => {
        const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
        
        const handleChange = () => {
            if (theme === "system") {
                const root = window.document.documentElement
                root.classList.remove("light", "dark")
                
                const systemTheme = mediaQuery.matches ? "dark" : "light"
                root.classList.add(systemTheme)
            }
        }

        mediaQuery.addEventListener("change", handleChange)
        return () => mediaQuery.removeEventListener("change", handleChange)
    }, [theme])

    return (
        <ThemeProviderContext.Provider {...props} value={{
            theme,
            setTheme: (theme: string) => {
                localStorage.setItem(storageKey, theme)
                setTheme(theme)
            },
        }}>
            {children}
        </ThemeProviderContext.Provider>
    )
}
