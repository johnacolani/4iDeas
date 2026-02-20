# Portfolio Section Implementation Plan

Based on [10 Exceptional Product Design Portfolios with Case Study Breakdowns](https://designerup.co/blog/10-exceptional-product-design-portfolios-with-case-study-breakdowns/), this plan outlines how to transform your portfolio section into a case-study-driven, product design showcase similar to Ellen Covey, Simon Pan, and Madeline Wukusick.

---

## Design Philosophy (From the Reference)

**Key elements that make exceptional portfolios stand out:**
1. Clear problem statement with user/business context
2. Thoughtful, user-centered approach
3. Transparent process (research, ideation, testing)
4. Cohesive narrative: Introduction → Problem → Solution → Process → Outcomes
5. Project cards with overview, goals, and links to live products
6. Clean, focused presentation revealing unique point of view

---

## Current State vs. Target State

| Aspect | Current | Target |
|--------|---------|--------|
| Content | Single case study (ASD) only | All apps + publications + package + GitHub |
| Format | Long scroll, one project | Case study cards → Expandable detail pages |
| Navigation | Link to external WebView | In-app sections with optional external links |
| Apps | Not listed | Grid of app cards with store links |
| Publications | Not shown | Medium articles with links |
| Package | Not shown | Pub.dev package card |
| Video | Not used | Portfolio video embed or link |

---

## Information Architecture

```
Portfolio Screen (Main)
├── Hero / Introduction
│   └── Short tagline + video link (Portfolio 2024 JohnColani.mp4)
├── Featured Case Studies (Full Case Study Format)
│   ├── 1. Absolute Stone Design (ASD) — already have content
│   ├── 2. Twin Scriptures — from colani_products
│   └── 3. [Optional] Vision Exercise — from vision_exercise/README
├── App Showcase (Cards with brief description + store links)
│   ├── Great T2S
│   ├── ASD USA
│   ├── Solomon Prayers Compass
│   ├── Phillips Rear Vu
│   ├── Dream Whisperer
│   ├── Infinite Notes Plus
│   ├── Twin Scriptures
│   ├── Twin Scripture EN/TR
│   └── Fraction Flow
├── Publications
│   └── Medium articles (6) with titles + links
├── Open Source & Package
│   ├── auto_scroll_image (pub.dev)
│   └── Weather App (GitHub - BLoC, Clean Architecture)
└── External Portfolio Link
    └── "View Full Portfolio" → Google Sites (existing)
```

---

## Case Study Template (Per Project)

Following DesignerUp formats (Ellen Covey, Simon Pan, Madeline Wukusick):

| Section | Content |
|---------|---------|
| **Introduction** | Brief overview, purpose, target audience |
| **The Problem** | Challenges faced by users/business |
| **The Solution** | What the product does to solve it |
| **Research & Insights** | User research, personas, key findings |
| **Design Process** | Ideation, wireframes, prototyping, iterations |
| **Final Designs** | High-fidelity mockups, key screens |
| **Outcomes & Reflections** | Impact, metrics, learnings |

---

## Data Sources for Content

| Content | Source |
|---------|--------|
| ASD case study | `colani_products/README.md`, `ASD-Product/README.md` |
| Twin Scriptures case study | `colani_products/README.md`, `Twin-Scriptures/README.md` |
| Vision Exercise | `colani_products/vision_exercise/README.md` |
| App metadata (names, store URLs) | User-provided links |
| Publication titles/URLs | User-provided Medium links |
| Images | `colani_products/ASD-Product/images/`, `Twin-Scriptures/pictures/`, `john_portfolio/assets` |

---

## TODO List (Implementation Order)

### Phase 1: Data & Structure
- [ ] **1.1** Create `lib/data/portfolio_data.dart` — centralized model for case studies, apps, publications
- [ ] **1.2** Define `PortfolioCaseStudy`, `PortfolioApp`, `PortfolioPublication` models
- [ ] **1.3** Populate data from colani_products READMEs and user-provided links

### Phase 2: Core Portfolio Screen Redesign
- [ ] **2.1** Replace current single-case layout with scrollable sections
- [ ] **2.2** Add hero section with tagline + video link (Portfolio 2024)
- [ ] **2.3** Create `CaseStudyCard` widget — collapsible/expandable or navigates to detail
- [ ] **2.4** Add "Featured Case Studies" section (ASD, Twin Scriptures, optionally Vision Exercise)

### Phase 3: App Showcase
- [ ] **3.1** Create `AppShowcaseCard` widget — app name, short description, App Store + Play Store buttons
- [ ] **3.2** Build responsive grid of app cards (2–3 columns desktop, 1–2 tablet, 1 mobile)
- [ ] **3.3** Add app descriptions (brief, 1–2 lines each — you can provide these)

### Phase 4: Publications & Open Source
- [ ] **4.1** Create `PublicationCard` — title, link to Medium
- [ ] **4.2** Create `PackageCard` for auto_scroll_image (pub.dev link)
- [ ] **4.3** Create `GitHubProjectCard` for Weather App (BLoC, Clean Architecture, tests)
- [ ] **4.4** Add "Publications" and "Open Source" sections

### Phase 5: Case Study Detail Screens
- [ ] **5.1** Create `CaseStudyDetailScreen` — full case study layout (Problem, Solution, Research, etc.)
- [ ] **5.2** Implement for ASD (reuse existing content, restructure into template)
- [ ] **5.3** Implement for Twin Scriptures (from colani_products)
- [ ] **5.4** Optionally add Vision Exercise case study
- [ ] **5.5** Copy images from colani_products into my_web_site/assets/portfolio/

### Phase 6: Assets & Polish
- [ ] **6.1** Copy or reference images from colani_products (ASD, Twin Scriptures)
- [ ] **6.2** Add app icons/placeholders if available
- [ ] **6.3** Ensure responsive typography (match existing ColorManager, Google Fonts)
- [ ] **6.4** Add url_launcher for all external links (App Store, Play Store, Medium, GitHub, pub.dev)
- [ ] **6.5** Integrate video link (Portfolio 2024) — open in browser or embed if supported

### Phase 7: Navigation & Integration
- [ ] **7.1** Keep "View Full Portfolio" link to Google Sites (optional)
- [ ] **7.2** Ensure web and mobile layouts look good
- [ ] **7.3** Test all links open correctly on web and mobile

---

## Questions for You

Before implementation, a few clarifications will help:

1. **App descriptions**: Do you have 1–2 sentence descriptions for each app (Great T2S, Dream Whisperer, Solomon Prayers Compass, etc.)? Or should I use placeholder text derived from store names?

2. **Vision Exercise**: What is the vision_exercise app? Should it be a full case study or a simple app card?

3. **Video**: Should the Portfolio 2024 video open in a new tab (GitHub raw/view URL) or would you prefer it hosted elsewhere (YouTube, Vimeo) for embedding?

4. **Images**: Can I copy images from `/Users/johncolani/colani_products/` into `my_web_site/assets/portfolio/`? Or do you prefer keeping them in colani_products and using relative paths (which would require colani_products to be part of the project)?

5. **Order of apps**: Any preferred order (by date, category, popularity)?

6. **Additional apps**: You listed Solomon Prayers Compass, Dream Whisperer, Great T2S, ASD USA, Phillips Rear Vu, Infinite Notes Plus, Twin Scriptures, Twin Scripture EN/TR, Fraction Flow. Are there any others to include or exclude?

---

## File Structure (Proposed)

```
lib/
├── data/
│   └── portfolio_data.dart          # Models + static data
├── features/
│   └── portfolio/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── portfolio_screen.dart       # Main portfolio (redesigned)
│       │   │   └── case_study_detail_screen.dart
│       │   └── widgets/
│       │       ├── case_study_card.dart
│       │       ├── app_showcase_card.dart
│       │       ├── publication_card.dart
│       │       └── section_header.dart
assets/
├── portfolio/
│   ├── asd/                         # ASD case study images
│   ├── twin_scriptures/             # Twin Scriptures images
│   └── app_icons/                   # App icons (if available)
```

---

## Estimated Effort

| Phase | Effort |
|-------|--------|
| Phase 1: Data & Structure | 1–2 hours |
| Phase 2: Core Redesign | 2–3 hours |
| Phase 3: App Showcase | 1–2 hours |
| Phase 4: Publications & Open Source | 1 hour |
| Phase 5: Case Study Details | 2–3 hours |
| Phase 6: Assets & Polish | 1–2 hours |
| Phase 7: Navigation & Integration | 0.5–1 hour |
| **Total** | **~9–14 hours** |

---

*Plan created: February 17, 2025*
