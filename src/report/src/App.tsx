import { RouterProvider } from "react-router-dom";
import { ThemeProvider } from "./contexts/ThemeContext";
import { router } from "./Router";

export default function App() {

    return (
        <ThemeProvider defaultTheme="system">
            <RouterProvider router={router} />
        </ThemeProvider>
    )
}
