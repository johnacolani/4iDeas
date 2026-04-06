# Flutter Web: Keeping the address bar in sync with GoRouter

This guide explains **why** the browser URL sometimes did not match the visible screen on our site, **what** we changed, and **how** to work with URLs correctly as you add features.

It assumes you already know basics of [GoRouter](https://pub.dev/packages/go_router) and that this project routes through `lib/app_router.dart`.

---

## 1. What “wrong URL” looked like

- **Symptom:** The user opened a **case study** (e.g. Absolute Stone Design). The **content** was correct, but the **address bar** still showed `/portfolio` instead of something like `/portfolio/case-study/asd`.
- **Why it matters:**
  - **Bookmarks and sharing** break if the URL does not match the screen.
  - **Browser back/forward** is confusing when history and URL disagree.
  - **Deep links** (opening `/portfolio/case-study/asd` directly) only work if routing and URL stay aligned.

---

## 2. Two ideas: path URLs vs hash URLs

On **Flutter Web**, the app can expose routes in two main ways:

| Style | Example | Notes |
|--------|---------|--------|
| **Hash** | `https://example.com/#/portfolio` | Everything after `#` is client-side; older default. |
| **Path** | `https://example.com/portfolio` | Looks like a normal website path; better for SEO and sharing. |

This project uses **path-based URLs** on web. That is configured once at startup:

- `lib/main.dart` calls `configureWebUrlStrategy()` before `runApp`.
- `lib/url_strategy_web.dart` calls `usePathUrlStrategy()` from `flutter_web_plugins`.

So when you run locally you should see **`http://localhost:<port>/portfolio/...`**, not only `#/portfolio`.

**Stub:** On non-web platforms, `url_strategy_stub.dart` provides a no-op so the same `main.dart` compiles everywhere.

---

## 3. `context.push` vs `context.go` (the important part)

GoRouter offers several navigation methods. The two you need to distinguish for **URL replacement** are:

### `context.push(location)`

- **Adds** a new entry on the **navigation stack**.
- On **web**, behavior depends on setup; often the **visible page** updates but the **browser URL may not change** to the new path the way users expect—especially when mixing stack navigation with flat routes.
- Good when you want a **modal flow** or **wizard** where “back” pops one screen and you care about stack order.

### `context.go(location)`

- **Replaces** the current location with the new one (conceptually “go to this route”).
- The **browser address bar** updates to match **`location`** (with path URL strategy).
- Good when the new screen **is** a full “place” in the app (e.g. a case study page with its own URL).

**Rule of thumb for this codebase:** For screens that have a **dedicated path** in `AppRoutes` (like case studies), prefer **`context.go(AppRoutes.somePath(...))`** so the **URL and the screen stay the same story**.

We use that pattern when opening a case study from:

- `case_study_card.dart` — tap on a case study card.
- `portfolio_app_card.dart` — tap when the app is linked to a case study (`caseStudyId != null`).

---

## 4. How routes are declared here

Paths live in **`AppRoutes`** (`lib/app_router.dart`), for example:

- `AppRoutes.portfolio` → `/portfolio`
- `AppRoutes.portfolioCaseStudyPath(id)` → `/portfolio/case-study/<id>`

The **case study** route is registered as:

```text
path: '/portfolio/case-study/:id'
```

So the ID in the URL (e.g. `asd`) must match a case study `id` in `PortfolioData` (or you’ll see the “Case study not found” placeholder).

**Note:** Portfolio-related routes are declared as **sibling** top-level routes (not only nested under one parent) so that **URL updates stay reliable on web**—see the comment in `app_router.dart` near those `GoRoute`s.

---

## 5. Back button on the case study screen

On a **case study** screen, the user might:

- Arrive from **portfolio** (`go` → often **no** extra stack to pop), or  
- Open a **deep link** directly (nothing to pop).

So the **AppBar back** is implemented to:

- **`context.pop()`** if `context.canPop()` is true (there is stack history).
- Otherwise **`context.go(AppRoutes.portfolio)`** so “back” always has a sensible target.

That lives in `case_study_detail_screen.dart`. When you add similar screens, think: *“What if the user landed here from a shared URL?”*

---

## 6. How to verify (before deploy)

You do **not** need to deploy to check URLs.

1. Run the web app, e.g. `flutter run -d chrome`.
2. Navigate: Home → Portfolio → open a case study.
3. Check the address bar: you should see something like  
   `http://localhost:<port>/portfolio/case-study/<id>`  
   The **host** is local; the **path** should match production.

**After deploy:** Same path structure on your real domain (e.g. `https://4ideasapp.com/portfolio/case-study/asd`). If an old bundle is cached, use a **hard refresh** or **incognito** once.

---

## 7. Checklist when you add a new routed screen

1. Add a **constant path** (and helper if it has parameters) to `AppRoutes`.
2. Register a **`GoRoute`** in `createAppRouter()` with the same path pattern.
3. Navigate with **`context.go`** or **`context.push`** on purpose:
   - Prefer **`go`** if the screen should have its **own bookmarkable URL**.
4. Test in **Chrome** locally and confirm the **address bar** updates.
5. If something only happens on **hosting**, check **Firebase rewrites** so unknown paths serve `index.html` (SPA behavior)—see `DEPLOY_WEB.md` / hosting config for this project.

---

## 8. Related docs in this repo

- `docs/GO_ROUTER_SETUP.md` — broader GoRouter setup and migration notes.
- `DEPLOY_WEB.md` — build and deploy the web bundle.

---

## 9. Short glossary

| Term | Meaning |
|------|--------|
| **Deep link** | Opening the app directly at a URL (e.g. shared link). |
| **Path URL strategy** | Using `/path` instead of `#/path` in the browser. |
| **`GoRouter`** | Declarative routing; syncs with browser history on web when used consistently. |

If you’re unsure whether to use `push` or `go`, ask: *“Should this screen have a stable URL people can copy?”* If **yes**, **`go`** is usually the right default for web.
