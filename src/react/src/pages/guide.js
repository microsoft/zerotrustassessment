import { useState } from "react";
import Layout from "@theme/Layout";
import GuideSteps from "@site/src/components/GuideSteps";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

export default function Guide() {
    const [showAnnouncementBanner, setShowAnnouncementBanner] = useState(true);

    const dismissAnnouncementBanner = () => {
        setShowAnnouncementBanner(false);
    };

    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
        >
            <div className={styles.guidePageShell}>
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

                <header className={`${styles.hero} ${styles.guideHero}`}>
                    <div className={styles.heroInner}>
                        <div className={styles.guideHeroContent}>
                            <div className={styles.guideHeroText}>
                                <Heading as="h1" className={styles.heroTitle}>
                                    Zero Trust Workshop Plan
                                </Heading>
                                <p className={styles.heroSubtitle}>
                                    Learn how to run the Microsoft Zero Trust workshop, including step-by-step instructions and best practices.
                                </p>
                            </div>
                            <div className={styles.guideHeroImage}>
                                <img src={require("@site/static/img/workshop-cover.png").default} alt="Zero Trust Workshop Guide" />
                            </div>
                        </div>
                    </div>
                </header>

                <main>
                    <GuideSteps />
                </main>
            </div>

        </Layout>
    );
}
