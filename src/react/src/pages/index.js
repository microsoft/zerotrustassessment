import clsx from "clsx";
import { useState } from "react";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";

import Heading from "@theme/Heading";
import styles from "./index.module.css";

import { msalConfig, loginRequest, apiConfig } from "../authConfig";

import {
  AuthenticatedTemplate,
  UnauthenticatedTemplate,
  useMsal,
  MsalProvider,
} from "@azure/msal-react";
import { PublicClientApplication } from "@azure/msal-browser";

const pca = new PublicClientApplication(msalConfig);

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const { instance, accounts, inProgress } = useMsal();
  const [showProgress, setShowProgress] = useState(false);
  const [showErrorAlert, setShowErrorAlert] = useState(false);

  const runAssessment = async () => {
    setShowProgress(true);
    setShowErrorAlert(false);

    let policy = {
      isMaskUser: false,
    };

    if (!instance.getActiveAccount() && instance.getAllAccounts().length > 0) {
      instance.setActiveAccount(instance.getAllAccounts()[0]);
    }

    const response = await instance.acquireTokenSilent({
      ...loginRequest,
    });
    let accessToken = response.accessToken;

    const options = {
      method: "POST",
      headers: {
        "Content-type": "application/json",
        "X-DocumentGeneration-Token": accessToken,
      },
      body: JSON.stringify(policy),
    };

    fetch(apiConfig.apiEndPoint + "/document", options)
      .then((response) => {
        if (response.ok) {
          return response.blob();
        }
        return null;
      })
      .then((blob) => {
        if (blob === null) {
          setShowErrorAlert(true);
        } else {
          // 2. Create blob link to download
          const url = window.URL.createObjectURL(new Blob([blob]));
          const link = document.createElement("a");
          link.href = url;
          link.setAttribute("download", `Zero Trust Assessment.xlsx`);
          // 3. Append to html page
          document.body.appendChild(link);
          // 4. Force download
          link.click();
          // 5. Clean up and remove the link
          link.parentNode.removeChild(link);
        }
        setShowProgress(false);
      })
      .catch((error) => {
        setShowErrorAlert(true);
        setShowProgress(false);
      });
  };

  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>

        <AuthenticatedTemplate>
          <div className={styles.buttons}>
            <Link
              className="button button--secondary button--lg"
              onClick={runAssessment}
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
          </div>
          {showErrorAlert && (
            <div class="alert alert--danger" role="alert">
              Sorry something went wrong. Please try again.
            </div>
          )}
          {showProgress && (
          <div class="alert alert--info" role="alert">
            <strong>Running assessment.</strong> Please wait, this can take a few minutes...
          </div>
          )}

        </AuthenticatedTemplate>
        <UnauthenticatedTemplate>
          <div className={styles.buttons}>
            <Link
              className="button button--secondary button--lg"
              onClick={() => {
                instance.loginRedirect(loginRequest);
              }}
            >
              Sign in to run assessment →
            </Link>
          </div>
        </UnauthenticatedTemplate>
      </div>

      <div
        class="modal fade"
        id="exampleModal"
        tabindex="-1"
        role="dialog"
        aria-labelledby="exampleModalLabel"
        aria-hidden="true"
      ></div>
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
