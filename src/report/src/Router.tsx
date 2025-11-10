import { createHashRouter } from "react-router-dom";

import { Applayout } from "./components/layouts/AppLayout";

import NoMatch from "./pages/NoMatch";
import Dashboard from "./pages/Dashboard";
import Identity from "./pages/Identity";
import Devices from "./pages/Devices";
import Apps from "./pages/Apps";
import Network from "./pages/Network";
import Infrastructure from "./pages/Infrastructure";
import Data from "./pages/Data";

export const router = createHashRouter([
    {
        path: "/",
        element: <Applayout />,
        children: [
            {
                path: "",
                element: <Dashboard />,
            },
            {
                path: "identity",
                element: <Identity />,
            },
            {
                path: "devices",
                element: <Devices />,
            },
            {
                path: "apps",
                element: <Apps />,
            },
            {
                path: "network",
                element: <Network />,
            },
            {
                path: "infrastructure",
                element: <Infrastructure />,
            },
            {
                path: "data",
                element: <Data />,
            },
        ],
    },
    {
        path: "*",
        element: <NoMatch />,
    },
], {
    basename: global.basename
})
