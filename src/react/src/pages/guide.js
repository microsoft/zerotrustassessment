import clsx from "clsx";
import { useState } from "react";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import GuideSteps from "@site/src/components/GuideSteps";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

import {
    FluentProvider,
    teamsLightTheme,
    teamsDarkTheme,
} from "@fluentui/react-components";

export default function Guide() {
    const { siteConfig } = useDocusaurusContext();
    const [showAnnouncementBanner, setShowAnnouncementBanner] = useState(true);

    const dismissAnnouncementBanner = () => {
        setShowAnnouncementBanner(false);
    };

    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
        >
            {showAnnouncementBanner && (
                <section className={styles.homeAnnouncementBanner} aria-label="Product announcement">
                    <button
                        type="button"
                        className={styles.dismissBannerButton}
                        aria-label="Dismiss announcement"
                        onClick={dismissAnnouncementBanner}
                    >
                        x
                    </button>
                    <p className={styles.homeAnnouncementText}>
                        <strong>Check out our latest updates!</strong> Experience our new{" "}
                        <a href="https://zerotrust.microsoft.com/"><strong>ZT Workshop Tool</strong></a>: a
                        Single-Page Application with a new AI pillar and the ability to generate
                        automated summaries and implementation plans. We&apos;ve also made
                        updates to the{" "}
                        <a href="https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started">
                            <strong>ZT Assessment</strong>
                        </a>, adding support for the Data and Network pillars and expanding the
                        number of Identity and Devices checks available.
                    </p>
                </section>
            )}

            <header className="hero-banner">
                <div className="hero-content">
                    <div className="hero-text">
                        <Heading as="h1" className="hero__title">
                            Zero Trust Workshop Plan
                        </Heading>
                        <p>
                            Learn how to run the Microsoft Zero Trust workshop, including step-by-step instructions and best practices.
                        </p>
                    </div>
                    <div className="hero-image">
                        <img src={require('@site/static/img/workshop-cover.png').default} alt="Zero Trust Workshop Guide" />
                    </div>
                </div>
            </header>

            <main>
                <GuideSteps />
            </main>

        </Layout>
    );
}