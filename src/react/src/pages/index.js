import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

import { msalConfig, loginRequest } from "../authConfig";

import { AuthenticatedTemplate, UnauthenticatedTemplate, useMsal, MsalProvider, } from "@azure/msal-react";
import { PublicClientApplication } from "@azure/msal-browser";

const pca = new PublicClientApplication(msalConfig);

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const { instance, accounts, inProgress } = useMsal();

  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <AuthenticatedTemplate>
            <Link
              className="button button--secondary button--lg"
              to="/docs/intro"
            >
              Start Zero Trust Assessment 🚀
            </Link> 
            <Link
              className="button button--secondary button--sm"
              onClick={() => {
                  instance.logoutRedirect();
              }}
            >
              Sign out →
            </Link>

          </AuthenticatedTemplate>
          <UnauthenticatedTemplate>
            <Link
              className="button button--secondary button--lg"
              onClick={() => {
                  instance.loginRedirect(loginRequest);
              }}
            >
              Sign in to run assessment →
            </Link>
          </UnauthenticatedTemplate>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`Microsoft Zero Trust Assessment`}
      description="Check your Microsoft tenant configuration for zero trust readiness"
    >
      <MsalProvider instance={pca}>
        <HomepageHeader />
      </MsalProvider>
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
