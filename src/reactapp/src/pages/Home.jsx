import React from 'react';
import { makeStyles, Title1} from '@fluentui/react-components';
import { DocGenAuto } from '../components/DocGenAuto';

const useStyles = makeStyles({

});

function Home() {
    const styles = useStyles();

    return (
        <div className={styles.container}>
            <Title1 as="h1" block>Zero Trust Assessment</Title1>
            <p>This app scans your Microsoft cloud services to perform an automated assessment of your zero trust posture.</p>
            <p>This Zero Trust Assessment app is a project created by the Microsoft Security CxE team and is not an official Microsoft product or service.</p>

            <DocGenAuto />
        </div>
    );
}

export default Home;