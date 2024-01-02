import React, { useLayoutEffect, useState } from "react";
import { useHistory } from 'react-router-dom';
import NotFound from "@theme-original/NotFound";

export default function NotFoundWrapper(props) {
  const [hasChecked, setHasChecked] = useState([]);

  const history = useHistory();

  useLayoutEffect(() => {
    const currentUrl = window.location.href;
    if (window.location.pathname.endsWith("/w/")) {
      const qs = window.location.search;
      let target = ""
      if (qs.startsWith("?RMI")) {
        target = "identity";
      } else if (qs.startsWith("?RMD")) {
        target = "devices";
      } else if (qs.startsWith("?RMDS")) {
        target = "devsecops";
      } else if (qs.startsWith("?RMT")) {
        target = "data";
      }
      if(target == ""){
        setHasChecked(true);
      }
      else {
        const newUrl = currentUrl.replace("/w/?", `/docs/workshop-guidance/${target}/`);
        window.history.replaceState({}, "", newUrl);
        const relativePath = new URL(newUrl).pathname;
        history.push(relativePath);
      }
    }
  }, [history]);

  return (
    <>
      {hasChecked && <NotFound {...props} />}
    </>
  );
}
