import clsx from "clsx";
import { useState } from "react";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

import {
    FluentProvider,
    teamsLightTheme,
    teamsDarkTheme,
} from "@fluentui/react-components";


export default function Testimonials() {
    const { siteConfig } = useDocusaurusContext();
    return (
        <Layout
            title={`Microsoft Zero Trust Assessment`}
            description="Check your Microsoft tenant configuration for zero trust readiness"
        >
            <header className={clsx("hero hero--primary", styles.heroBanner)}>
                <div className="container">
                    <Heading as="h1" className="hero__title">
                        Zero Trust Readiness Testimonials
                    </Heading>
                    <p className="hero__subtitle">Hear what customers have had to say...</p>
                </div>
            </header>

            <img src="img/testimonials.png" className="testimonial-image" alt="Zero Trust Satisfied Customers" />

        </Layout>
    );
}