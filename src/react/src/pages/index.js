import { useState, useEffect, useCallback } from "react";
import Link from "@docusaurus/Link";
import useBaseUrl from "@docusaurus/useBaseUrl";
import Layout from "@theme/Layout";
import Translate from "@docusaurus/Translate";
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
    href: "https://learn.microsoft.com/en-us/security/zero-trust/assessment/get-started",
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

        <div className={styles.pillarRow}>
          <span className={styles.pillarItem}>Identity</span>
          <span className={styles.pillarItem}>Devices</span>
          <span
            className={`${styles.pillarItem} ${styles.pillarNew}`}
            title="New automated assessment checks"
          >
            Data
            <span className={styles.pillarNewTag}>UPDATED</span>
          </span>
          <span
            className={`${styles.pillarItem} ${styles.pillarNew}`}
            title="New automated assessment checks"
          >
            Network
            <span className={styles.pillarNewTag}>UPDATED</span>
          </span>
          <span className={styles.pillarItem}>Infrastructure</span>
          <span className={styles.pillarItem}>SecOps</span>
          <span
            className={`${styles.pillarItem} ${styles.pillarHighlighted}`}
            title="AI pillar in Workshop"
          >
            AI
            <span className={styles.pillarNewTag}>NEW</span>
          </span>
        </div>

        <p className={styles.pillarSubtitle}>
          Now featuring auto-generated summaries and expanded data &amp; network
          posture checks.
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
                A new web application to plan your Zero Trust deployment
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
