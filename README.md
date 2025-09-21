# Joseph Waite – Homepage

Personal homepage for Joseph Waite highlighting product leadership, software work, and contact options. The site is built with Astro, Tailwind CSS v4, and DaisyUI, and applies a custom palette + typography pairing (Playfair Display & Work Sans).

## Features

- Responsive hero introducing Joseph Waite with custom fonts and curated colour palette
- Featured work grid powered by reusable `ProjectCard` components and shared data source
- Contact section with Calendly call-to-action and copy-to-clipboard email button instrumented for analytics
- Plausible analytics loaded only in production plus custom event tracking for key interactions

## Project Structure

```text
src/
├─ assets/
│  └─ global.css          # Tailwind entrypoint, DaisyUI plugin, theme tokens, shared utilities
├─ components/
│  ├─ ContactCard.astro    # CTA with calendly + email button
│  ├─ ProjectCard.astro    # Individual featured project card
│  └─ SectionHeading.astro # Shared heading + divider pattern
├─ data/
│  └─ projects.ts         # Featured work definitions
├─ layouts/
│  └─ Layout.astro        # Root layout and metadata, loads fonts/styles, injects Plausible in prod
├─ pages/
│  └─ index.astro         # Homepage assembly using the above building blocks
└─ scripts/
   └─ siteInteractions.ts # Browser script wiring custom Plausible events & clipboard behaviour
```

## Getting Started

```bash
npm install
npm run dev
```

The dev server runs at `http://localhost:4321`. Fonts are served from Google Fonts; no additional setup required.

## Production Build

```bash
npm run build
npm run preview
```

During production builds the layout injects the Plausible script (`data-domain=josephwaite.ca`). Custom events fire for:

- Project card clicks (`Project Card Click` with project label)
- Calendly button (`Schedule Call`)
- Email copy action (`Email Copied` with location + display email)

## Styling Notes

- Tailwind CSS v4 with DaisyUI provides the component primitives.
- Theme tokens and component-level utilities (such as the copy button animation) live in `src/assets/global.css`.
- Colour palette is defined via custom CSS variables for consistency across DaisyUI + Tailwind.

## Deployment

The site outputs a fully static build in `dist/`. Deploy the contents of that folder to any static host (e.g., Netlify, Vercel, Cloudflare Pages). Ensure the production domain is `josephwaite.ca` to align with Plausible tracking.

## Infrastructure & Agents

Operational helpers and runbooks live under `agents/`:

1. Generate local convenience variables once with `./agents/scripts/extract-secrets.sh`. This creates `agents/secrets.local.env`, which is git-ignored.
2. Run discovery or deployment helpers as needed:
   - `./agents/scripts/discover.sh`
   - `./agents/scripts/deploy-dev.sh`
   - `./agents/scripts/deploy-prod.sh`
3. Scripts automatically source `${SECRET_ENV:-agents/secrets.local.env}` when present so commands stay runnable without hardcoding IDs.
4. See `agents/runbook.md` for the full AWS/Terraform workflow and environment-specific guidance.
