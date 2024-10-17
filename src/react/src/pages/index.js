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

    <header className="hero-banner">
      <div className="hero-content">
        <div className="hero-text">
          <Heading as="h1" className="hero__title">
            {siteConfig.title}
          </Heading>
          <p>
            A comprehensive technical guide to help customers and partners adopt a Zero Trust strategy and deploy security solutions end to end to secure their organizations.
          </p>
        </div>
        <div className="hero-image">
          <img src={require('@site/static/img/hero-datacenter.png').default} alt="Zero Trust Concept" />
        </div>
      </div>
    </header>

    // <header className={clsx("hero hero--primary", styles.heroBanner)}>
    //   <div className="container">
    //     <Heading as="h1" className="hero__title">
    //       {siteConfig.title}
    //     </Heading>
    //     <p className="hero__subtitle">{siteConfig.tagline}</p>
    //     <UnauthenticatedTemplate>
    //       <h4>
    //         Enhance your expertise and identify growth opportunities by scheduling a Zero Trust Workshop along with running a Zero Trust Assessment on your Microsoft Entra ID Tenant.
    //       </h4>
    //     </UnauthenticatedTemplate>
    //   </div>
    // </header>
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
        <br />
        {/* <h3 className="text--center padding-horiz--md">
          What Does Our Zero Trust Workshop Provide?
        </h3>
        <div className="container">
          <p>
            Lorem ipsum odor amet, consectetuer adipiscing elit. Euismod vestibulum adipiscing sociosqu; proin lobortis molestie cras interdum at. Posuere aptent at hendrerit gravida, convallis euismod ullamcorper. Habitasse ultricies sem eleifend facilisis duis curae placerat. Euismod metus auctor rhoncus potenti pellentesque volutpat nascetur. Mollis class potenti aptent et, potenti rhoncus. Primis eu taciti blandit, at ad lectus. Torquent praesent phasellus malesuada posuere id nostra. Nunc torquent condimentum morbi dui elementum vel arcu aenean. Duis efficitur vestibulum ligula duis ex non felis.
          </p>
        </div> */}

        <HomepageFeatures />
        {/* <WhatIsZeroTrust />

        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            href="https://aka.ms/zerotrust">
            Learn more about Microsoft Zero Trust
          </Link>
        </div> */}

      </main>
    </Layout>
  );
}
