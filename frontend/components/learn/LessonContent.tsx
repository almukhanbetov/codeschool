/**
 * Renders lessons.content safely. The column stays plain TEXT (no schema
 * change, no new required field, old rows keep working) — this is a small,
 * hand-written parser for a safe Markdown-like *subset*, not a general
 * Markdown/HTML engine: only the constructs below are recognized, everything
 * else (including any literal HTML tag) is shown as plain text. There is no
 * dangerouslySetInnerHTML anywhere in this file — every node is a real React
 * element built from parsed, escaped text.
 *
 * Supported per line/block:
 *   # / ## / ### heading
 *   - or *  bullet list item (consecutive lines group into one <ul>)
 *   1. 2. … ordered list item (consecutive lines group into one <ol>)
 *   ```lang / ``` fenced code block
 *   blank-line-separated paragraphs, with inline **bold**, *italic*, `code`,
 *     [text](https://…) links and ![alt](https://…) images
 * Links/images: only http(s) URLs are ever turned into a real href/src —
 * anything else renders as plain text. Images are additionally restricted to
 * an explicit host allowlist (currently empty — this project has no image
 * upload/hosting pipeline yet, so an unrecognized image host safely falls
 * back to showing the alt text only, never a broken/arbitrary remote image).
 *
 * Plain, unstructured text (exactly what the 19 pre-existing lessons store)
 * has no lines matching any of the above, so it falls straight through to
 * the paragraph path — one <p> per non-blank line — which is the same
 * content, still fully readable, just no longer forced into a monospace
 * <pre> block.
 */

import type { ReactNode } from "react";

const ALLOWED_IMAGE_HOSTS: string[] = [];

function safeHref(raw: string): string | null {
  try {
    const u = new URL(raw);
    return u.protocol === "https:" || u.protocol === "http:" ? u.toString() : null;
  } catch {
    return null;
  }
}

function safeImageSrc(raw: string): string | null {
  try {
    const u = new URL(raw);
    if (u.protocol !== "https:") return null;
    return ALLOWED_IMAGE_HOSTS.includes(u.hostname) ? u.toString() : null;
  } catch {
    return null;
  }
}

/** Inline formatting within one paragraph/list-item line: **bold**, *italic*, `code`, [text](url), ![alt](url). */
function renderInline(text: string, keyBase: string): ReactNode[] {
  const nodes: ReactNode[] = [];
  // Order matters: images before links (both use []()), then code, then bold before italic.
  const pattern = /!\[([^\]]*)\]\(([^)]+)\)|\[([^\]]*)\]\(([^)]+)\)|`([^`]+)`|\*\*([^*]+)\*\*|\*([^*]+)\*/g;
  let last = 0;
  let m: RegExpExecArray | null;
  let i = 0;
  while ((m = pattern.exec(text))) {
    if (m.index > last) nodes.push(text.slice(last, m.index));
    const key = `${keyBase}-${i++}`;
    if (m[1] !== undefined) {
      const src = safeImageSrc(m[2]);
      nodes.push(src ? <img key={key} src={src} alt={m[1]} className="learn-content-img" /> : <span key={key}>{m[1] || m[2]}</span>);
    } else if (m[3] !== undefined) {
      const href = safeHref(m[4]);
      nodes.push(
        href ? (
          <a key={key} href={href} target="_blank" rel="noreferrer">
            {m[3]}
          </a>
        ) : (
          <span key={key}>{m[3]}</span>
        )
      );
    } else if (m[5] !== undefined) {
      nodes.push(<code key={key}>{m[5]}</code>);
    } else if (m[6] !== undefined) {
      nodes.push(<strong key={key}>{m[6]}</strong>);
    } else if (m[7] !== undefined) {
      nodes.push(<em key={key}>{m[7]}</em>);
    }
    last = pattern.lastIndex;
  }
  if (last < text.length) nodes.push(text.slice(last));
  return nodes;
}

export function LessonContent({ text }: { text: string }) {
  const lines = text.replace(/\r\n/g, "\n").split("\n");
  const blocks: ReactNode[] = [];
  let i = 0;
  let key = 0;

  while (i < lines.length) {
    const line = lines[i];

    if (line.trim() === "") {
      i++;
      continue;
    }

    // fenced code block
    if (line.trim().startsWith("```")) {
      const codeLines: string[] = [];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith("```")) {
        codeLines.push(lines[i]);
        i++;
      }
      i++; // skip closing fence
      blocks.push(
        <pre key={key++} className="learn-content-code">
          <code>{codeLines.join("\n")}</code>
        </pre>
      );
      continue;
    }

    // heading
    const heading = /^(#{1,3})\s+(.*)$/.exec(line);
    if (heading) {
      const level = heading[1].length;
      const content = renderInline(heading[2], `h${key}`);
      const cls = "learn-content-heading";
      blocks.push(
        level === 1 ? (
          <h4 key={key++} className={cls}>{content}</h4>
        ) : level === 2 ? (
          <h5 key={key++} className={cls}>{content}</h5>
        ) : (
          <h6 key={key++} className={cls}>{content}</h6>
        )
      );
      i++;
      continue;
    }

    // unordered list
    if (/^[-*]\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^[-*]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^[-*]\s+/, ""));
        i++;
      }
      blocks.push(
        <ul key={key++} className="learn-content-list">
          {items.map((it, idx) => (
            <li key={idx}>{renderInline(it, `ul${key}-${idx}`)}</li>
          ))}
        </ul>
      );
      continue;
    }

    // ordered list
    if (/^\d+[.)]\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\d+[.)]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\d+[.)]\s+/, ""));
        i++;
      }
      blocks.push(
        <ol key={key++} className="learn-content-list">
          {items.map((it, idx) => (
            <li key={idx}>{renderInline(it, `ol${key}-${idx}`)}</li>
          ))}
        </ol>
      );
      continue;
    }

    // paragraph — collect consecutive plain lines into one <p>, one <br/> each
    const paraLines: string[] = [];
    while (
      i < lines.length &&
      lines[i].trim() !== "" &&
      !lines[i].trim().startsWith("```") &&
      !/^(#{1,3})\s+/.test(lines[i]) &&
      !/^[-*]\s+/.test(lines[i]) &&
      !/^\d+[.)]\s+/.test(lines[i])
    ) {
      paraLines.push(lines[i]);
      i++;
    }
    blocks.push(
      <p key={key++} className="learn-content-para">
        {paraLines.map((l, idx) => (
          <span key={idx}>
            {renderInline(l, `p${key}-${idx}`)}
            {idx < paraLines.length - 1 && <br />}
          </span>
        ))}
      </p>
    );
  }

  return <div className="learn-content-body">{blocks}</div>;
}
