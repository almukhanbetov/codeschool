"use client";

import { useState } from "react";
import { useLanguage } from "@/hooks/useLanguage";

/**
 * Renders lesson.videoUrl safely. Only two shapes are ever embedded:
 *   - a direct https video file (.mp4/.webm/.ogg/.ogv/.mov) -> native <video>
 *   - a YouTube or Vimeo link -> a sandboxed iframe on the provider's own
 *     privacy-enhanced/player domain, built from an extracted ID (never the
 *     raw URL string interpolated into markup)
 * Anything else (unknown host, non-https, unparsable) falls back to a plain
 * outbound link — it is never embedded. No dangerouslySetInnerHTML anywhere.
 */

type Kind = { type: "file"; src: string } | { type: "youtube"; id: string } | { type: "vimeo"; id: string } | { type: "unsupported" };

const FILE_EXT = /\.(mp4|webm|ogg|ogv|mov)$/i;

function classify(raw: string): Kind {
  let u: URL;
  try {
    u = new URL(raw);
  } catch {
    return { type: "unsupported" };
  }
  if (u.protocol !== "https:") return { type: "unsupported" };

  const host = u.hostname.replace(/^www\./, "");

  if (host === "youtube.com" || host === "m.youtube.com") {
    const id = u.searchParams.get("v");
    if (id && /^[\w-]{6,20}$/.test(id)) return { type: "youtube", id };
    return { type: "unsupported" };
  }
  if (host === "youtu.be") {
    const id = u.pathname.slice(1);
    if (id && /^[\w-]{6,20}$/.test(id)) return { type: "youtube", id };
    return { type: "unsupported" };
  }
  if (host === "vimeo.com" || host === "player.vimeo.com") {
    const id = u.pathname.split("/").filter(Boolean).pop();
    if (id && /^\d{6,15}$/.test(id)) return { type: "vimeo", id };
    return { type: "unsupported" };
  }
  if (FILE_EXT.test(u.pathname)) {
    return { type: "file", src: u.toString() };
  }
  return { type: "unsupported" };
}

export function LessonVideo({ url }: { url: string }) {
  const { t } = useLanguage();
  const [fileError, setFileError] = useState(false);
  const kind = classify(url);

  if (kind.type === "youtube") {
    return (
      <div className="learn-video">
        <iframe
          className="learn-video-frame"
          src={`https://www.youtube-nocookie.com/embed/${kind.id}`}
          title={t.learn.videoTitle}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          referrerPolicy="strict-origin-when-cross-origin"
          sandbox="allow-scripts allow-same-origin allow-presentation"
          allowFullScreen
        />
      </div>
    );
  }

  if (kind.type === "vimeo") {
    return (
      <div className="learn-video">
        <iframe
          className="learn-video-frame"
          src={`https://player.vimeo.com/video/${kind.id}`}
          title={t.learn.videoTitle}
          allow="autoplay; fullscreen; picture-in-picture; clipboard-write"
          referrerPolicy="strict-origin-when-cross-origin"
          sandbox="allow-scripts allow-same-origin allow-presentation"
          allowFullScreen
        />
      </div>
    );
  }

  if (kind.type === "file" && !fileError) {
    return (
      <div className="learn-video">
        <video
          className="learn-video-frame"
          controls
          playsInline
          preload="metadata"
          onError={() => setFileError(true)}
        >
          <source src={kind.src} />
        </video>
      </div>
    );
  }

  // Only ever offer a clickable fallback for a genuinely safe http(s) URL —
  // never pass an arbitrary scheme (javascript:, data:, vbscript:, ...)
  // straight into href. React 19 also blocks javascript: hrefs itself, but
  // this component doesn't rely on that as the only line of defense.
  let safeHref: string | null = null;
  try {
    const parsed = new URL(url);
    if (parsed.protocol === "https:" || parsed.protocol === "http:") safeHref = parsed.toString();
  } catch {
    safeHref = null;
  }

  return (
    <p className="learn-video-error">
      {fileError ? t.learn.videoLoadError : t.learn.videoUnsupported}
      {safeHref && (
        <>
          {" "}
          <a href={safeHref} target="_blank" rel="noreferrer">
            {t.learn.videoOpenLink}
          </a>
        </>
      )}
    </p>
  );
}
