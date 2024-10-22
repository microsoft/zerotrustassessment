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
    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
        >

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