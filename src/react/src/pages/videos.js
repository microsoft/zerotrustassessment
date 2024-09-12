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
        </Layout>
    );
}