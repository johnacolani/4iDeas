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

### Where the codes live, and why

Codes are generated, tracked and sent **entirely from the admin screen** — you
never open the Stripe dashboard. They are nonetheless registered with Stripe,
because Stripe's checkout page only accepts codes it knows about; a code held
only in our database would be rejected as invalid when the customer typed it.
Think of Stripe as the register, and this screen as the control panel.

### The stock: five codes per discount

The top card is the answer to "what do I have left to give away". Each tier
shows how many codes are **available** and how many customers have **used** one,
with expired or disabled codes counted separately so they pad neither figure.

Press **Top up to 5 per discount** to bring every tier back to five. It is
idempotent — a full tier is left alone — so it is safe to press whenever the
stock looks low. Codes come out as `4ICAD50-K7QF2P`: the tier stays legible and
the suffix avoids O/0 and I/1, because these get read aloud and typed by hand.

Restocked codes are always **single-use**. That is what makes the counts mean
anything: one code, one customer, and it flips to used the moment they redeem it.

### Sending one to a customer

Press the ✉ button on any available code, enter their address, and the app:

1. records the recipient against the code, and
2. opens **your own mail app** with the message written out — the code, where to
   go, and how to enter it at checkout.

Nothing is sent by our servers: the site has no mail infrastructure, and a
message from your own address is likelier to be read and replied to than one
from a no-reply sender. The recipient is recorded either way, so the row then
reads "Sent to alice@example.com" — and later, when they buy, "Used by
alice@example.com" underneath it. Comparing those two lines is how you spot a
code that was forwarded on.

If no mail app is available (a fresh browser, a kiosk), the code goes to the
clipboard instead and the recipient is still recorded.

### One-off and campaign codes

The card below the stock still creates codes by hand: switch to **Name one
myself** for a public campaign code like `4ICAD10` meant to circulate, or
generate an ad-hoc batch with its own note, expiry, redemption cap, or
first-time-customer restriction.

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

## 3. Platforms, and putting a new one on sale

The 4iCAD page carries a **Choose your platform** grid — Windows, Web, iOS,
Android, macOS, Linux — matching the promise the hero artwork makes. Each tile
says plainly what can be done today: **Buy**, **Open store**, **Try free — 48h**,
or **Coming very soon**. A platform the visitor already owns says so instead of
selling itself again.

Two things must both be true before a platform can be bought:

1. Its key is in `SELLABLE_PRODUCT_KEYS` (`functions/src/core.ts`) — an
   allowlist, so a typo or a probing client cannot reach a half-configured
   product.
2. `product_config/{key}` holds a `stripePriceId`. This collection is
   server-only; no browser can read or influence which Price is charged.

The tile itself is driven by `products/{key}.platformStatus`, which a browser
*can* read:

| Value | Tile shows |
| --- | --- |
| `buy` | Buy button, straight into Stripe Checkout |
| `store` | Open store — needs `storeUrl` |
| `trial` | Try free — 48 hours |
| `soon` | Coming very soon (the default for unreleased platforms) |

A `storeUrl` alone is enough to open a store, so adding an App Store or Play
listing later is one field on one document — no release needed.

Note the deliberate asymmetry: a product document **cannot promote a platform on
its own**, however complete it looks. Only an explicit `platformStatus` does
that. The reason is that the Stripe Price lives in server-only config the
browser cannot see, so "a product doc exists" is not evidence anything can
actually be charged — and a Buy button that fails at checkout is worse than an
honest "coming soon".

### Selling the web build

Windows is configured and selling. To switch the Web tile from *Try free* to
*Buy*:

1. Create a Price for the browser build in Stripe.
2. Write `product_config/4icad_web` with `{stripePriceId: "price_…", active: true}`.
3. Set `platformStatus: "buy"` on `products/4icad_web`.

Entitlements are per platform, so a web buyer gets `4icad_web` and a Windows
buyer gets `4icad_windows`. Either one counts as ownership for the web app: a
Windows buyer keeps unlimited browser access as part of the purchase they
already made, rather than being put back on the 48-hour clock.

### Selling iOS, Android or macOS

Those go through Apple and Google, not Stripe. When a listing exists, put its
URL in `products/{key}.storeUrl` and the tile becomes a store link. Nothing else
changes — no Stripe Price, no entitlement, because the store handles the sale.

---

## 4. What a buyer gets, and how

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

## 5. Publishing a release — do this before selling

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

## 6. The 48-hour web trial

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

## 7. Deploying

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

## 8. Tests

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

## 9. Conventions worth keeping

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
