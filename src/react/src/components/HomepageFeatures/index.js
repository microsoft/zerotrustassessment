import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from "@docusaurus/Link";

const FeatureList = [
  {
    title: 'What is Zero Trust?',
    Svg: require('@site/static/img/what-is-zero-trust.png').default,
    description: (
      <>
        Navigating the complexities of modern security is challenging, but a Zero Trust strategy can provide clarity and direction. By adopting Zero Trust, your organization can enhance its security posture, reducing risk and complexity while improving compliance and governance.
        <br /><br />
        This approach leverages AI to provide robust protection and adaptability. In today's dynamic environment, a new security model is essential—one that embraces the hybrid workplace and safeguards people, devices, apps, and data, regardless of location.
      </>
    ),
    buttonText: 'Learn more',
    buttonDest: 'https://aka.ms/zerotrust',
  },
  {
    title: 'What does the workshop cover?',
    Svg: require('@site/static/img/what-does-workshop-cover.png').default,
    description: (
      <>
        The Zero Trust Workshop is a guided framework from Microsoft to help you translate Zero Trust Strategy into a deployment reality.
        <br /><br />
        Using our learnings from thousands of customer deployments, we help you evaluate your current environment and provide concrete steps in a first-then-next structure to help you arrive at an improved end-to-end security posture.
      </>
    ),
    buttonText: 'Learn about our workshop',
    buttonDest: 'workshop',
  },
  {
    title: 'How do I run the workshop?',
    Svg: require('@site/static/img/workshop-run.png').default,
    description: (
      <>
        For step-by-step guidance on delivering the strategy session and running the assessment, refer to our guide.

      </>
    ),
    buttonText: 'Read the guide',
    buttonDest: 'guide',
  },
];

function Feature({ Svg, title, description, buttonText, buttonDest }) {
  let theButton;
  if (buttonDest !== '') {
    theButton = <div className="text--center featureBtn action-button">
      <Link className="text--center button button--primary button--lg" href={buttonDest}>{buttonText}</Link>
    </div>;
  }

  return (
    <div className="sub-section">
      <img src={Svg} className={styles.featureSvg} role="img" title={title} />
      <div className="content">
        <Heading as="h2">{title}</Heading>
        <p className="text--left">{description}</p>
      </div>

      {theButton}
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="section">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
