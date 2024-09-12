import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Step 1: Run assessment',

    description: (
      <>
        Run this assessment to check tenant config and
        download the roadmap templates that will be used during the workshops.
        <br />
        <code>
          Install-Module ZeroTrustAssessment
          Invoke-ZTAssessment
        </code>
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

function Feature({ Svg, title, description }) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        {Svg && <Svg className={styles.featureSvg} role="img" />}
        {!Svg && <img src="img/step1.png" />}

      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function WhatIsZeroTrust() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="text--center padding-horiz--md">
          <h3>What is Zero Trust?</h3>
        </div>

        <div className="text-image-pair">
          <p>
            Lorem ipsum odor amet, consectetuer adipiscing elit. Mattis praesent torquent fermentum interdum himenaeos nostra mollis. Condimentum in sagittis aptent semper consequat potenti facilisis. Per bibendum amet consequat nascetur; taciti sit aliquet. Penatibus ornare in sapien non porta. Feugiat magna nascetur venenatis fusce; ligula augue. Senectus posuere consectetur ac at imperdiet. Himenaeos etiam ad fringilla mauris sit dui placerat nostra eros.
            <br />
            Arcu pharetra nunc integer; efficitur urna tempor leo varius. Hac pellentesque urna primis non aliquam blandit etiam. Lacus quam faucibus viverra orci porta, venenatis commodo. Penatibus bibendum pharetra cubilia diam; sollicitudin et hac ligula fames. Platea sagittis iaculis ac fermentum tristique lectus imperdiet elementum. Fusce vitae mauris senectus imperdiet nullam fermentum tempor varius. Ac scelerisque est auctor metus rhoncus at montes urna. Eros magna mauris vitae metus condimentum. Congue ligula dictum natoque conubia fermentum posuere class tellus feugiat.
          </p>
          <img src="img/zero-trust-architecture.svg" alt="Zero Trust Architecture" />
        </div>
      </div>
    </section>
  );
}
