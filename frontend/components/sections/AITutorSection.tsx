"use client";

import { useLanguage } from "@/hooks/useLanguage";
import { useReveal } from "@/hooks/useReveal";
import { Icon } from "@/lib/icons";
import { SectionHeading } from "@/components/ui/SectionHeading";

export function AITutorSection() {
  const { t } = useLanguage();
  const { ref: chatRef, className: chatClassName } = useReveal<HTMLDivElement>();

  return (
    <section className="section aitutor-section">
      <div className="container aitutor-inner">
        <SectionHeading
          eyebrow={t.aitutor.eyebrow}
          title={t.aitutor.title}
          description={
            <>
              {t.aitutor.desc1}
              <br />
              <span className="strong-line">{t.aitutor.desc2}</span>
            </>
          }
          align="left"
        />

        <div ref={chatRef} className={`chat-mock ${chatClassName}`}>
          <div className="chat-bubble chat-student">
            <div className="chat-avatar" aria-hidden="true">
              <Icon name="user" />
            </div>
            <div className="chat-content">
              <p>{t.aitutor.q}</p>
              <pre className="code-block code-block-error">
                <code>
                  <span className="tok-kw">for</span> i <span className="tok-kw">in</span>{" "}
                  <span className="tok-num">10</span>:{"\n    "}
                  <span className="tok-fn">print</span>(i)
                </code>
              </pre>
            </div>
          </div>

          <div className="chat-bubble chat-ai">
            <div className="chat-avatar chat-avatar-ai" aria-hidden="true">
              <Icon name="sparkles" />
            </div>
            <div className="chat-content">
              <p dangerouslySetInnerHTML={{ __html: t.aitutor.a1 }} />
              <p dangerouslySetInnerHTML={{ __html: t.aitutor.a2 }} />
              <p>{t.aitutor.a3}</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
