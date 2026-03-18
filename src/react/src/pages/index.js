import { useState, useEffect, useCallback } from "react";
import Link from "@docusaurus/Link";
import useBaseUrl from "@docusaurus/useBaseUrl";
import Layout from "@theme/Layout";
import Translate, { translate } from "@docusaurus/Translate";
import useEmblaCarousel from "embla-carousel-react";
import Autoplay from "embla-carousel-autoplay";
import Fade from "embla-carousel-fade";
import { IoChevronBackSharp, IoChevronForwardSharp } from "react-icons/io5";
import styles from "./index.module.css";

/* ─── Hero Carousel data ─────────────────────────────────── */
const SLIDES = [
  {
    img: "/img/zt-framework.png",
    alt: "Zero Trust Framework — Identity, Endpoints, Data, Apps, Infrastructure, Network, AI Resources",
    caption: "Zero Trust Framework",
    href: "https://aka.ms/zerotrust",
  },
  {
    img: "/img/zt-workshop-screenshot.png",
    alt: "Zero Trust Workshop tool — plan across all seven pillars",
    caption: "Zero Trust Workshop",
    href: "https://zerotrust.microsoft.com/",
  },
  {
    img: "/img/zt-assessment-screenshot.png",
    alt: "Zero Trust Assessment dashboard — tenant overview and scores",
    caption: "Zero Trust Assessment",
    href: "https://learn.microsoft.com/security/zero-trust/assessment/get-started",
  },
];

/* ─── Carousel component ─────────────────────────────────── */
function HeroCarousel() {
  const [selectedIndex, setSelectedIndex] = useState(0);

  const [emblaRef, emblaApi] = useEmblaCarousel({ loop: true }, [
    Fade(),
    Autoplay({ delay: 5000, stopOnInteraction: false, stopOnMouseEnter: true }),
  ]);

  // resolve baseUrl for each slide image
  const resolvedSlides = SLIDES.map((s) => ({
    ...s,
    imgSrc: useBaseUrl(s.img),
  }));

  const onSelect = useCallback(() => {
    if (!emblaApi) return;
    setSelectedIndex(emblaApi.selectedScrollSnap());
  }, [emblaApi]);

  useEffect(() => {
    if (!emblaApi) return;
    emblaApi.on("select", onSelect);
    onSelect();
    return () => emblaApi.off("select", onSelect);
  }, [emblaApi, onSelect]);

  const scrollPrev = useCallback(
    () => emblaApi && emblaApi.scrollPrev(),
    [emblaApi]
  );
  const scrollNext = useCallback(
    () => emblaApi && emblaApi.scrollNext(),
    [emblaApi]
  );
  const goTo = useCallback(
    (idx) => emblaApi && emblaApi.scrollTo(idx),
    [emblaApi]
  );

  return (
    <div className={styles.carousel}>
      <div className={styles.carouselViewport} ref={emblaRef}>
        <div className={styles.carouselTrack}>
          {resolvedSlides.map((slide, i) => (
            <div className={styles.carouselSlide} key={i}>
              <button
                type="button"
                className={styles.carouselSlideLink}
                onClick={() =>
                  document
                    .getElementById("products")
                    ?.scrollIntoView({ behavior: "smooth" })
                }
              >
                <img src={slide.imgSrc} alt={slide.alt} />
              </button>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.carouselControls}>
        <button
          className={styles.carouselArrow}
          onClick={scrollPrev}
          aria-label="Previous slide"
        >
          <IoChevronBackSharp />
        </button>

        <div className={styles.carouselDots}>
          {SLIDES.map((_, i) => (
            <button
              key={i}
              className={`${styles.carouselDot} ${
                i === selectedIndex ? styles.carouselDotActive : ""
              }`}
              onClick={() => goTo(i)}
              aria-label={`Go to slide ${i + 1}`}
            />
          ))}
        </div>

        <button
          className={styles.carouselArrow}
          onClick={scrollNext}
          aria-label="Next slide"
        >
          <IoChevronForwardSharp />
        </button>
      </div>
    </div>
  );
}

/* ─── Section 1: Hero ────────────────────────────────────── */
function HeroSection() {
  return (
    <header className={styles.hero}>
      <div className={styles.heroInner}>
        <div className={styles.heroTagline}>
          <span className={styles.newBadge}>
            <Translate id="badge.new">NEW</Translate>
          </span>
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
            <Translate id="hero.cta.workshop">Launch Workshop</Translate> →
          </Link>
          <Link
            className={styles.ctaSecondary}
            href="https://learn.microsoft.com/security/zero-trust/assessment/get-started"
          >
            <Translate id="hero.cta.assessment">Run Assessment</Translate> →
          </Link>
        </div>

        <HeroCarousel />
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
          <Translate id="ai.pill">What&apos;s New</Translate>
        </div>

        <h2 className={styles.aiSpotlightTitle}>
          <Translate id="ai.title">
            Introducing the AI Pillar in Zero Trust
          </Translate>
        </h2>

        <p className={styles.aiSpotlightDesc}>
          <Translate id="ai.description">
            As organizations adopt AI agents and MCP servers, the Zero Trust
            framework now includes a dedicated AI Resources pillar with AI
            controls — ensuring your AI workloads are governed with the same
            rigor as every other part of your environment.
          </Translate>
        </p>

        <div className={styles.pillarRow}>
          <span className={styles.pillarItem}>
            <Translate id="pillar.identity">Identity</Translate>
          </span>
          <span className={styles.pillarItem}>
            <Translate id="pillar.devices">Devices</Translate>
          </span>
          <span
            className={`${styles.pillarItem} ${styles.pillarNew}`}
            title={translate({
              id: "pillar.data.tooltip",
              message: "New automated assessment checks",
            })}
          >
            <Translate id="pillar.data">Data</Translate>
            <span className={styles.pillarNewTag}>
              <Translate id="badge.updated">UPDATED</Translate>
            </span>
          </span>
          <span
            className={`${styles.pillarItem} ${styles.pillarNew}`}
            title={translate({
              id: "pillar.network.tooltip",
              message: "New automated assessment checks",
            })}
          >
            <Translate id="pillar.network">Network</Translate>
            <span className={styles.pillarNewTag}>
              <Translate id="badge.updated">UPDATED</Translate>
            </span>
          </span>
          <span className={styles.pillarItem}>
            <Translate id="pillar.infrastructure">Infrastructure</Translate>
          </span>
          <span className={styles.pillarItem}>
            <Translate id="pillar.secops">SecOps</Translate>
          </span>
          <span
            className={`${styles.pillarItem} ${styles.pillarHighlighted}`}
            title={translate({
              id: "pillar.ai.tooltip",
              message: "AI pillar in Workshop",
            })}
          >
            <Translate id="pillar.ai">AI</Translate>
            <span className={styles.pillarNewTag}>
              <Translate id="badge.new">NEW</Translate>
            </span>
          </span>
        </div>

        <p className={styles.pillarSubtitle}>
          <Translate id="ai.pillarSubtitle">
            Now featuring auto-generated summaries and expanded data & network
            posture checks.
          </Translate>
        </p>
      </div>
    </section>
  );
}

/* ─── Section 3: Two Product Cards ───────────────────────── */
function ProductShowcase() {
  const workshopImg = useBaseUrl("/img/zt-workshop-screenshot.png");
  const assessmentImg = useBaseUrl("/img/zt-assessment-screenshot.png");
  return (
    <section id="products" className={styles.products}>
      <div className={styles.productsInner}>
        <div className={styles.productsHeader}>
          <h2 className={styles.productsTitle}>
            <Translate id="products.title">Two Tools, One Mission</Translate>
          </h2>
          <p className={styles.productsSubtitle}>
            <Translate id="products.subtitle">
              Whether you&apos;re planning your Zero Trust roadmap or measuring
              your current posture, we have you covered.
            </Translate>
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
              <div className={styles.productLabel}>
                <Translate id="products.workshop.label">
                  Interactive Planning Tool
                </Translate>
              </div>
              <h3 className={styles.productName}>
                <Translate id="products.workshop.name">
                  Zero Trust Workshop
                </Translate>
              </h3>
              <p className={styles.productDesc}>
                <Translate id="products.workshop.description">
                  A new web application to plan your Zero Trust deployment
                  across all seven pillars — Identity, Devices, Data, Network,
                  Infrastructure, Security Operations, and AI. Prioritize tasks
                  in a First-Then structure and generate automated summaries and
                  implementation plans.
                </Translate>
              </p>
              <div className={styles.productTags}>
                <span className={styles.productTag}>
                  <Translate id="products.workshop.tag.pillars">
                    7 Pillars
                  </Translate>
                </span>
                <span
                  className={`${styles.productTag} ${styles.productTagNew}`}
                >
                  <Translate id="products.workshop.tag.ai">AI Pillar</Translate>
                </span>
                <span
                  className={`${styles.productTag} ${styles.productTagNew}`}
                >
                  <Translate id="products.workshop.tag.summaries">
                    Auto Summaries
                  </Translate>
                </span>
                <span className={styles.productTag}>
                  <Translate id="products.workshop.tag.plans">
                    Implementation Plans
                  </Translate>
                </span>
              </div>
              <Link
                className={styles.productCta}
                href="https://zerotrust.microsoft.com/"
              >
                <Translate id="products.workshop.cta">
                  Launch Workshop
                </Translate>{" "}
                →
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
              <div className={styles.productLabel}>
                <Translate id="products.assessment.label">
                  Automated Tenant Analysis
                </Translate>
              </div>
              <h3 className={styles.productName}>
                <Translate id="products.assessment.name">
                  Zero Trust Assessment
                </Translate>
              </h3>
              <p className={styles.productDesc}>
                <Translate id="products.assessment.description">
                  Connect to your Microsoft Entra tenant and get an automated
                  assessment of your Zero Trust posture. Analyze configurations
                  across Identity, Devices, Data, and Network pillars with
                  actionable insights and visual dashboards.
                </Translate>
              </p>
              <div className={styles.productTags}>
                <span className={styles.productTag}>
                  <Translate id="products.assessment.tag.identity">
                    Identity
                  </Translate>
                </span>
                <span className={styles.productTag}>
                  <Translate id="products.assessment.tag.devices">
                    Devices
                  </Translate>
                </span>
                <span
                  className={`${styles.productTag} ${styles.productTagNew}`}
                >
                  <Translate id="products.assessment.tag.data">Data</Translate>
                </span>
                <span
                  className={`${styles.productTag} ${styles.productTagNew}`}
                >
                  <Translate id="products.assessment.tag.network">
                    Network
                  </Translate>
                </span>
                <span className={styles.productTag}>
                  <Translate id="products.assessment.tag.checks">
                    Automated Checks
                  </Translate>
                </span>
              </div>
              <Link
                className={styles.productCta}
                href="https://learn.microsoft.com/security/zero-trust/assessment/get-started"
              >
                <Translate id="products.assessment.cta">
                  Run Assessment
                </Translate>{" "}
                →
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
        <h2 className={styles.howItWorksTitle}>
          <Translate id="howItWorks.title">How It Works</Translate>
        </h2>
        <p className={styles.howItWorksSubtitle}>
          <Translate id="howItWorks.subtitle">
            Three steps to improve your organization&apos;s security posture.
          </Translate>
        </p>

        <div className={styles.stepsGrid}>
          <div className={styles.step}>
            <div className={styles.stepNumber}>1</div>
            <h3 className={styles.stepTitle}>
              <Translate id="howItWorks.step1.title">Learn</Translate>
            </h3>
            <p className={styles.stepDesc}>
              <Translate id="howItWorks.step1.description">
                Understand Zero Trust principles — Verify Explicitly, Least
                Privilege Access, and Assume Compromise — and how they apply to
                your environment.
              </Translate>
            </p>
            <Link className={styles.stepLink} href="https://aka.ms/zerotrust">
              <Translate id="howItWorks.step1.link">
                Explore Microsoft Zero Trust
              </Translate>{" "}
              →
            </Link>
          </div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>2</div>
            <h3 className={styles.stepTitle}>
              <Translate id="howItWorks.step2.title">Plan</Translate>
            </h3>
            <p className={styles.stepDesc}>
              <Translate id="howItWorks.step2.description">
                Use the Workshop to build a concrete Zero Trust roadmap across
                all pillars. Prioritize tasks and generate implementation plans
                tailored to your organization.
              </Translate>
            </p>
            <Link
              className={styles.stepLink}
              href="https://zerotrust.microsoft.com/"
            >
              <Translate id="howItWorks.step2.link">Open Workshop</Translate> →
            </Link>
          </div>

          <div className={styles.step}>
            <div className={styles.stepNumber}>3</div>
            <h3 className={styles.stepTitle}>
              <Translate id="howItWorks.step3.title">Assess</Translate>
            </h3>
            <p className={styles.stepDesc}>
              <Translate id="howItWorks.step3.description">
                Run the Assessment against your Microsoft Entra tenant to
                measure your current posture, identify gaps, and track progress
                over time.
              </Translate>
            </p>
            <Link
              className={styles.stepLink}
              href="https://learn.microsoft.com/security/zero-trust/assessment/get-started"
            >
              <Translate id="howItWorks.step3.link">Run Assessment</Translate> →
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
          <h2>
            <Translate id="getStarted.title">Ready to Get Started?</Translate>
          </h2>
          <p>
            <Translate id="getStarted.description">
              Follow our step-by-step plan to deliver a Zero Trust strategy
              session. Whether you&apos;re a Microsoft partner or running an
              internal workshop, the guide walks you through preparation,
              delivery, and follow-up.
            </Translate>
          </p>
          <Link className={styles.getStartedCta} href="guide">
            <Translate id="getStarted.cta">View Step-by-Step Plan</Translate> →
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
      title={translate({
        id: "home.layout.title",
        message: "Microsoft Zero Trust Workshop & Assessment",
      })}
      description={translate({
        id: "home.layout.description",
        message:
          "Plan your Zero Trust deployment with the Workshop tool and measure your posture with the automated Assessment — now featuring a new AI pillar.",
      })}
    >
      <HeroSection />
      <AiSpotlight />
      <ProductShowcase />
      <HowItWorks />
      <GetStarted />
    </Layout>
  );
}
