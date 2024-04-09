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
  FluentProvider,
  teamsLightTheme,
  teamsDarkTheme,
} from "@fluentui/react-components";

import {
  Dialog,
  DialogTrigger,
  DialogSurface,
  DialogTitle,
  DialogBody,
  DialogActions,
  DialogContent,
  Button,
} from "@fluentui/react-components";

import { Spinner } from "@fluentui/react-components";

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

  const doDialogCancel = (state) => {
    console.log(state);
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
            {!showProgress && (
              <Link
                className="button button--secondary button--lg"
                onClick={runAssessment}
              >
                Start Zero Trust Assessment 🚀
              </Link>
            )}
            {showProgress && (
              <Link className="button button--secondary button--lg disabled">
                Start Zero Trust Assessment 🚀
              </Link>
            )}

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
            <Dialog defaultOpen={true} modalType="alert">
              <DialogSurface>
                <DialogBody>
                  <DialogContent>
                    <Spinner label="Running assessment. Please wait, this can take a few minutes..." />
                  </DialogContent>
                </DialogBody>
              </DialogSurface>
            </Dialog>
          )}
        </AuthenticatedTemplate>
        <UnauthenticatedTemplate>
          <div className={styles.buttons}>
            {/* Check url for preview flag and show link */}
            <BrowserOnly>
              {() => {
                {
                  window.location.href.includes("preview") && (
                    <Link
                      className="button button--secondary button--lg"
                      onClick={() => {
                        instance.loginRedirect(loginRequest);
                      }}
                    >
                      Sign in to run assessment →
                    </Link>
                  );
                }
              }}
            </BrowserOnly>
            <Link
              className="button button--secondary button--lg"
              href="https://github.com/microsoft/zerotrustassessment/raw/main/src/documentgenerator/Assets/ZeroTrustTemplate.xlsx"
            >
              Download strategy workshop workbook ↓
            </Link>
          </div>
        </UnauthenticatedTemplate>
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
        <FluentProvider theme={teamsDarkTheme}>
          <HomepageHeader />
        </FluentProvider>
      </MsalProvider>
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
