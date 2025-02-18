import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import Link from "@docusaurus/Link";
import Translate, { translate } from '@docusaurus/Translate';

const FeatureList = [


  {
    title: 'How do I run the workshop?',
    Svg: require('@site/static/img/workshop-run.png').default,
    description: (
      <>
        For step-by-step guidance on delivering the strategy session and running the assessment, refer to our <a href="guide" title="Zero Trust Workshop Plan">step-by-step plan</a>.
        If you are unsure how to get started, watch our Zero Trust Workshop Introductory video.
        <br /><br />
        <iframe width="100%" height="315" src="
          https://www.youtube.com/embed/0-IYLWMHxGg?si=JyV0MuwIUBDKoFpN
          " title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen>
        </iframe>
      </>
    ),
    buttonText: '',
    buttonDest: '',
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

          {/* <!-- What is Zero Trust? --> */}
          <div className="sub-section">
            <img src={require('@site/static/img/what-is-zero-trust.png').default} className={styles.featureSvg} role="img" />
            <div className="content">
              <Heading as="h2"><Translate id='homepage.whatIsZt.title'>What is Zero Trust?</Translate></Heading>
              <p className="text--left">
                <Translate id='homepage.whatIsZt.sentence1'>
                  Navigating the complexities of modern security is challenging, but a Zero Trust strategy can provide clarity and direction. By adopting Zero Trust, your organization can enhance its security posture, reducing risk and complexity while improving compliance and governance.
                </Translate>
                <br /><br />
                <Translate id='homepage.whatIsZt.sentence2'>
                  This workshop helps you apply the Zero Trust principles across the Microsoft Security landscape:
                </Translate>
                <ul>
                  <li><Translate id='homepage.whatIsZt.verify'>Verify Explicitly</Translate></li>
                  <li><Translate id='homepage.whatIsZt.leastPriv'>Use Least Privilege Access</Translate></li>
                  <li><Translate id='homepage.whatIsZt.assumeComp'>Assume Compromise</Translate></li>
                </ul>
                <br />
              </p>
            </div>
            <div className="text--center featureBtn action-button">
              <Link className="text--center button button--primary button--lg" href='https://aka.ms/zerotrust'><Translate id='learnMore'>Learn more</Translate></Link>
            </div>
          </div>

          {/* <!-- Why run the workshop --> */}
          <div className="sub-section">
            <img src={require('@site/static/img/what-does-workshop-cover.png').default} className={styles.featureSvg} role="img" />
            <div className="content">
              <Heading as="h2"><Translate id='homepage.whyRunWorkshop.title'>Why run the workshop</Translate></Heading>
              <p className="text--left">
                <Translate id='homepage.whyRunWorkshop.sentence1'>
                  The Zero Trust Workshop is a guided framework from Microsoft to help you translate Zero Trust Strategy into a deployment reality.
                </Translate>
                <br /><br />
                <Translate id='homepage.whyRunWorkshop.sentence2'>
                  Using our learnings from thousands of customer deployments, we help you evaluate your current environment and provide concrete steps in a first-then-next structure to help you arrive at an improved end-to-end security posture.
                </Translate>
              </p>
            </div>
            <div className="text--center featureBtn action-button">
              <Link className="text--center button button--primary button--lg" href='workshop'><Translate id='homepage.whyRunWorkshop.learnAboutWorkshop'>Learn about our workshop</Translate></Link>
            </div>
          </div>

          {/* <!-- How do I run the workshop? --> */}
          <div className="sub-section">
            <img src={require('@site/static/img/workshop-run.png').default} className={styles.featureSvg} role="img" />
            <div className="content">
              <Heading as="h2"><Translate id='homepage.howRunWorkshop.title'>How do I run the workshop?</Translate></Heading>
              <p className="text--left">
                <Translate id='homepage.howRunWorkshop.sentence1'>
                  The Zero Trust Workshop is a guided framework from Microsoft to help you translate Zero Trust Strategy into a deployment reality.
                </Translate>
                <br /><br />
                <Translate id='homepage.howRunWorkshop.sentence2'>
                  Using our learnings from thousands of customer deployments, we help you evaluate your current environment and provide concrete steps in a first-then-next structure to help you arrive at an improved end-to-end security posture.
                </Translate>
                <br /><br />
                <iframe width="100%" height="315" src="https://www.youtube.com/embed/0-IYLWMHxGg?si=JyV0MuwIUBDKoFpN" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen>
                </iframe>
              </p>
            </div>
          </div>

          {/* {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))} */}
        </div>
      </div>
    </section>
  );
}
