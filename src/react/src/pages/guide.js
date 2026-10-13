import Layout from "@theme/Layout";
import GuideSteps from "@site/src/components/GuideSteps";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

export default function Guide() {
    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
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
