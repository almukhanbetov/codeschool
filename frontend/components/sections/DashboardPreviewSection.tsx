"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon } from "@/lib/icons";
import { SectionHeading } from "@/components/ui/SectionHeading";
import { Button } from "@/components/ui/Button";

export function DashboardPreviewSection() {
  const { t } = useLanguage();
  const { ref: mockRef, className: mockClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="section dashboard-section" id="dashboard">
      <div className="container">
        <SectionHeading
          eyebrow={t.dashboard.eyebrow}
          title={t.dashboard.title}
          description={t.dashboard.subtitle}
        />

        <div ref={mockRef} className={`dashboard-mock ${mockClassName}`}>
          <div className="dashboard-sidebar">
            <div className="dashboard-sidebar-item active">
              <Icon name="layout-dashboard" />
              <span>{t.dashboard.sidebar1}</span>
            </div>
            <div className="dashboard-sidebar-item">
              <Icon name="trending-up" />
              <span>{t.dashboard.sidebar2}</span>
            </div>
            <div className="dashboard-sidebar-item">
              <Icon name="folder-kanban" />
              <span>{t.dashboard.sidebar3}</span>
            </div>
            <div className="dashboard-sidebar-item">
              <Icon name="sparkles" />
              <span>{t.dashboard.sidebar4}</span>
            </div>
          </div>
          <div className="dashboard-main">
            <div className="dashboard-main-head">
              <h3>Python Basics</h3>
              <span className="dashboard-percent">78%</span>
            </div>
            <div className="progress-track dashboard-progress">
              <div className="progress-fill" style={{ width: "78%" }} />
            </div>
            <div className="dashboard-lesson-card">
              <div>
                <span className="dashboard-lesson-num">{t.dashboard.lessonNum}</span>
                <strong>{t.dashboard.lessonName}</strong>
              </div>
              <Button href="#courses" variant="primary" size="sm">
                {t.dashboard.continue}
              </Button>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
