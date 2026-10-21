import Layout from "@theme/Layout";
import GuideSteps from "@site/src/components/GuideSteps";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

export default function Guide() {
    return (
        <Layout
            title="Zero Trust Workshop Plan"
            description="Learn how to prepare for, deliver, and follow up on a Zero Trust workshop for your customers or your organization"
        >
            <div className={styles.guidePageShell}>
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
                            <div className={styles.guideHeroVideo}>
                                <iframe
                                    src="https://www.youtube.com/embed/IM1tPevGTJg?si=dgo43IyqmcFdWlmo"
                                    title="Microsoft Zero Trust Workshop and Assessment Overview"
                                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                    referrerPolicy="strict-origin-when-cross-origin"
                                    allowFullScreen
                                />
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
