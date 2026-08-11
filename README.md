# GrowCentricDemo

Demo pages for **GrowCentric.ai**: a product teaser used for screenshots and demo videos.

> **Full feature guide**: see [`docs/FEATURES.md`](docs/FEATURES.md) for every page, every
> settings section, the demo narrative and how all features connect.
No real integrations: every page is rendered from seeded demo data. The app sits behind
a Devise login wall; the seeded demo user is `georg@keferboeck.com` (password comes from
`GROWCENTRIC_DEMO_PASSWORD`, with a default set in `db/seeds.rb`). `/register` has no
signup form: GrowCentric.ai is in private beta, access requests go to georg@growcentric.ai.

The demo merchant is **Velora Cycling Supply**, a fictional Vienna-based Shopify shop.
All brands, competitors and domains in the data are invented.

## Pages

| Path | What it shows |
|---|---|
| `/` | Dashboard: value added by GrowCentric, product portfolio matrix, revenue, forecast, alerts |
| `/sherpa` | Sherpa (Beta): AI growth copilot with grounded Q&A, morning briefing and drafted work |
| `/content`, `/content/queue`, `/content/experiments` | Content (Beta): per-product content states with actions, approval queue, A/B & multivariate content tests. Brand voice, tone sources and workflow live under `/settings/content` |
| `/hidden-potential` | Catalog analysis: products with untapped potential, ranked by score |
| `/competitors` | Competitive landscape from Google Shopping discovery + live signal feed |
| `/price-position` | Cheapest-vs-visibility verdicts per SKU + who advertises where (Google Shopping / Meta / TikTok) |
| `/delivery` | Captured shipping tariffs (postcode / radius / weight / size / thresholds), subscription & quantity offers, season sales |
| `/forecast` | Daily revenue actuals + 60-day forecast with confidence band and early warning |
| `/campaigns` | ROAS vs POAS per campaign, ML budget reallocation (margin × conversion × inventory × competitive), A/B tests |
| `/dynamic-pricing` | Pricing engine: price development chart, sold-price by channel/campaign/segment, guardrails, elasticity optima, decision log |
| `/recommendations` | Invest / pull back / corrective actions with projected impact |
| `/resellers` | Manufacturer mode: reseller/UVP monitoring as LumenRide GmbH, violations, auto-notices, gray-market detection |
| `/settings/*` | SaaS settings: automation & thresholds (auto-approve vs review), notifications & briefing, integrations & crawler, API & products, content & brand voice, reseller policy (UVP), team & permissions, plan & billing, profile |

The forecast page includes a champion/challenger model comparison (Ensemble, gradient
boosting, SARIMA, Holt-Winters baseline with backtest MAPE and band coverage); the
competitors page carries a crawl index (derived price indices only, no stored competitor
prices) with per-competitor quantity/subscription/sale intel; Sherpa's briefing stages
auto-reactions to competitor moves, governed by the automation settings.

The campaigns and dynamic-pricing pages implement the concepts from
[Dynamic Pricing & Algorithmic Marketing: The Complete Technical Playbook](https://keferboeck.com/en-gb/articles/dynamic-pricing-and-algorithmic-marketing-the-complete-technical-playbook):
POAS = ROAS × gross margin, the four-factor budget allocation score, elasticity
optimum P* = (C × ε)/(ε + 1), hourly repricing loop, and guardrails
(cost floor, KVI ceilings, ±5%/day, ,90 rounding, 30% elasticity blend).

## Stack

- Rails 7.1 · PostgreSQL · Tailwind CSS v4 (`tailwindcss-rails`)
- UI follows Tailwind Plus application-UI patterns (sidebar shell, stat cards, tables, feeds)
- Brand colours come from `growcentric-landing` (`#fff1be` / `#ee87cb` / `#b060ff`),
  defined as Tailwind theme tokens in `app/assets/tailwind/application.css`
  (`brand-*` and the derived `accent-*` purple scale, plus `.bg-brand-gradient`)
- Charts are server-rendered inline SVG (`app/helpers/chart_helper.rb`,
  `app/views/shared/_forecast_chart.html.erb`) with a vanilla-JS crosshair tooltip

## Languages

The whole demo is bilingual: English and German, switchable via the flag menu next
to the user avatar (persists in the session, or `?locale=de` / `?locale=en` in any URL).
Translation works gettext-style: English strings in the views are the source, and
`app/helpers/german_dictionary.rb` maps them 1:1 to German via the `dt()` helper
(`app/helpers/translation_helper.rb`). Missing entries fall back to English, so new
copy can never break a page. Dates and time-ago strings localise via `rails-i18n`.

## Setup

```sh
bundle install
bin/rails db:create db:migrate db:seed
bin/dev        # runs the server + tailwind watcher (Procfile.dev)
```

Database credentials are in `config/database.yml` (local `postgres` user; override the
password with `GROWCENTRIC_DB_PASSWORD`).

## Deployment (DigitalOcean App Platform, GitHub deploy)

The app deploys straight from GitHub via App Platform's Ruby buildpack; the spec lives
in `.do/app.yaml` (Procfile: `web: bundle exec puma -C config/puma.rb`):

1. Push the repo to GitHub and update the two `github.repo` entries in `.do/app.yaml`.
2. Create the app from the spec (`doctl apps create --spec .do/app.yaml` or paste the
   spec in the dashboard under Create App -> Edit App Spec). It provisions a dev
   Postgres and wires `DATABASE_URL`; the buildpack precompiles assets automatically.
3. Set the secrets in the dashboard: `SECRET_KEY_BASE` (generate with `bin/rails secret`)
   and optionally `GROWCENTRIC_DEMO_PASSWORD` for the demo login.
4. After the first deploy, point `APP_HOST` at the assigned URL (or custom domain).

The web process runs `rails db:prepare db:seed` before starting Puma; the seeds are
idempotent and date-relative, so each deploy migrates the database and refreshes the
demo data (remove `db:seed` from the command if you want the data left alone; it also
makes boot take a few seconds longer, covered by the health check's initial delay).
Health check is `/up`
(not behind the login wall). Password reset mails use the `:test` delivery in
production too, since the demo has no SMTP.

Re-running `bin/rails db:seed` resets all demo data; the forecast is generated relative
to the current date, so re-seed before recording new screenshots or videos to keep the
"Today" marker fresh.
