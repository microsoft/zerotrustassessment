import React from 'react';
import { makeStyles, Title1, Subtitle1 } from '@fluentui/react-components';

const useStyles = makeStyles({
});

function Home() {
    const styles = useStyles();

    return (
        <div className={styles.container}>
            <Title1 as="h1" block>About the Zero Trust Assessment</Title1>
            <p>The Zero Trust assessment is a community project by the Microsoft CxE team, however this is not an official Microsoft product or service. We are publishing it under the terms of the <a href="https://github.com/microsoft/zerotrustassessment/blob/main/LICENSE">MIT license.</a></p>

            <Subtitle1 as="h2" block>Feedback and support</Subtitle1>
            <p>Please share feedback and report issues on <a href="https://github.com/microsoft/zerotrustassessment/issues">GitHub</a>.</p>
            <p>As this is a community project, support is provided on a best efforts basis.</p>

            <Subtitle1 as="h2" block>Credits</Subtitle1>
            <ul>
                <li><a href="https://www.syncfusion.com/">Syncfusion</a> - This project will not be possible without the amazing library provided by Syncfusion.</li>
                <li><a href="https://learn.microsoft.com/en-us/graph/toolkit/overview/">Microsoft Graph Toolkit</a> - The components made it super easy to provide a seamless sign in experience for users. </li>
                <li><a href="https://github.com/mattl-msft/Amazing-Icon-Downloader">Amazing Icon Downloader</a> - An amazing tool to find the icons used in this site and project.</li>
            </ul>
        </div>
    );
}

export default Home;