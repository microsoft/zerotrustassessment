import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from '@docusaurus/Link';

const FeatureList = [
  {
    title: 'Workshop Goals and Outcomes',
    description: (
      <>
        <ul>
          <li>Provide a detailed, customized zero trust roadmap that is relevant to your organization​</li>
          <li>Provide a way to measure progress and impact of your ZT journey​</li>
          <li>Highlight cross-product integrations that are both valuable and may not always be considered by siloed teams.​​</li>
          <li>Help you fully utilize the Microsoft Security features/products you own​​</li>
          <li>Ultimately, Improve your end-to-end security posture​​</li>
        </ul>
      </>
    ),
    learnMoreText: '',
    learnMoreUrl: ''
    // learnMoreText: 'Request a Workshop',
    // learnMoreUrl: 'https://aka.ms/ztassess/request'
  },
  {
    title: 'Who Should Attend?',
    description: (
      <>
        <ul>
          <li>Security Architects</li>
          <li>Identity Architects</li>
          <li>ITDM of the primary pillars (Identity, Devices, Network, Infra and Data)</li>
        </ul>
      </>
    ),
    learnMoreText: '',
    learnMoreUrl: ''
  },
  {
    title: 'Workshop Structure',
    description: (
      <>
        We provide training materials for a self-service workshop, but you can also collaborate with your Microsoft Account team or a partner if you use Microsoft Security products.
      </>
    ),
    learnMoreText: 'Access Our Step-by-Step Guide',
    learnMoreUrl: 'guide'
  },
];

function Feature({ title, description, learnMoreText, learnMoreUrl }) {
  let theButton;
  if (learnMoreUrl !== '') {
    theButton = <div className="text--center featureBtn">
      <Link className="text--center button button--secondary button--lg" href={learnMoreUrl}>{learnMoreText}</Link>
    </div>;
  }

  return (
    <div className={clsx('col col--4')}>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p className="text--justify">{description}</p>
      </div>
      {theButton}
    </div>
  );
}

export default function WorkshopFeatures() {
  return (

    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}




// Run this assessment to check tenant config and
// download the roadmap templates that will be used during the workshops.
// <br />
// <code>
//   Install-Module ZeroTrustAssessment
//   Invoke-ZTAssessment
// </code>
