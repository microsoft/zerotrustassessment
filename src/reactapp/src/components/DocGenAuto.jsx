import * as React from "react";
import { useState, useEffect } from 'react';
import {
    makeStyles,
    tokens,
} from "@fluentui/react-components";

import { Providers, ProviderState } from "@microsoft/mgt";
import { Login } from '@microsoft/mgt-react';
import { DocGenButton } from '../components/DocGenButton';
import { Alert } from "@fluentui/react-components/unstable";
import { ComboboxProps, shorthands, typographyStyles } from "@fluentui/react-components";

const useStyles = makeStyles({
    base: {
        display: "flex",
        flexDirection: "column",
        "& > label": {
            display: "block",
            marginBottom: tokens.spacingVerticalMNudge,
        },
    },
    textarea: {
        height: "200px",
    },
    wrapper: {
        marginTop: tokens.spacingVerticalM,
        columnGap: "15px",
        display: "flex",
    },
    settingsForm: {
        // Stack the label above the field with a gap
        display: "grid",
        gridTemplateRows: "repeat(1fr)",
        justifyItems: "start",
        ...shorthands.gap("2px"),
        //maxWidth: "400px",
      },
      description: {
        ...typographyStyles.caption1,
      },
    
});

function useIsSignedIn(): [boolean] {
    const [isSignedIn, setIsSignedIn] = useState(false);

    useEffect(() => {
        const updateState = () => {
            const provider = Providers.globalProvider;
            setIsSignedIn(provider && provider.state === ProviderState.SignedIn);
        };

        Providers.onProviderUpdated(updateState);
        updateState();

        return () => {
            Providers.removeProviderUpdatedListener(updateState);
        }
    }, []);

    return [isSignedIn];
}

export const DocGenAuto = (props: Partial<ComboboxProps>) => {
    const styles = useStyles();
    const [isSignedIn] = useIsSignedIn();

    return (
        <>
            <div className={styles.base}>                

                {isSignedIn &&
                    <>
                        <DocGenButton/>
                    </>
                }

                {!isSignedIn &&
                    <div>
                        <Alert intent="info" >
                            <p>Please sign in to run the assessment.</p>
                            <p>
                                <Login />
                            </p>
                        </Alert>
                    </div>
                }
            </div>
        </>
    );
};



