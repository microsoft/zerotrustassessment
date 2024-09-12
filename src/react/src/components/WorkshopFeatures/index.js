import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from '@docusaurus/Link';

const FeatureList = [
  {
    title: 'What is a Zero Trust Workshop?',
    Svg: require('@site/static/img/workshop-buildroadmap.png').default,
    description: (
      <>
        The Zero Trust Workshop is a guided journey by a Microsoft SME or Partner to help you understand the adoption journey, learn best practices, and develop an action plan to secure your future.
      </>
    ),
    learnMoreText: '',
    learnMoreUrl: ''
    // learnMoreText: 'Request a Workshop',
    // learnMoreUrl: 'https://aka.ms/ztassess/request'
  },
  {
    title: 'Who Should Attend?',
    Svg: require('@site/static/img/step2.png').default,
    description: (
      <>
        Anyone in your organization that is responsible for your security strategy and implementation. Each Zero Trust pillar is a separate workshop, so your SMEs for each pillar should attend the appropriate workshop.
      </>
    ),
    learnMoreText: '',
    learnMoreUrl: ''
  },
  {
    title: 'What Should I Expect?',
    Svg: require('@site/static/img/step3.png').default,
    description: (
      <>
        An interactive experience with Microsoft SMEs or partners, with a focus on your current security implementation with an eye focused on best practices and guidance to help you on your Zero Trust journey.
      </>
    ),
    learnMoreText: '',
    learnMoreUrl: ''
  },
];

function Feature({ Svg, title, description, learnMoreText, learnMoreUrl }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img src={Svg} className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
        <Link to={learnMoreUrl}>{learnMoreText}</Link>
      </div>
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
