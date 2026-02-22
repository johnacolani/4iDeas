# Admin Inline Editing – Plan & TODO List

## Goal
When logged in as **Admin**, show **Add** / **Edit** / **Delete** controls **inline** on each section (Portfolio, Services, About Us, Contact Us). Remove the separate **"Admin - Portfolio & Info"** screen from the drawer; keep **"Admin - Orders"** as-is.

---

## Current State Summary

| Section      | Content source        | Admin today                          |
|-------------|------------------------|--------------------------------------|
| **Portfolio** | Case studies: static (`PortfolioData.caseStudies`) | Separate AdminPortfolioScreen (apps only) |
|             | App showcase: Firestore + static fallback | Add/Edit/Delete apps in AdminPortfolioScreen |
|             | Publications: static (`PortfolioData.publications`) | — |
|             | Open Source: hardcoded (2 cards) | — |
| **Services**  | 6 hardcoded service cards | — |
| **About Us**  | Hardcoded text & blocks | — |
| **Contact Us** | 4 hardcoded items (phone, email, LinkedIn, Portfolio) | — |

---

## 1. Portfolio Section (Admin inline)

### 1.1 Featured Case Studies
- **Add:** Button “Add case study” (only visible to admin). Opens create flow (form or screen) → save to Firestore.
- **Edit:** Each `CaseStudyCard` shows Edit (icon/button) for admin → open edit screen/dialog.
- **Delete:** Delete button on each card for admin → confirm → remove from Firestore.
- **Data:** New Firestore collection `portfolio_case_studies`. Keep static `PortfolioData.caseStudies` as fallback when collection empty. Model already exists: `PortfolioCaseStudy` (+ sections, images).

**TODO (Case Studies):**
- [ ] Add Firestore collection `portfolio_case_studies` and service (e.g. `CaseStudyContentService`) with CRUD.
- [ ] Portfolio screen: if admin, show “Add case study” button above/below Featured Case Studies list.
- [ ] Case study card: if admin, show Edit + Delete on each card (e.g. overlay or row of icons).
- [ ] Create “Case study edit” screen/dialog (create + edit) for title, subtitle, overview, design approach, sections (title, content, images).
- [ ] Wire create/update/delete to Firestore and refresh list; keep fallback to static data when Firestore empty.

### 1.2 App Showcase
- **Add:** Button “Add app” for admin. Reuse existing flow (e.g. `AdminPortfolioAppEditScreen`) or inline dialog.
- **Edit / Delete:** Each `PortfolioAppCard` shows Edit + Delete for admin; Delete already implemented in `PortfolioContentService`; Edit uses existing `AdminPortfolioAppEditScreen`.

**TODO (App Showcase):**
- [ ] Portfolio screen: if admin, show “Add app” button for App Showcase section.
- [ ] `PortfolioAppCard`: if admin, show Edit + Delete (e.g. small icon buttons). Edit → push to `AdminPortfolioAppEditScreen` (or inline dialog). Delete → confirm → `PortfolioContentService.deleteApp` + refresh.
- [ ] Ensure app list refreshes after add/edit/delete (already uses `_displayApps` / Firestore).

### 1.3 Publications
- **Add:** “Add publication” for admin. Save to Firestore.
- **Edit / Delete:** Per publication card: Edit + Delete for admin.

**TODO (Publications):**
- [ ] Add Firestore collection `portfolio_publications` and service (e.g. `PublicationContentService`) with CRUD (title, url, optional order).
- [ ] Portfolio screen: load publications from Firestore with static fallback; if admin, show “Add publication”.
- [ ] Publication card: if admin, show Edit + Delete; add edit/create screen or dialog (title, URL).
- [ ] Wire CRUD and refresh list.

### 1.4 Open Source & Package
- **Add:** “Add open source item” for admin. Store title, subtitle, url, optional icon/key.
- **Edit / Delete:** Per open-source card: Edit + Delete for admin.

**TODO (Open Source):**
- [ ] Add Firestore collection `portfolio_open_source` and service with CRUD (e.g. title, subtitle, url, iconName or order).
- [ ] Portfolio screen: load open source items from Firestore with static fallback (current 2 items); if admin, show “Add open source item”.
- [ ] Open source card: if admin, show Edit + Delete; add edit/create screen or dialog.
- [ ] Wire CRUD and refresh list.

---

## 2. Services Section (Admin inline)

- **Items:** Each service = one card (icon, title, subtitle, description, list of details).
- **Add:** “Add service” for admin. New Firestore collection `services` (or `site_services`).
- **Edit:** Each service card shows Edit for admin → edit screen/dialog (icon, title, subtitle, description, details list).
- **Delete:** Delete on each card for admin → confirm → remove from Firestore.

**TODO (Services):**
- [ ] Define `ServiceItem` model (icon name/code, title, subtitle, description, details list) and Firestore collection.
- [ ] Add `ServicesContentService` (or extend a generic “site content” service) with CRUD for service items.
- [ ] Services screen: load service cards from Firestore; fallback to current hardcoded 6 items if empty.
- [ ] If admin: show “Add service” and on each card show Edit + Delete.
- [ ] Build service edit/create screen or dialog; wire CRUD and refresh.

---

## 3. About Us Section (Admin inline)

- **Content:** Currently one-off text (name, tagline, location, bio, etc.) and possibly contact-style blocks. Need to define “editable blocks” (e.g. title, subtitle, body text, list of links).
- **Add:** Optional “Add section” or “Add link” depending on structure.
- **Edit:** Each logical block (e.g. bio, skills, link list) has Edit for admin.
- **Delete:** Only for optional/repeatable items (e.g. extra links or sections).

**TODO (About Us):**
- [ ] Define About Us content model (e.g. sections: title, content, order; or single document with fields).
- [ ] Add Firestore collection/document(s) for About Us and service with read/update (and optional create/delete for list items).
- [ ] About Us screen: load from Firestore with fallback to current hardcoded content; if admin, show Edit (and Add/Delete where applicable) per block.
- [ ] Build edit UI (form/dialog) for each block type; wire save and refresh.

---

## 4. Contact Us (Admin inline)

- **Items:** Contact entries: phone, email, LinkedIn, Portfolio (and any future links). Each has type (phone/email/link), label, value (number, email, or URL), optional action (tel:, mailto:, or open URL).
- **Add:** “Add contact” for admin.
- **Edit:** Each contact row shows Edit for admin (change label, value, type).
- **Delete:** Delete per contact for admin.

**TODO (Contact Us):**
- [ ] Define `ContactEntry` model (e.g. type: phone | email | link, label, value, optional urlForLink).
- [ ] Add Firestore collection `contact_entries` and service with CRUD.
- [ ] Contact Us dialog/screen: load contact list from Firestore; fallback to current 4 hardcoded items if empty. If admin, show Add and per-item Edit + Delete.
- [ ] Build contact edit/create dialog; wire CRUD and refresh. Ensure “View Portfolio” stays as app navigation (context.go) and other entries stay as tel:/mailto:/launch URL.

---

## 5. Remove “Admin - Portfolio & Info”

- **TODO:**
  - [ ] Remove drawer menu item “Admin - Portfolio & Info” that opens `AdminPortfolioScreen`.
  - [ ] Decide: keep `AdminPortfolioScreen` and `AdminPortfolioAppEditScreen` as reusable screens (opened from Portfolio when editing an app) or inline everything into Portfolio and delete the standalone admin portfolio screen. **Recommendation:** Keep `AdminPortfolioAppEditScreen` for add/edit app form; remove only the drawer entry and the standalone list view (AdminPortfolioScreen) if all app management is now from Portfolio.

---

## 6. Shared / Infrastructure

- **TODO:**
  - [ ] Reuse `AdminService.isAdmin()` on Portfolio, Services, About Us, and Contact Us to show/hide Add and Edit/Delete.
  - [ ] Optional: shared “admin action bar” or “edit/delete icon” widget used across cards for consistency.
  - [ ] Ensure Firestore security rules allow read for all, write only for authenticated admin (e.g. by email or custom claim).

---

## Implementation Order (suggested)

1. **Portfolio – App Showcase** (Firestore + UI already exist): Add “Add app” on Portfolio + Edit/Delete on each app card; remove drawer “Admin - Portfolio & Info”.
2. **Portfolio – Publications**: Firestore + service + “Add” + Edit/Delete on publication cards.
3. **Portfolio – Open Source**: Firestore + service + “Add” + Edit/Delete on open source cards.
4. **Portfolio – Case Studies**: Firestore + service + “Add” + Edit/Delete + case study edit screen (most complex).
5. **Services**: Model + Firestore + load + Add/Edit/Delete.
6. **About Us**: Model + Firestore + load + Edit (and optional Add/Delete).
7. **Contact Us**: Model + Firestore + load + Add/Edit/Delete in dialog.

---

## TODO List (flat, for tracking)

- [ ] **P1** Portfolio – App Showcase: “Add app” button when admin.
- [ ] **P2** Portfolio – App Showcase: Edit + Delete on each `PortfolioAppCard` when admin.
- [ ] **P3** Remove “Admin - Portfolio & Info” from drawer; keep Admin Orders.
- [ ] **P4** Publications: Firestore collection + CRUD service + load with fallback.
- [ ] **P5** Publications: “Add publication” + Edit/Delete on each card when admin + edit dialog/screen.
- [ ] **P6** Open Source: Firestore collection + CRUD service + load with fallback.
- [ ] **P7** Open Source: “Add open source” + Edit/Delete on each card when admin + edit dialog/screen.
- [ ] **P8** Case studies: Firestore collection + CRUD service + load with fallback.
- [ ] **P9** Case studies: “Add case study” + Edit/Delete on each card when admin.
- [ ] **P10** Case studies: Case study create/edit screen (sections, images).
- [ ] **S1** Services: Define model + Firestore + CRUD service + load with fallback.
- [ ] **S2** Services: “Add service” + Edit/Delete per card when admin + edit dialog/screen.
- [ ] **A1** About Us: Define content model + Firestore + load with fallback.
- [ ] **A2** About Us: Edit (and optional Add/Delete) per block when admin.
- [ ] **C1** Contact Us: Define `ContactEntry` + Firestore + CRUD + load with fallback.
- [ ] **C2** Contact Us: “Add contact” + Edit/Delete per item when admin in dialog.
- [ ] **Infra** Firestore rules: read public, write admin-only; optional shared admin widget.
