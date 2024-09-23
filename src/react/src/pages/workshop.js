import clsx from "clsx";
import { useState } from "react";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import WorkshopFeatures from "@site/src/components/WorkshopFeatures";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

import {
    FluentProvider,
    teamsLightTheme,
    teamsDarkTheme,
} from "@fluentui/react-components";


export default function Workshop() {
    const { siteConfig } = useDocusaurusContext();
    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
        >

            <header className="hero-banner">
                <div className="hero-content">
                    <div className="hero-image-left">
                        <img src={require('@site/static/img/workshop-hero.jpg').default} alt="Zero Trust Workshops" />
                    </div>
                    <div className="hero-text">
                        <Heading as="h1" className="hero__title">
                            What is the Microsoft Zero Trust Workshop and Why Use It?
                        </Heading>
                        <p>
                            The Microsoft Zero Trust Workshop simplifies the complexity of today's Security landscape by embracing Zero Trust concepts and architecture into a tailored, actionable roadmap. This roadmap provides precise, step-by-step guidance for implementing a secure Zero Trust posture, along with measurable milestones to track progress.
                        </p>
                    </div>
                </div>
            </header>

            {/* <header className={clsx("hero hero--primary", styles.heroBanner)}>
                <div className="container">
                    <Heading as="h1" className="hero__title">
                        Zero Trust Workshops
                    </Heading>
                    <p className="hero__subtitle">Create Your Roadmap to Zero Trust</p>
                    <p>Lorem ipsum odor amet, consectetuer adipiscing elit. Euismod vestibulum adipiscing sociosqu; proin lobortis molestie cras interdum at. Posuere aptent at hendrerit gravida, convallis euismod ullamcorper. Habitasse ultricies sem eleifend facilisis duis curae placerat. Euismod metus auctor rhoncus potenti pellentesque volutpat nascetur. Mollis class potenti aptent et, potenti rhoncus. Primis eu taciti blandit, at ad lectus. Torquent praesent phasellus malesuada posuere id nostra. Nunc torquent condimentum morbi dui elementum vel arcu aenean. Duis efficitur vestibulum ligula duis ex non felis.</p>

                    <p>Aliquet curabitur eget torquent vestibulum eu pulvinar. Netus rhoncus semper metus sagittis praesent ac sodales tellus id. Eget porttitor lacus hendrerit morbi fames. Vitae purus tristique magna hac; bibendum felis non. Vulputate arcu vivamus; eleifend suscipit nulla fermentum? Anetus tristique fames; hac mollis est egestas. Hac eget dignissim eleifend quam nisl mi. Scelerisque blandit ad a varius nunc faucibus.</p>
                </div>
            </header> */}


            <main>
                <br />
                <h2 className="text--center hero__subtitle">About our Zero Trust Workshops</h2>
                <WorkshopFeatures />
            </main>

            <div className={styles.buttons}>
                <Link
                    className="button button--secondary button--lg"
                    href="https://github.com/microsoft/zerotrustassessment/raw/main/src/documentgenerator/Assets/ZeroTrustTemplate.xlsx">
                    Download strategy workshop workbook ↓
                </Link>
            </div>

        </Layout>
    );
}