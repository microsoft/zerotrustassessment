import Link from "@docusaurus/Link";
import useBaseUrl from "@docusaurus/useBaseUrl";
import Layout from "@theme/Layout";
import Translate from "@docusaurus/Translate";
import styles from "./index.module.css";
import { VscRobot } from "react-icons/vsc";
import { HiOutlineDocumentText } from "react-icons/hi";
import { GoShieldCheck } from "react-icons/go";

/* ─── Section 1: Hero ────────────────────────────────────── */
function HeroSection() {
  const frameworkImg = useBaseUrl("/img/zt-framework.png");
  return (
    <header className={styles.hero}>
      <div className={styles.heroInner}>
        <div className={styles.heroTagline}>
          <span className={styles.newBadge}>NEW</span>
          <Translate id="hero.tagline">
            AI pillar now available in the Zero Trust framework
          </Translate>
        </div>

        <h1 className={styles.heroTitle}>
          <Translate id="hero.title">
            Accelerate Your Zero Trust Journey
          </Translate>
        </h1>

        <p className={styles.heroSubtitle}>
          <Translate id="hero.subtitle">
            A comprehensive framework from Microsoft to help organizations adopt
            a Zero Trust strategy and deploy security solutions end-to-end —
            now with a new AI pillar for securing agents and AI resources.
          </Translate>
        </p>

        <div className={styles.heroCtas}>
          <Link
            className={styles.ctaPrimary}
            href="https://zerotrust.microsoft.com/"
          >
            Launch Workshop →
          </Link>
          <Link
            className={styles.ctaSecondary}
            href="https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started"
          >
            Run Assessment →
          </Link>
        </div>

        <div className={styles.heroImage}>
          <img
            src={frameworkImg}
            alt="Zero Trust Framework"
          />
        </div>
      </div>
    </header>
  );
}

/* ─── Section 2: AI Pillar Spotlight ─────────────────────── */
function AiSpotlight() {
  return (
    <section className={styles.aiSpotlight}>
      <div className={styles.aiSpotlightInner}>
        <div className={styles.aiPill}>
          What&apos;s New
        </div>

        <h2 className={styles.aiSpotlightTitle}>
          Introducing the AI Pillar in Zero Trust
        </h2>

        <p className={styles.aiSpotlightDesc}>
          As organizations adopt AI agents and MCP servers, the Zero Trust
          framework now includes a dedicated AI Resources pillar with AI
          controls — ensuring your AI workloads are governed with the same
          rigor as every other part of your environment.
        </p>

        <div className={styles.aiHighlights}>
          <div className={styles.aiHighlightItem}>
            <div className={styles.aiHighlightIcon}><VscRobot /></div>
            <div className={styles.aiHighlightTitle}>AI Pillar in Workshop</div>
            <p className={styles.aiHighlightDesc}>
              Plan your Zero Trust posture for AI agents and MCP servers with
              dedicated guidance and implementation tasks.
            </p>
          </div>

          <div className={styles.aiHighlightItem}>
            <div className={styles.aiHighlightIcon}><HiOutlineDocumentText /></div>
            <div className={styles.aiHighlightTitle}>Automated Summaries</div>
            <p className={styles.aiHighlightDesc}>
              Generate automated summaries and implementation plans directly
              from the Workshop tool — no manual effort required.
            </p>
          </div>

          <div className={styles.aiHighlightItem}>
            <div className={styles.aiHighlightIcon}><GoShieldCheck /></div>
            <div className={styles.aiHighlightTitle}>Expanded Assessment</div>
            <p className={styles.aiHighlightDesc}>
              New Data and Network pillar checks alongside expanded Identity
              and Devices coverage for deeper tenant analysis.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ─── Section 3: Two Product Cards ───────────────────────── */
function ProductShowcase() {
  const workshopImg = useBaseUrl("/img/zt-workshop-screenshot.png");
  const assessmentImg = useBaseUrl("/img/zt-assessment-screenshot.png");
  return (
    <section className={styles.products}>
      <div className={styles.productsInner}>
        <div className={styles.productsHeader}>
          <h2 className={styles.productsTitle}>Two Tools, One Mission</h2>
          <p className={styles.productsSubtitle}>
            Whether you&apos;re planning your Zero Trust roadmap or measuring your
            current posture, we have you covered.
          </p>
        </div>

        <div className={styles.productGrid}>
          {/* Workshop Card */}
          <div className={styles.productCard}>
            <div className={styles.productImageWrap}>
              <img
                src={workshopImg}
                alt="Zero Trust Workshop tool"
                loading="lazy"
              />
            </div>
            <div className={styles.productBody}>
              <div className={styles.productLabel}>Interactive Planning Tool</div>
              <h3 className={styles.productName}>Zero Trust Workshop</h3>
              <p className={styles.productDesc}>
                A Single-Page Application to plan your Zero Trust deployment
                across all seven pillars — Identity, Devices, Data, Network,
                Infrastructure, Security Operations, and AI. Prioritize tasks
                in a First-Then structure and generate automated summaries and
                implementation plans.
              </p>
              <div className={styles.productTags}>
                <span className={styles.productTag}>7 Pillars</span>
                <span className={`${styles.productTag} ${styles.productTagNew}`}>
                  AI Pillar
                </span>
                <span className={`${styles.productTag} ${styles.productTagNew}`}>
                  Auto Summaries
                </span>
                <span className={styles.productTag}>Implementation Plans</span>
              </div>
              <Link
                className={styles.productCta}
                href="https://zerotrust.microsoft.com/"
              >
                Launch Workshop →
              </Link>
            </div>
          </div>

          {/* Assessment Card */}
          <div className={styles.productCard}>
            <div className={styles.productImageWrap}>
              <img
                src={assessmentImg}
                alt="Zero Trust Assessment dashboard"
                loading="lazy"
              />
            </div>
            <div className={styles.productBody}>
              <div className={styles.productLabel}>Automated Tenant Analysis</div>
              <h3 className={styles.productName}>Zero Trust Assessment</h3>
              <p className={styles.productDesc}>
                Connect to your Microsoft Entra tenant and get an automated
                assessment of your Zero Trust posture. Analyze configurations
                across Identity, Devices, Data, and Network pillars with
                actionable insights and visual dashboards.
              </p>
              <div className={styles.productTags}>
                <span className={styles.productTag}>Identity</span>
                <span className={styles.productTag}>Devices</span>
                <span className={`${styles.productTag} ${styles.productTagNew}`}>
                  Data
                </span>
                <span className={`${styles.productTag} ${styles.productTagNew}`}>
                  Network
                </span>
                <span className={styles.productTag}>Automated Checks</span>
              </div>
              <Link
                className={styles.productCta}
                href="https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started"
              >
                Run Assessment →
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ─── Section 4: How It Works ────────────────────────────── */
function HowItWorks() {
  return (
    <section className={styles.howItWorks}>
      <div className={styles.howItWorksInner}>
        <h2 className={styles.howItWorksTitle}>How It Works</h2>
        <p className={styles.howItWorksSubtitle}>
          Three steps to improve your organization&apos;s security posture.
        </p>

        <div className={styles.stepsGrid}>
          <div className={styles.step}>
            <div className={styles.stepNumber}>1</div>
            <h3 className={styles.stepTitle}>Learn</h3>
            <p className={styles.stepDesc}>
              Understand Zero Trust principles — Verify Explicitly, Least
              Privilege Access, and Assume Compromise — and how they apply to
              your environment.
            </p>
            <Link className={styles.stepLink} href="https://aka.ms/zerotrust">
              Explore Microsoft Zero Trust →
            </Link>
          </div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>2</div>
            <h3 className={styles.stepTitle}>Plan</h3>
            <p className={styles.stepDesc}>
              Use the Workshop to build a concrete Zero Trust roadmap across
              all pillars. Prioritize tasks and generate implementation plans
              tailored to your organization.
            </p>
            <Link
              className={styles.stepLink}
              href="https://zerotrust.microsoft.com/"
            >
              Open Workshop →
            </Link>
          </div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>3</div>
            <h3 className={styles.stepTitle}>Assess</h3>
            <p className={styles.stepDesc}>
              Run the Assessment against your Microsoft Entra tenant to
              measure your current posture, identify gaps, and track progress
              over time.
            </p>
            <Link
              className={styles.stepLink}
              href="https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started"
            >
              Run Assessment →
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

/* ─── Section 5: Video + Getting Started ─────────────────── */
function GetStarted() {
  return (
    <section className={styles.getStarted}>
      <div className={styles.getStartedInner}>
        <div className={styles.videoWrap}>
          <iframe
            src="https://www.youtube.com/embed/0-IYLWMHxGg?si=JyV0MuwIUBDKoFpN"
            title="Zero Trust Workshop — Introduction"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            referrerPolicy="strict-origin-when-cross-origin"
            allowFullScreen
          />
        </div>
        <div className={styles.getStartedText}>
          <h2>Ready to Get Started?</h2>
          <p>
            Follow our step-by-step plan to deliver a Zero Trust strategy
            session. Whether you&apos;re a Microsoft partner or running an internal
            workshop, the guide walks you through preparation, delivery, and
            follow-up.
          </p>
          <Link className={styles.getStartedCta} href="guide">
            View Step-by-Step Plan →
          </Link>
        </div>
      </div>
    </section>
  );
}

/* ─── Page ───────────────────────────────────────────────── */
export default function Home() {
  return (
    <Layout
      title="Microsoft Zero Trust Workshop & Assessment"
      description="Plan your Zero Trust deployment with the Workshop tool and measure your posture with the automated Assessment — now featuring a new AI pillar."
    >
      <HeroSection />
      <AiSpotlight />
      <ProductShowcase />
      <HowItWorks />
      <GetStarted />
    </Layout>
  );
}
