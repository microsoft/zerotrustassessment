import clsx from "clsx";
import { useState } from "react";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import WorkshopFeatures from "@site/src/components/WorkshopFeatures2";

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
                        <img src={require('@site/static/img/workshop-hero.png').default} alt="Zero Trust Workshops" />
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

            <main>
                <br />
                {/* <h2 className="text--center hero__subtitle">About our Zero Trust Workshops</h2> */}
                <WorkshopFeatures />
            </main>

        </Layout>
    );
}