import React from 'react';
import { makeStyles, Title1} from '@fluentui/react-components';
import { DocGenAuto } from '../components/DocGenAuto';
import { OptionsRegular, } from "@fluentui/react-icons";
import { Accordion, AccordionHeader, AccordionItem, AccordionPanel} from "@fluentui/react-components";

const useStyles = makeStyles({

});

function Home() {
    const styles = useStyles();

    return (
        <div className={styles.container}>
            <Title1 as="h1" block>Zero Trust Assessment</Title1>
            <p>This app scans your Microsoft cloud services to perform an automated assessment of your tenant's zero trust posture.</p>

            <div className={styles.base}>                
                <Accordion collapsible={true}>
                    <AccordionItem value="1">
                        <AccordionHeader icon={<OptionsRegular />}>
                            More information
                        </AccordionHeader>
                        <AccordionPanel>
                            <div className={styles.settingsForm}>
                                <p>A user with the Global Reader role is required to run this assessment.</p>
                                <p>Please note this app is not an official Microsoft product or service.</p>
                            </div>
                        </AccordionPanel>
                    </AccordionItem>
                </Accordion>
            </div>

            <DocGenAuto />
        </div>
    );
}

export default Home;