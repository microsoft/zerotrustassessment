import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from "@docusaurus/Link";

const FeatureList = [
  {
    title: 'Current Baseline',
    Svg: require('@site/static/img/learn-handson.png').default,
    description: (
      <>
        Establish your current zero trust baseline with a Microsoft SME or Partner across the Identity, Devices, and Data pillars.
      </>
    ),
    buttonText: 'Learn About Workshops',
    buttonDest: 'workshop',
  },
  {
    title: 'Run Assessment',
    Svg: require('@site/static/img/learn-assess.png').default,
    description: (
      <>
        Check your Microsoft Entra ID tenant's configuration to determine your zero trust readiness.
      </>
    ),
    buttonText: 'Learn About Assessments',
    buttonDest: 'assessment',
  },
  {
    title: 'Build Your Roadmap',
    Svg: require('@site/static/img/learn-roadmap.png').default,
    description: (
      <>
        Review the results of the workshops and implement the zero trust roadmap across your entire digital estate for end to end security.
      </>
    ),
    buttonText: '',
    buttonDest: '',
  },
];

function Feature({ Svg, title, description, buttonText, buttonDest }) {
  let theButton;
  if (buttonDest !== '') {
    theButton = <div className="text--center featureBtn">
      <Link className="text--center button button--secondary button--lg" href={buttonDest}>{buttonText}</Link>
    </div>;
  }

  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <img src={Svg} className={styles.featureSvg} role="img" />

      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>

      {theButton}
    </div>
  );
}

export default function HomepageFeatures() {
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
