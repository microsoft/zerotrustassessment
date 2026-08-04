import { Outlet } from "react-router-dom";
import { Header } from "./Header";
import { Footer } from "./Footer";

export function Applayout() {
    return (
        <div className="min-h-screen">
            <Header />
            <div className="flex-grow flex flex-col">
                <div className="w-full max-w-[1800px] mx-auto px-12 md:px-[72px] flex-grow flex flex-col">
                    <Outlet />
                </div>
            </div>
            <div className="w-full max-w-[1800px] mx-auto px-12 md:px-[72px]">
                <Footer />
            </div>
        </div>
    )
}
