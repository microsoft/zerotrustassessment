import { makeStyles, tokens, Button } from "@fluentui/react-components";
import * as React from "react";
import { CalendarMonthRegular, } from "@fluentui/react-icons";
import { Providers, ProviderState } from "@microsoft/mgt";
import { useState } from 'react';
import { Spinner } from "@fluentui/react-components";
import { Alert } from "@fluentui/react-components/unstable";
import { apiConfig } from "../authConfig"

const useStyles = makeStyles({
    wrapper: {
        marginTop: tokens.spacingVerticalM,
        columnGap: "15px",
        display: "flex",
    },
});

export const DocGenButton = ({ isManual, caPolicyJson, maskOptions, groupSlidesByState}) => {
    const styles = useStyles();
    const [showProgress, setShowProgress] = useState(false);
    const [showErrorAlert, setShowErrorAlert] = useState(false);

    const dismissAlert = async (e) => {
        setShowErrorAlert(false);
    }

    const handleClick = async () => {
        setShowProgress(true);
        setShowErrorAlert(false);

        if (maskOptions == null) { maskOptions = [""] }
        if (groupSlidesByState == null) { groupSlidesByState = true; }

        if (maskOptions == null) { maskOptions = [""] }
        let policy = {
            isMaskUser: maskOptions.includes("User"),
        };

        let token = "";
        if (Providers.globalProvider.state === ProviderState.SignedIn) {
            token = await Providers.globalProvider.getAccessToken({ scopes: ['User.Read'] })
        }

        const options = {
            method: 'POST',
            headers: {
                'Content-type': 'application/json',
                'X-DocumentGeneration-Token': token
            },
            body: JSON.stringify(policy)
        };


        fetch(apiConfig.apiEndPoint + '/document', options)
            .then((response) => {
                if (response.ok) {
                    return response.blob();
                }
                return null;
            })
            .then((blob) => {
                if (blob === null) {
                    setShowErrorAlert(true);
                }
                else {
                    // 2. Create blob link to download
                    const url = window.URL.createObjectURL(new Blob([blob]));
                    const link = document.createElement('a');
                    link.href = url;
                    link.setAttribute('download', `Zero Trust Assessment.xlsx`);
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
        <>
            <div className={styles.wrapper}>
                <Button appearance="primary" icon={<CalendarMonthRegular />}
                    onClick={handleClick}
                >
                    Run Zero Trust assessment
                </Button> {showProgress && <Spinner label="Running assessment. Please wait, this can take a few minutes..." size="small" />}
            </div>
            {showErrorAlert &&
                <div style={{ display: "flex", flexDirection: "column", gap: "10px", marginTop: "20px" }}>
                    <Alert intent="error" action="Dismiss" onClick={dismissAlert}>
                        Sorry something went wrong. Please try again.
                    </Alert>
                </div>
            }
        </>
    );
};