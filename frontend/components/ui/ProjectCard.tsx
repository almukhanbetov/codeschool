"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon, type IconName } from "@/lib/icons";
import type { ProjectItem } from "@/types";

export function ProjectCard({ item }: { item: ProjectItem }) {
  const { t } = useLanguage();
  const { ref, className } = useReveal<HTMLElement>();
  const project = t.projects[item.key];

  return (
    <article ref={ref} className={`project-card ${className}`}>
      <div className={`project-thumb ${item.thumbClass}`} aria-hidden="true">
        <Icon name={item.icon as IconName} />
      </div>
      <div className="project-body">
        <h3>{project.title}</h3>
        <div className="project-meta">
          <span className="project-tech">{item.tech}</span>
          <span>{project.age}</span>
        </div>
        <p>{project.desc}</p>
      </div>
    </article>
  );
}
