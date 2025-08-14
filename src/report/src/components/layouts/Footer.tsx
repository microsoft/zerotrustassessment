// import { ztAppConfig } from "@/config/app";
// import { ModeToggle } from "../mode-toggle";

export function Footer() {
    return (
        <footer className="flex flex-col items-center justify-between gap-4 min-h-[3rem] md:h-20 py-2 md:flex-row">
            <p className="text-center text-sm leading-loose text-muted-foreground md:text-left">Generated using <a href="https://www.powershellgallery.com/packages/ZeroTrustAssessmentV2" target="_blank" rel="noreferrer noopener" className="font-medium underline underline-offset-4">ZeroTrustAssessment</a>. Share feedback and report issues → <a href="https://aka.ms/ztassess/feedback" target="_blank" rel="noreferrer" className="font-medium underline underline-offset-4">Feedback</a>.</p>
            <div className="hidden md:block">
                {/* Show LightTheme by default and disable toggle. Charts don't render will in dark mode. */}
                {/* <ModeToggle /> */}
            </div>
        </footer>
    )
}
