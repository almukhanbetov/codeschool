"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon } from "@/lib/icons";
import { Button } from "@/components/ui/Button";

export function HeroSection() {
  const { t } = useLanguage();
  const { ref: contentRef, className: contentClassName } = useReveal<HTMLDivElement>();
  const { ref: visualRef, className: visualClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="hero" id="hero">
      <div className="hero-bg" aria-hidden="true">
        <div className="glow glow-1" />
        <div className="glow glow-2" />
        <div className="glow glow-3" />
        <div className="grid-overlay" />
      </div>

      <div className="container hero-inner">
        <div ref={contentRef} className={`hero-content ${contentClassName}`}>
          <div className="hero-badge">
            <span className="dot" />
            <span>{t.hero.badge}</span>
          </div>

          <h1 className="hero-title">
            <span>{t.hero.title1}</span>
            <br />
            <span className="gradient-text">{t.hero.title2}</span>
          </h1>

          <p className="hero-subtitle">{t.hero.subtitle}</p>
          <p className="hero-extra">{t.hero.extra}</p>

          <div className="hero-cta-row">
            <Button href="#courses" variant="primary" size="lg">
              <span>{t.hero.cta1}</span>
              <Icon name="arrow-right" aria-hidden="true" />
            </Button>
            <Button href="/teacher" variant="secondary" size="lg">
              {t.hero.cta2}
            </Button>
          </div>

          <div className="hero-trust">
            <div className="trust-item">
              <Icon name="users" aria-hidden="true" />
              <span>{t.hero.trust1}</span>
            </div>
            <div className="trust-item">
              <Icon name="languages" aria-hidden="true" />
              <span>{t.hero.trust2}</span>
            </div>
            <div className="trust-item">
              <Icon name="hammer" aria-hidden="true" />
              <span>{t.hero.trust3}</span>
            </div>
            <div className="trust-item">
              <Icon name="sparkles" aria-hidden="true" />
              <span>{t.hero.trust4}</span>
            </div>
          </div>
        </div>

        <div ref={visualRef} className={`hero-visual ${visualClassName}`} aria-hidden="true">
          <div className="float-card card-python">
            <div className="float-card-head">
              <Icon name="file-code-2" />
              <span>Python</span>
            </div>
            <pre className="code-block">
              <code>
                <span className="tok-kw">for</span> i <span className="tok-kw">in</span>{" "}
                <span className="tok-fn">range</span>(<span className="tok-num">5</span>):
                {"\n    "}
                <span className="tok-fn">print</span>(<span className="tok-str">&quot;Hello&quot;</span>)
              </code>
            </pre>
          </div>

          <div className="float-card card-robotics">
            <div className="float-card-head">
              <Icon name="cpu" />
              <span>Robotics</span>
            </div>
            <ul className="chip-list">
              <li>Arduino</li>
              <li>Sensors</li>
            </ul>
          </div>

          <div className="float-card card-ai">
            <div className="float-card-head">
              <Icon name="brain-circuit" />
              <span>AI</span>
            </div>
            <ul className="chip-list">
              <li>Machine Learning</li>
            </ul>
          </div>

          <div className="float-card card-progress">
            <div className="float-card-head">
              <span>Python Basics</span>
              <span className="progress-percent">72%</span>
            </div>
            <div className="progress-track">
              <div className="progress-fill" style={{ width: "72%" }} />
            </div>
          </div>

          <div className="hero-orbit-ring" aria-hidden="true" />
        </div>
      </div>
    </section>
  );
}
