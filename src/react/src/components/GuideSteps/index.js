import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from "@docusaurus/Link";


const Steps = [
    {
        id: 1,
        title: 'Step 1: (Optional) Zero Trust Assessment',
        description: (
            <>
                Begin with the Zero Trust Assessment to ensure your organization is securely positioned before advancing your Zero Trust journey.
                <br />
                This assessment provides essential checks to confirm a strong security baseline, preparing you for advanced features and a more resilient security posture.
                <br />
                Click the video to learn more about the assessment or use this link for in-depth documentation.
            </>
        ),
        imageUrl: require('@site/static/img/guide-step1.png').default
    },
    {
        id: 2,
        title: 'Step 2: Prepare for the Workshop ',
        description: (
            <>
                <ol>
                    <li>Identify which teams to involve.</li>
                    <li>Access the Zero Trust architecture resources here.</li>
                    <li>Schedule with your Microsoft partner or account team.</li>
                    <li>Download the Zero Trust Workshop tool.</li>
                </ol>
            </>
        ),
        imageUrl: require('@site/static/img/guide-step1.png').default
    },
    {
        id: 3,
        title: 'Step 3: Run the Pillar-Specific Workshops',
        description: (
            <>
                <p>Use discussion guides and materials for:</p>
                <ol>
                    <li>Identity pillar</li>
                    <li>Devices pillar</li>
                    <li>Data pillar</li>
                </ol>
            </>
        ),
        imageUrl: require('@site/static/img/guide-step3.png').default
    },
    {
        id: 4,
        title: 'Step 4: Document Results & Create a Plan',
        description: (
            <>
                <p>Use discussion guides and materials for:</p>
                <ol>
                    <li>Upload assessment and workshop results to your project management tool (e.g., ADO, JIRA).</li>
                    <li>Establish a baseline and track your progress with regular assessments every 6 months.</li>
                    <li>Identify areas that need improvement and adjust your security plan accordingly.. ​</li>
                </ol>
            </>
        ),
        imageUrl: require('@site/static/img/guide-step4.png').default
    },
    {
        id: 5,
        title: 'Step 5: Share Your Feedback',
        description: (
            <>
                <p>Use discussion guides and materials for:</p>
                <ol>
                    <li>Have feedback from running the workshop? Share it with us here.</li>
                    <li>Found any bugs or have enhancement suggestions? Contribute to the GitHub repository here. ​</li>
                </ol>
            </>
        ),
        imageUrl: require('@site/static/img/guide-step5.png').default
    },
];

export default function GuideSteps() {
    return (
        <div className="content-rows">
            {Steps.map((step, index) => {
                const isEven = (index) % 2 === 0; // steps are 1-indexed
                return (
                    <section
                        key={step.id}
                        className={`row-section ${isEven ? 'even-row' : 'odd-row'}`}
                    >
                        <div
                            className={`row-content ${isEven ? 'image-first' : 'text-first'
                                }`}
                        >
                            {/* Conditionally render Image and Text based on row number */}
                            {isEven ? (
                                <>
                                    <div className="image-container">
                                        <img src={step.imageUrl} alt={`Row ${step.id}`} />
                                    </div>
                                    <div className="text-container">
                                        <h2>{step.title}</h2>
                                        <p>{step.description}</p>
                                    </div>
                                </>
                            ) : (
                                <>
                                    <div className="text-container">
                                        <h2>{step.title}</h2>
                                        <p>{step.description}</p>
                                    </div>
                                    <div className="image-container">
                                        <img src={step.imageUrl} alt={`Row ${step.id}`} />
                                    </div>
                                </>
                            )}
                        </div>
                    </section>
                );
            })}
        </div>
    );
}
