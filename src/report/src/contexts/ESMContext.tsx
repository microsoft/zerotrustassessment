import { createContext, useContext, useEffect, useState } from "react"

type ESMProviderProps = {
    children: React.ReactNode
    storageKey?: string
}

type ESMContextState = {
    isESM: boolean
    setIsESM: (value: boolean) => void
}

const initialState: ESMContextState = {
    isESM: false,
    setIsESM: () => null,
}

const ESMContext = createContext<ESMContextState>(initialState)

export function ESMProvider({
    children,
    storageKey = "zt-esm-mode",
}: ESMProviderProps) {
    const [isESM, setIsESMState] = useState(() => {
        const stored = localStorage.getItem(storageKey)
        return stored === "true"
    })

    useEffect(() => {
        const root = window.document.documentElement
        if (isESM) {
            root.classList.add("esm")
        } else {
            root.classList.remove("esm")
        }
    }, [isESM])

    const setIsESM = (value: boolean) => {
        localStorage.setItem(storageKey, String(value))
        setIsESMState(value)
    }

    return (
        <ESMContext.Provider value={{ isESM, setIsESM }}>
            {children}
        </ESMContext.Provider>
    )
}

export function useESM() {
    const context = useContext(ESMContext)
    if (context === undefined) {
        throw new Error("useESM must be used within an ESMProvider")
    }
    return context
}
