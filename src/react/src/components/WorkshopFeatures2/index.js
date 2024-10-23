import React from 'react';
import styles from './styles.module.css'; // Updated CSS module
import { FaRoad, FaChartLine, FaPuzzlePiece, FaMicrosoft, FaUserTie, FaCogs, FaProjectDiagram, FaShieldAlt, FaBook } from 'react-icons/fa'; // Using react-icons for icons
import Link from '@docusaurus/Link';


const benefits = [
    {
        icon: <FaRoad />,
        title: 'Create',
        description: 'a detailed, customized zero trust roadmap that is relevant to your organization',
    },
    {
        icon: <FaChartLine />,
        title: 'Measure',
        description: 'progress and impact of your ZT journey',
    },
    {
        icon: <FaPuzzlePiece />,
        title: 'Highlight',
        description: 'cross-product integrations that are both valuable and may not always be considered by siloed teams',
    },
    {
        icon: <FaMicrosoft />,
        title: 'Utilize',
        description: 'fully the Microsoft Security features/products you own',
    },
    {
        icon: <FaShieldAlt />,
        title: 'Improve',
        description: 'your end-to-end security posture',
    },
];

const attendees = [
    {
        icon: <FaUserTie />,
        title: 'Zero Trust Lead',
        description: 'Leads the zero trust strategy and implementation across the organization',
    },
    {
        icon: <FaCogs />,
        title: 'Enterprise Architects',
        description: 'Drive the design and architecture of end-to-end solutions, ensuring security integration',
    },
    {
        icon: <FaProjectDiagram />,
        title: 'Pillar Architects, Leads, and Experts',
        description: 'Ensure specific business or technical pillars are aligned with the zero trust strategy',
    },
    {
        icon: <FaShieldAlt />,
        title: 'Cybersecurity Team Members',
        description: 'Responsible for implementing and managing security measures',
    },
];


export default function WorkshopFeatures2() {
    return (
        <div>
            {/* Buttons */}
            {/* <p className='text--center'>
                <span><button className="text--center button button--primary button--lg" onClick={() => {
                    const elem = document.getElementById('benefits-sect');
                    elem?.scrollIntoView({ behavior: 'smooth' });
                }}>Key Benefits</button></span>
                <span><button className="text--center button button--primary button--lg buttonPad" onClick={() => {
                    const elem = document.getElementById('attendees-sect');
                    elem?.scrollIntoView({ behavior: 'smooth' });
                }}>Who Should Attend</button></span>
                <span><button className="text--center button button--primary button--lg buttonPad" onClick={() => {
                    const elem = document.getElementById('guide-sect');
                    elem?.scrollIntoView({ behavior: 'smooth' });
                }}>Running Your Own Workshop</button></span>
            </p> */}
            {/* Benefits */}
            < section id="benefits-sect" >
                <div className={styles.container}>
                    <h1 className={styles.title}>Key benefits of the Zero Trust workshop</h1>
                    <div className={styles.benefitsGrid}>
                        {benefits.map((benefit, index) => (
                            <div key={index} className={styles.benefitCard}>
                                <div className={styles.icon}>{benefit.icon}</div>
                                <p className={styles.benefitTitle}>
                                    <strong>{benefit.title}</strong> {benefit.description}
                                </p>
                            </div>
                        ))}
                    </div>
                </div>
            </section >
            <section id="attendees-sect">
                <div className={styles.container}>
                    <h1 className={styles.title}>Who should attend the Zero Trust workshop</h1>
                    <div className={styles.attendeesGrid}>
                        {attendees.map((attendee, index) => (
                            <div key={index} className={styles.attendeeCard}>
                                <div className={styles.icon}>{attendee.icon}</div>
                                <p className={styles.attendeeTitle}>
                                    <strong>{attendee.title}</strong> {attendee.description}
                                </p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
            <section id="guide-sect">
                <div className={styles.container}>
                    <h1 className={styles.title}>Run your own workshop</h1>
                    <div className={styles.attendeeCard}>
                        <p className={styles.attendeeTitle}>
                            We provide training materials for a self-service workshop, but you can also collaborate with your Microsoft Account team or a partner if you use Microsoft Security products.
                        </p>
                        <div className="text--center featureBtn action-button">
                            <Link className="text--center button button--primary button--lg" href="guide">Access our step-by-step guide</Link>
                        </div>
                    </div>
                </div>
            </section>
        </div >
    )
}