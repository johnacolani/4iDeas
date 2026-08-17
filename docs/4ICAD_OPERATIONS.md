# 4iCAD operations runbook

Everything needed to run the 4iCAD side of the site: who can administer it,
how to discount it, how a buyer gets the installer, and how the 48-hour web
trial works. Deep integration detail for the web app lives in
[4ICAD_WEB_TRIAL.md](4ICAD_WEB_TRIAL.md).

The governing principle throughout: **money and access are decided server-side.**
The Flutter client shows and hides things as a courtesy, but every real decision
is made by Cloud Functions and Firestore/Storage rules reading the verified ID
token. Hiding a button is never the control.

---

## 1. Admin access

The admin menu appears in the home header (desktop/web) and the nav menu button
(mobile) — the same code runs on web, iOS and Android, so all three get it.

Menu entries: Profile · Admin orders · Contact inbox · Privacy policies ·
4iCAD releases · 4iCAD orders · Promotion codes.

They are rendered from one list, `HomeNavMenuItems.adminItems` in
`lib/widgets/home_mobile_nav_menu_button.dart`. **Add a new admin screen there**
and it appears in both menus at once; a router test asserts every entry resolves
to a declared route, so the list cannot grow a dead link.

You qualify as an admin by either:

- the `admin: true` custom claim on your account, or
- the legacy allowlist — exactly one address, in `AdminService._adminEmails`,
  `LEGACY_ADMIN_EMAILS` (functions), and both rules files. Remove all four
  together once every admin has the claim.

The claim is cached at sign-in. After granting one with `setAdminClaim`, the
account needs a fresh token: sign out and back in, or call
`AdminService.refreshAdminClaim(force: true)`.

Admin routes are all URL-addressable, so they can be bookmarked:

| Screen | Route |
| --- | --- |
| 4iCAD releases | `/admin/4icad/releases` |
| 4iCAD orders | `/admin/4icad/orders` |
| Order detail | `/admin/4icad/orders/{sessionId}` |
| Promotion codes | `/admin/4icad/promotions` |

---

## 2. Discount codes

**Where:** admin menu → Promotion codes, or `/admin/4icad/promotions`.

### Keeping a stock of codes to hand out

1. Pick a tier chip (10 / 30 / 50 / 70 / 100 %).
2. Leave the mode on **Generate codes** and choose how many (1, 5, 10 or 20;
   the backend caps a batch at 20).
3. Optionally add a **note** — "Trade show", "Acme Ltd" — which is stored on the
   code in Stripe and shown in the list, so you can tell later what a batch was
   for.
4. Press **Generate**. Codes come out as `4ICAD50-K7QF2P`: the tier stays
   legible and the suffix avoids O/0 and I/1, because these get read aloud and
   typed by hand.

Generated codes are **single-use by default** (max redemptions 1) — that is what
makes the list meaningful. Copy one with the button beside it and send it
however you like; the app deliberately sends no email.

Switch the mode to **Name one myself** for a public campaign code like
`4ICAD10`, where the same code is meant to circulate.

### Telling who used what

The list is the ledger. Each code carries a status badge, derived live from
Stripe rather than stored anywhere:

| Badge | Meaning |
| --- | --- |
| `AVAILABLE` | Still spendable — safe to hand out |
| `USED` | Every redemption spent. For a single-use code, a customer redeemed it |
| `EXPIRED` | Past its expiry date, and nobody used it in time |
| `DISABLED` | Switched off by an admin |

A used code is greyed and struck through, its toggle disappears (it is
finished), and it sinks below the codes still in play. Underneath it, a green
line names **who spent it** — email, date and the amount they saved — joined
from the order the Stripe webhook wrote. That join is the only way to answer
"who used this code": Stripe counts the redemption, our order record knows the
person behind it.

If a code shows `USED` but no name, the webhook has not landed yet, or the order
predates the code's id being recorded.

Notes that matter:

- **Nothing calculates a discount in our code.** `allow_promotion_codes: true`
  makes Stripe render and validate the field on its own checkout page. The
  customer clicks **"Add promotion code"** under the subtotal — Stripe keeps it
  collapsed until clicked — and types the code there.
- The five tiers are enforced server-side; any other percentage is refused.
- Coupons are scoped to the 4iCAD Stripe product, so a code cannot be spent on
  anything else.
- Codes belong to the **mode of the secret key that created them**. A test
  (Sandbox) key makes sandbox codes; they will not exist in live mode. Recreate
  them after switching to a live key.
- Stripe only allows toggling `active` on an existing code. The discount value
  is immutable, which is what you want for anything already in customers' hands.
- A **100% code is a real order**, not a bypass: Checkout reports
  `no_payment_required`, the webhook treats that as fulfillable, and the buyer
  gets a normal entitlement. Orders record `originalAmount`, `amountDiscount`,
  `amountPaid`, `percentOff` and the code used.

---

## 3. What a buyer gets, and how

1. They press Buy → `createCheckoutSession` → Stripe's hosted checkout.
2. Stripe returns them to `/4icad/success?session_id=…`. **That page proves
   nothing** — the session id is a lookup hint. It calls `getPurchaseStatus`,
   which reads server state.
3. The **webhook is what grants access**: `checkout.session.completed` writes
   the order and the entitlement. The redirect usually beats the webhook, so the
   page reports "processing" and polls every 3s up to 10 times.
4. Once entitled, `/4icad` and the success page show **Download {version} for
   Windows**.
5. `getDownloadUrl` re-checks entitlement server-side, finds the release marked
   Current, and returns a **V4 signed URL valid for 10 minutes**. Issuance is
   logged to `download_audit` and capped at 20/hour per account.
6. Later, from any device: sign in → `/4icad` → Download. Entitlement is
   product-scoped, not release-scoped, so **every future version is included**
   and the button always serves whatever is Current.

The installer is never publicly readable — Storage rules deny client reads on
`releases/windows/`, so that function is the only path to the bytes, and a
copied link dies in ten minutes.

### Buying requires a verified email

`requireVerifiedAuth` reads `email_verified` from the ID token. Note that
`user.reload()` refreshes the local user object but **not** the cached token, so
the app force-refreshes the token before checkout and after any reload that
reports verification. If a buyer ever sees "Verify your email address before
purchasing" despite having verified, that token refresh is the thing to check.

Verification is deliberately **not** required for downloads: once someone has
paid, entitlement is the authority, and re-checking would strand a legitimate
buyer who later changed to an unverified address.

---

## 4. Publishing a release — do this before selling

**If no release is marked Current, buyers see "No Windows release has been
published yet" and the download button is disabled — they have paid and cannot
download.** Check `/admin/4icad/releases` before announcing a launch.

Admin menu → 4iCAD releases: upload the installer to Storage under
`releases/windows/…`, publish it, then set it Current. `publishRelease` refuses
any path outside that prefix and verifies the object exists. Setting a new
release Current clears the flag from the previous one in a batch, so exactly one
is ever Current.

Publishing denormalises a public-safe summary (version, size, checksum, notes)
onto the product document. It deliberately omits `storagePath` — that must never
reach a browser.

---

## 5. The 48-hour web trial

A visitor presses **Try Web App**, signs in, and gets 48 hours in the 4iCAD web
app. The window is anchored server-side to their Firebase uid on first launch,
so re-launching does not extend it and clearing browser storage does not restart
it. Owners are not on a clock at all.

- `startWebTrial` writes the anchor transactionally and returns the web-app URL
  with a signed token attached.
- `verifyWebTrial` is the public endpoint the web app calls to ask whether it
  may keep running. It re-reads Firestore every time, so a revoked trial or a
  refund takes effect on the next check.
- `web_trials/{uid}` is **read-own, write-nobody** — a browser that could write
  `startedAt` could grant itself an endless trial.

Operating it:

| Task | How |
| --- | --- |
| Revoke a trial | Set `revoked: true` on `web_trials/{uid}` |
| Extend / reset | Delete the document; the next launch starts a fresh 48 hours |
| Change the length | `TRIAL_WINDOW_MS` in `functions/src/trials/trial-policy.ts` (existing trials keep the `expiresAt` already written) |
| See who trialled | The `web_trials` collection — it carries `email` and `launchCount` |

**Outstanding:** until the `mountTrialCounter()` and verification snippet from
[4ICAD_WEB_TRIAL.md](4ICAD_WEB_TRIAL.md) are pasted into the `icad-75d53`
project, the 48 hours gate the launch button on this site but not the web app
itself — a bookmarked URL still works.

A second account gets another 48 hours. That is inherent to an account-bound
trial and is the deliberate trade: a device or browser anchor is bypassed by an
incognito window, which is strictly weaker.

---

## 6. Deploying

```bash
# Functions (all, or name them individually)
firebase deploy --only functions
firebase deploy --only functions:startWebTrial,functions:verifyWebTrial

# Rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules

# Web hosting
flutter build web --release && firebase deploy --only hosting
```

**Gotcha:** if a deploy fails with `Cannot determine backend specification.
Timeout after 10000`, that is firebase-tools' source-analysis step timing out on
a slow machine, not a code fault. Re-run with a longer window:

```bash
FUNCTIONS_DISCOVERY_TIMEOUT=120 firebase deploy --only functions
```

Verify the module itself is healthy with
`node -e "require('./lib/index.js')"` from `functions/` — it should load in
well under a second.

### Secrets

Set with `firebase functions:secrets:set NAME`, injected at runtime, never
bundled into client code and never logged.

| Secret | Used by |
| --- | --- |
| `STRIPE_SECRET_KEY` | checkout, promotions, webhook, purchase status |
| `STRIPE_WEBHOOK_SECRET` | webhook signature verification |
| `WEB_TRIAL_SIGNING_KEY` | signing and verifying trial tokens |

Rotating `WEB_TRIAL_SIGNING_KEY` invalidates every issued trial token
immediately. Visitors simply press the button again and keep whatever is left of
their window, because the window lives in Firestore rather than in the token.

---

## 7. Tests

Three suites, all runnable locally:

```bash
flutter test                       # client value types, routes, purchase state
npm --prefix functions test        # auth guards, trial policy (build + node --test)
npm --prefix rules-test test       # Firestore/Storage rules against the emulator
```

Anything that decides money or access belongs in the functions or rules suites,
not the client one. The client tests exist so the UI never *promises* something
the server would refuse, and never blocks something it would allow.

---

## 8. Conventions worth keeping

- **Never trust the browser for price, discount, entitlement or trial length.**
  The client sends a product key and nothing else.
- **Every URL-addressable screen needs an explicit back button.** These pages
  are opened cold — pasted links, QR codes, Stripe redirects — and with an empty
  navigator stack Flutter renders no arrow at all. Use
  `FrostedAppBar.backLeading(context, fallback: …)`, pointing the fallback at
  the screen one level up.
- **One list per navigation surface.** The admin destinations were once three
  hand-maintained copies, one of which was never mounted; that is how the 4iCAD
  screens ended up reachable only by typing their URLs.
- **Entitlement before verification.** An owner keeps their download even if
  their email later becomes unverified.
