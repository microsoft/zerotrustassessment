import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Step 1: Run assessment',
    Svg: require('@site/static/img/step1.svg').default,
    description: (
      <>
        Run this assessment to check tenant config and 
        download the roadmap templates that will be used during the workshops.
        <br/>
        <code><a href="docs/app-permissions">App Permissions</a></code>
      </>
    ),
  },
  {
    title: 'Step 2: Strategy workshops',
    Svg: require('@site/static/img/step2.svg').default,
    description: (
      <>
        Schedule workshops with your Microsoft consultants for each of the Identity, Devices, Data and Network pillars.
      </>
    ),
  },
  {
    title: 'Step 3: Implement roadmap',
    Svg: require('@site/static/img/step3.svg').default,
    description: (
      <>
        Review the results of the workshops and implement the zero trust roadmap across your entire digital estate for end to end security.
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
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
