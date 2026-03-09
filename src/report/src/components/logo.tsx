import { ztAppConfig } from "@/config/app";
import { Icons } from "./icons";

export function Logo() {
    return (
        <>
            <Icons.logo className="h-6 w-6" />
            <span className="font-bold">{ztAppConfig.name}</span>
        </>
    )
}
