import styles from "./styles.module.css";

const Steps = [
    {
        id: 1,
        title: "Step 1: Prepare for the Zero Trust workshop",
        description: (
            <>
                <ul>
                    <li><b>Bring the right people together.</b> Identify stakeholders and deployment partners for the pillars you plan to cover.</li>
                    <li><b>Review the <a href="docs/workshop-guidance/delivery-guide" title="Workshop Delivery Guide">delivery guide</a>.</b> Understand the workshop format and preparation requirements.</li>
                    <li><b>Align your stakeholders.</b> Use the <a href="https://github.com/microsoft/zerotrustassessment/raw/main/src/documentgenerator/Assets/ZTWorkshopPitchDeck.pptx" title="Zero Trust Workshop Pitch Deck">pitch deck</a> to introduce the workshop and its goals.</li>
                    <li><b>Establish your baseline.</b> Run the <a href="https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started" title="Learn about the Zero Trust Assessment">Zero Trust Assessment</a> to understand your current configuration and identify gaps.</li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/guide-step1.png").default,
        imageAltText: "Microsoft Zero Trust Assessment overview",
        videoUrl: "https://www.youtube.com/embed/bB2Heu7CCFg",
    },
    {
        id: 2,
        title: "Step 2: Run the Zero Trust strategy workshop",
        description: (
            <>
                <ul>
                    <li>
                        <b>Open the <a href="https://zerotrust.microsoft.com" title="Zero Trust Workshop Tool">workshop tool</a>.</b>
                    </li>
                    <li>
                        <b>Choose your focus.</b> Cover all eight pillars in the proposed order or choose those that align with your organization's priorities:
                        <ul>
                            <li>
                                <a href="docs/videos/IdentityPillar" title="Identity Pillar Info">
                                    Identity
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/DevicesPillar" title="Devices Pillar Info">
                                    Devices
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/DataPillar" title="Data Pillar Info">
                                    Data
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/NetworkPillar" title="Network Pillar Info">
                                    Network
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/InfrastructurePillar" title="Infrastructure Pillar Info">
                                    Infrastructure
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/SecurityOperationsPillar" title="Security Operations Pillar Info">
                                    Security Operations
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/AIPillar" title="AI Pillar Info">
                                    Artificial Intelligence
                                </a>
                            </li>
                            <li>
                                <a href="docs/videos/DevSecOpsPillar" title="DevSecOps Pillar Info">
                                    DevSecOps (New)
                                </a>
                            </li>
                        </ul>
                    </li>
                    <li>
                        <b>Work through each selected pillar.</b> Discuss your current approach and capture responses with the relevant stakeholders.
                    </li>
                    <li>
                        <b>Save your progress.</b> Export your results as a JSON file regularly to save your progress.
                    </li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/newUI2.png").default,
        imageAltText: "Zero Trust Workshop DevSecOps roadmap with tasks organized into First, Then, and Next.",
        videoUrl: "",
    },
    {
        id: 3,
        title: "Step 3: Build an action plan",
        description: (
            <>
                <ul>
                    <li>
                        <b>Download your workshop report.</b> Use the workshop tool to generate a summary report, then share it with relevant stakeholders.
                    </li>
                    <li>
                        <b>Review your findings.</b> Use the workshop report and assessment results to identify gaps.
                    </li>
                    <li>
                        <b>Prioritize improvements.</b> Agree on priority actions, owners, and target dates.
                    </li>
                    <li>
                        <b>Track delivery.</b> Add agreed actions to Azure DevOps, Jira, or your preferred project management tool.
                    </li>
                    <li>
                        <b>Measure progress.</b> Reassess every six months to compare results against your baseline.
                    </li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/report.png").default,
        imageAltText: "Zero Trust Workshop progress report showing remaining tasks by pillar and implementation timeframe.",
        videoUrl: "",
    },
];

export default function GuideSteps() {
    return (
        <div className={styles.contentRows}>
            {Steps.map((step, index) => {
                const isEven = index % 2 === 0; // steps are 1-indexed
                return (
                    <section
                        key={step.id}
                        className={`${styles.rowSection} ${isEven ? styles.evenRow : styles.oddRow}`}
                    >
                        <div
                            className={`${styles.rowContent} ${isEven ? styles.imageFirst : styles.textFirst}`}
                        >
                            {/* Conditionally render Image and Text based on row number */}
                            {isEven ? (
                                <>
                                    {step.videoUrl != "" ? (
                                        <div className={styles.videoContainer}>
                                            <iframe
                                                src={step.videoUrl}
                                                frameBorder="0"
                                                allow="autoplay; encrypted-media"
                                                allowFullScreen
                                                title={step.imageAltText}
                                                height={315}
                                                width={560}
                                            />
                                        </div>
                                    ) : (
                                        <div className={styles.imageContainer}>
                                            <img src={step.imageUrl} alt={step.imageAltText} title={step.imageAltText} />
                                        </div>
                                    )}
                                    <div className={styles.textContainer}>
                                        <h2>{step.title}</h2>
                                        <div className={styles.textLeft}>{step.description}</div>
                                    </div>
                                </>
                            ) : (
                                <>
                                    <div className={styles.textContainer}>
                                        <h2>{step.title}</h2>
                                        <div className={styles.textLeft}>{step.description}</div>
                                    </div>
                                    {step.videoUrl != "" ? (
                                        <div className={styles.videoContainer}>
                                            <iframe
                                                src={step.videoUrl}
                                                frameBorder="0"
                                                allow="autoplay; encrypted-media"
                                                allowFullScreen
                                                title={step.imageAltText}
                                                height={315}
                                                width={560}
                                            />
                                        </div>
                                    ) : (
                                        <div className={styles.imageContainer}>
                                            <img src={step.imageUrl} alt={step.imageAltText} title={step.imageAltText} />
                                        </div>
                                    )}
                                </>
                            )}
                        </div>
                    </section>
                );
            })}
            <section className={styles.feedbackSection} aria-labelledby="workshop-feedback-title">
                <div className={styles.feedbackPanel}>
                    <h2 id="workshop-feedback-title">Help improve the workshop</h2>
                    <ul className={styles.feedbackCards}>
                        <li>
                            <a
                                className={styles.feedbackCard}
                                href="https://aka.ms/ztworkshop/feedback"
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                <span className={styles.feedbackCardTitle}>Share feedback</span>
                                <span className={styles.feedbackCardDescription}>Tell us about your workshop experience.</span>
                            </a>
                        </li>
                        <li>
                            <a
                                className={styles.feedbackCard}
                                href="https://forms.office.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbR7t6ckxTCw9OiSbwsJxSnMlUMDEzTUtLQ0dXSUMyTjJPVVI5M1JYNUNRNC4u"
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                <span className={styles.feedbackCardTitle}>Report partner deliveries</span>
                                <span className={styles.feedbackCardDescription}>For Microsoft partners delivering workshops.</span>
                            </a>
                        </li>
                        <li>
                            <a
                                className={styles.feedbackCard}
                                href="https://github.com/microsoft/zerotrustassessment"
                                target="_blank"
                                rel="noopener noreferrer"
                            >
                                <span className={styles.feedbackCardTitle}>Report an issue</span>
                                <span className={styles.feedbackCardDescription}>Report a bug or suggest an improvement.</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </section>
        </div>
    );
}
