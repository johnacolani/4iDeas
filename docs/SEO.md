# SEO for 4iDeas (Flutter Web)

## Realistic limits of Flutter Web SEO

- **Single Page App (SPA):** The first HTTP response is `web/index.html` with a fixed shell. After JavaScript runs, the app updates `<title>`, meta description, Open Graph, Twitter card, and `<link rel="canonical">` per route via `lib/seo/seo_document_web.dart` and `attachSeoToRouter` in `lib/main.dart`.
- **Crawlers:** Google generally executes JavaScript; others may not fully. For maximum control (snippets, social previews per URL without JS), you would add **server-side rendering, pre-rendering, or static HTML** for key URLs at the CDN/host (e.g. Cloudflare, prerender.io, or a small edge function). That is **not** included here.
- **Semantic HTML headings:** Flutter paints mostly to canvas/DOM widgets; `Semantics(header: true)` improves **accessibility** and may help when the engine exposes a meaningful a11y tree. It is **not** the same as raw `<h1>` in static HTML for every crawler.
- **Images:** Decorative assets should stay out of the semantics tree (`ExcludeSemantics` where used); informative images use `semanticLabel` on `Image.asset` where added.

## Files

| File | Role |
|------|------|
| `web/index.html` | Default title, description, OG/Twitter defaults, `lang`, theme-color, JSON-LD `@graph` (Organization, WebSite, Person, ProfessionalService), canonical for `/`. |
| `web/robots.txt` | Allow all + sitemap URL. Served as a static asset from `build/web` (Firebase serves static files before SPA rewrites). |
| `web/sitemap.xml` | Lists primary marketing URLs; submit in Google Search Console. |
| `lib/seo/seo_resolver.dart` | Maps route path → title, description, canonical path (includes case studies from `PortfolioData`). |
| `lib/seo/seo_document_web.dart` | Updates DOM on navigation (web only). |
| `lib/seo/seo_binding.dart` | Listens to `GoRouter` and reapplies SEO after each navigation. |
| `firebase.json` | Hosting rewrites: static files (e.g. `robots.txt`, `sitemap.xml`) are served if present; otherwise SPA fallback applies. |

## Recommended meta titles & descriptions (key routes)

Values are defined in code (`seo_resolver`) and should stay aligned with this table.

| Route | Meta title (target ≤ ~60 chars) | Meta description (target ~155 chars) |
|--------|-----------------------------------|----------------------------------------|
| `/` | Flutter Developer & Product Designer \| MVP & Firebase \| 4iDeas | US-focused Flutter developer and product designer: MVP apps, Flutter + Firebase, iOS, Android, and web from Richmond, VA. Clear scopes and one accountable build path. |
| `/services` | Services — Flutter, MVP, Firebase & Product Design \| 4iDeas | Hire for MVP delivery, Flutter development, Firebase backends, product UX/UI, and AI features that belong in the product. Clear scopes for startups and US businesses. |
| `/portfolio` | Portfolio — Flutter Apps, Case Studies & Product Design \| 4iDeas | Case studies and shipped Flutter products: business constraints, role, outcomes, and links to live apps. Design + engineering proof. |
| `/about` | About — Flutter Engineer & Product Designer \| 4iDeas | Background and how we work with US clients: Flutter engineering, product design, Firebase, and accountable delivery—Richmond, VA roots. |
| `/contact` | Contact — Start a Flutter or MVP Project \| 4iDeas | Describe your app, timeline, and stack. Flutter + Firebase, MVPs, and product design for US clients—candid next steps. |
| `/flutter-developer-richmond-va` | Flutter Developer in Richmond, VA \| US Clients \| 4iDeas | Richmond, Virginia–based Flutter developer: product design, MVP app development, Flutter + Firebase, one accountable path from idea to release. |
| `/mvp-app-development` | MVP App Development with Flutter & Firebase \| 4iDeas | Ship a credible MVP faster: scoped Flutter, Firebase backends, UX for your market, and clear communication for US teams. |
| `/product-design-flutter-engineering` | Product Design + Flutter Engineering \| Designer‑Developer \| 4iDeas | Product designer who ships in Flutter: UX/UI, design systems, Firebase, production code for iOS, Android, and web. |

Case study URLs `/portfolio/case-study/:id` use the case study title plus a trimmed overview from `PortfolioData`.

## Structured data (JSON-LD) plan

Implemented as a static `@graph` in `web/index.html`:

| Type | @id | Notes |
|------|-----|--------|
| **Organization** | `https://4ideas.com/#organization` | Brand, logo, Richmond VA postal address. |
| **WebSite** | `https://4ideas.com/#website` | `inLanguage: en-US`, publisher → Organization. |
| **Person** | `https://4ideas.com/#person` | John A. Colani; `knowsAbout` skills; `worksFor` → Organization. **Update** `sameAs` / profile URLs in JSON-LD when you add LinkedIn, GitHub, etc. |
| **ProfessionalService** | `https://4ideas.com/#service` | Provider → Organization; `areaServed` US; `serviceType` and description aligned with positioning. |

Optional next steps (not implemented): **BreadcrumbList** on deep pages; **FAQ** only if you add real FAQ content; **LocalBusiness** if you want stronger map pack signals (requires consistent NAP + Google Business Profile).

## Hosting / Search Console

1. Deploy `build/web` including `robots.txt` and `sitemap.xml`.
2. In **Google Search Console**, verify the property and submit `https://4ideas.com/sitemap.xml`.
3. Optionally add **Bing Webmaster Tools** with the same sitemap.
4. If you use a **custom domain on Firebase**, confirm `https://4ideas.com` is canonical everywhere (no mixed `www` without redirects).

## Internal linking

- Homepage hero includes topic links to the three intent landing routes (`lib/core/widgets/home_hero_section.dart`).
- Landing pages link to **Contact**, **Portfolio**, and **Services** (`lib/screens/seo_topic_landing_screen.dart`).

## Image alt strategy

- **Informative logos / service icons:** `semanticLabel` on `Image.asset` (Firebase, AWS, per-service icons, drawer logo).
- **Decorative animation:** portfolio Lottie wrapped in `ExcludeSemantics` so screen readers skip it.

## Migration note (`dart:html`)

`lib/seo/seo_document_web.dart` uses `dart:html` with lint ignores. Upgrading to `package:web` + `dart:js_interop` is recommended when you adopt newer Dart/Flutter web patterns.
