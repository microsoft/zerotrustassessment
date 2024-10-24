import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";
import Link from "@docusaurus/Link";

const Steps = [
    {
        id: 1,
        title: "Step 1: Prepare for the Zero Trust workshop",
        description: (
            <>
                <ul>
                    <li>Identity and notify the right stakeholders from your organization and your deployment partners for each zero trust pillar</li>
                    <li>Review the <a href="docs/workshop-guidance/delivery-guide" title="Workshop Delivery Guide">delivery guide</a></li>
                    <li>(Optional) Run the <a href="docs/app-permissions" title="Lear about the Zero Trust Assessment">Zero Trust Assessment</a> to make sure you are starting with a healthy configuration</li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/guide-step1.png").default,
        imageAltText: "Learn about the Zero Trust Assessment video",
        videoUrl: "https://www.youtube.com/embed/oyG3EcFd-_E?start=0:03",
    },
    {
        id: 2,
        title: "Step 2: Run the Zero Trust strategy workshop",
        description: (
            <>
                <ul>
                    <li>
                        Download the <a href="https://github.com/microsoft/zerotrustassessment/raw/main/src/documentgenerator/Assets/ZeroTrustTemplate.xlsx" title="Zero Trust Workshop Tool">workshop tool</a>.
                    </li>
                    <li>
                        Delivery the workshop for each Zero Trust pillar with the right stakeholders. You can run them in the proposed order or choose the right pillar for the area you are focused on:
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
                        </ul>
                    </li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/guide-step4.png").default,
        imageAltText: "Run a strategy workshop",
        videoUrl: "",
    },
    {
        id: 3,
        title: "Step 3: Document results and create a plan",
        description: (
            <>
                <ul>
                    <li>
                        Identify areas that need improvement and adjust your security plan
                        accordingly.
                    </li>
                    <li>
                        Establish a baseline and track your progress with regular
                        assessments every 6 months.
                    </li>
                    <li>
                        Upload assessment and workshop results to your project management
                        tool (e.g., ADO, JIRA).
                    </li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/learn-pillars.png").default,
        imageAltText: "Specific pillar workshop videos",
        videoUrl: "",
    },
    {
        id: 4,
        title: "Share your feedback",
        description: (
            <>
                <ul>
                    <li>
                        Have feedback from running the workshop? Share it with us{" "}
                        <a
                            href="https://aka.ms/ztworkshop/feedback"
                            target="_blank"
                            title="Zero Trust Workshop Feedback"
                        >
                            here
                        </a>
                        .
                    </li>
                    <li>
                        Found any bugs or have enhancement suggestions? Contribute to the
                        GitHub repository{" "}
                        <a
                            href="https://github.com/microsoft/zerotrustassessment"
                            target="_blank"
                            title="Zero Trust Workshop and Assessment Repo"
                        >
                            here
                        </a>
                        .
                    </li>
                </ul>
            </>
        ),
        imageUrl: require("@site/static/img/guide-step5.png").default,
        imageAltText: "Provide feedback on the workshop",
        videoUrl: "",
    },
];

export default function GuideSteps() {
    return (
        <div className="content-rows">
            {Steps.map((step, index) => {
                const isEven = index % 2 === 0; // steps are 1-indexed
                return (
                    <section
                        key={step.id}
                        className={`row-section ${isEven ? "even-row" : "odd-row"}`}
                    >
                        <div
                            className={`row-content ${isEven ? "image-first" : "text-first"}`}
                        >
                            {/* Conditionally render Image and Text based on row number */}
                            {isEven ? (
                                <>
                                    {step.videoUrl != "" ? (
                                        <div className="video-container">
                                            <iframe
                                                src={step.videoUrl}
                                                frameborder="0"
                                                allow="autoplay; encrypted-media"
                                                allowfullscreen
                                                title="video"
                                                height={315}
                                                width={560}
                                            />
                                        </div>
                                    ) : (
                                        <div className="image-container">
                                            <img src={step.imageUrl} title={step.imageAltText} />
                                        </div>
                                    )}
                                    <div className="text-container">
                                        <h2>{step.title}</h2>
                                        <p className="text--left">{step.description}</p>
                                    </div>
                                </>
                            ) : (
                                <>
                                    <div className="text-container">
                                        <h2>{step.title}</h2>
                                        <p className="text--left">{step.description}</p>
                                    </div>
                                    {step.videoUrl != "" ? (
                                        <div className="video-container">
                                            <iframe
                                                src={step.videoUrl}
                                                frameborder="0"
                                                allow="autoplay; encrypted-media"
                                                allowfullscreen
                                                title="video"
                                                height={315}
                                                width={560}
                                            />
                                        </div>
                                    ) : (
                                        <div className="image-container">
                                            <img src={step.imageUrl} title={step.imageAltText} />
                                        </div>
                                    )}
                                </>
                            )}
                        </div>
                    </section>
                );
            })}
        </div>
    );
}
