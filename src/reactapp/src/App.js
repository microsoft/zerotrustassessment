import React, { useEffect } from "react";
import { PageLayout } from "./components/PageLayout";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import About from "./pages/About";
import NoPage from "./pages/NoPage";
import { envConfig } from "./authConfig"

function App() {

    // for static title, pass an empty array as the second argument
    // for dynamic title, put the dynamic values inside the array
    // see: https://reactjs.org/docs/hooks-effect.html#tip-optimizing-performance-by-skipping-effects
    useEffect(() => {
        document.title = 'Zero Trust Assessment M' + envConfig.envName;
    }, []);

    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<PageLayout />}>
                    <Route index element={<Home />} />
                    <Route path="*" element={<NoPage />} />
                    <Route path="/about" element={<About />} />
                </Route>
            </Routes>
        </BrowserRouter>
    );
}

export default App;