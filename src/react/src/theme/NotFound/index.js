import React, { useEffect, useState } from "react";
import { translate } from "@docusaurus/Translate";
import { PageMetadata } from "@docusaurus/theme-common";
import Layout from "@theme/Layout";
import NotFoundContent from "@theme/NotFound/Content";
import BrowserOnly from "@docusaurus/BrowserOnly";

import { useHistory } from "react-router-dom";

export default function Index() {
  const title = translate({
    id: "theme.NotFound.title",
    message: "Page Not Found",
  });

  const [hasChecked, setHasChecked] = useState(false);
  const [hasMounted, setHasMounted] = useState(false);
  console.log("starting");
  const history = useHistory();

  useEffect(() => {
    setHasMounted(true);
    const currentUrl = window.location.href;
    if (window.location.pathname.endsWith("/w/")) {
      const qs = window.location.search;
      let target = "";
      if (qs.startsWith("?RMI_")) {
        target = "identity";
      } else if (qs.startsWith("?RMD_")) {
        target = "devices";
      } else if (qs.startsWith("?RMDS_")) {
        target = "devsecops";
      } else if (qs.startsWith("?RMT_")) {
        target = "data";
      }
      if (target.length === 0) {
        console.log("Setting target");
        setHasChecked(true);
      } else {
        console.log("Redirecting");
        const newUrl = currentUrl.replace(
          "/w/?",
          `/docs/workshop-guidance/${target}/`
        );
        window.history.replaceState({}, "", newUrl);
        const relativePath = new URL(newUrl).pathname;
        history.push(relativePath);
      }
    }
  }, [history]);

  if (!hasMounted) {
    return null;
  }
  
  if (hasChecked) {
    return (
      <>
        <BrowserOnly fallback={<div></div>}>
          <PageMetadata title={title} />
          <Layout>
            <NotFoundContent />
          </Layout>
        </BrowserOnly>
      </>
    );
  }
}
