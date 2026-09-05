# syntax=docker/dockerfile:1
#
# Frontend image. Next.js App Router with `output: "standalone"` (see
# next.config.ts) -> the build emits a self-contained `.next/standalone`
# server that needs neither the full node_modules nor the Next CLI at runtime.
# Multi-stage, runs as the non-root `node` user, runs `node server.js`
# (the production server) — never `next dev`.
#
# NEXT_PUBLIC_* are inlined into the client bundle at BUILD time, so they are
# passed as build args by docker-compose (per environment). They are public
# values (API URLs), not secrets.

# --- deps: install with a clean, reproducible lockfile ---
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# --- build ---
FROM node:22-alpine AS build
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ARG NEXT_PUBLIC_BROWSER_API_URL
ENV NEXT_PUBLIC_BROWSER_API_URL=${NEXT_PUBLIC_BROWSER_API_URL}
RUN npm run build

# --- runtime: only the standalone server + static assets, nothing else ---
FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

# `node` (uid 1000) ships with the base image. Copy build output owned by it.
COPY --from=build --chown=node:node /app/public ./public
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static ./.next/static

USER node
EXPOSE 3000
CMD ["node", "server.js"]
