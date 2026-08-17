# 4iCAD web app — 48-hour trial

How the marketing site (`my-web-page-ef286`) grants time-limited access to the
4iCAD web app (`icad-75d53`), and what the web app has to do to honour it.

The two apps live in different Firebase projects, so the web app cannot read
this project's auth state or entitlements. The bridge is a signed bearer token.

## The flow

1. A visitor presses **Try Web App — 48h free** on 4ideasapp.com. If signed out
   they are sent to sign in first: the window is account-bound, because a
   browser-local clock resets on a cleared cache or a second browser and is
   therefore no limit at all.
2. The site calls `startWebTrial`. On the first call the backend writes
   `web_trials/{uid}.startedAt` — the anchor — inside a transaction, so two
   simultaneous launches cannot each start a fresh window.
3. The backend returns the web-app URL with `?trial=<token>` attached. The URL
   comes from `products/4icad_windows.webAppUrl` on the server, never from the
   browser, so a caller cannot have a valid token attached to a site of their
   choosing.
4. The web app reads `?trial=`, stores it, and asks `verifyWebTrial` whether it
   may run — on load, and periodically after that.

Owners are not on a clock. Buying 4iCAD at any point (including after the trial
lapses) turns the next verification into `access: "owner"`.

## What the web app must implement

### Endpoint

```
GET  https://us-central1-my-web-page-ef286.cloudfunctions.net/verifyWebTrial?token=<token>
POST https://us-central1-my-web-page-ef286.cloudfunctions.net/verifyWebTrial   {"token": "<token>"}
```

CORS is restricted to `https://icad-75d53.web.app`,
`https://icad-75d53.firebaseapp.com`, `https://4ideasapp.com`, and
`http://localhost:<port>` for development. Add any custom domain to
`VERIFY_ALLOWED_ORIGINS` in `functions/src/trials/web-trial.ts` before pointing
the web app at it.

### Responses

Always HTTP 200 — a lapsed trial is a legitimate answer, not a fault, and should
render as "trial ended" rather than as an error.

```jsonc
// inside the window
{"valid": true,  "access": "trial", "uid": "…", "expiresAt": 1760171000000, "remainingMs": 5400000}
// bought the product
{"valid": true,  "access": "owner", "uid": "…", "expiresAt": null, "remainingMs": null}
// refused
{"valid": false, "reason": "trial_expired" | "token_expired" | "bad_signature" | "malformed" | "unknown_user"}
```

### Drop-in check

```js
const VERIFY = "https://us-central1-my-web-page-ef286.cloudfunctions.net/verifyWebTrial";

async function checkTrial() {
  // The token arrives once, in the launch URL. Keep it for the session so a
  // refresh does not lose access, and strip it from the address bar.
  const fromUrl = new URLSearchParams(location.search).get("trial");
  if (fromUrl) {
    sessionStorage.setItem("4icad_trial", fromUrl);
    history.replaceState({}, "", location.pathname);
  }
  const token = sessionStorage.getItem("4icad_trial");
  if (!token) return {valid: false, reason: "no_token"};

  try {
    const res = await fetch(`${VERIFY}?token=${encodeURIComponent(token)}`);
    return await res.json();
  } catch {
    // Network failure is not proof of expiry. Decide deliberately: this returns
    // "keep running" so a flaky connection does not eject a paying owner.
    return {valid: true, access: "unknown", offline: true};
  }
}
```

Call it on load, and again on an interval (every 5–10 minutes is plenty — the
window is 48 hours). When it returns `valid: false`, stop the app and show a
"trial ended" screen linking to <https://4ideasapp.com/4icad>.

### Floating countdown inside the web app

`remainingMs` from the verification response is everything the badge needs; tick
it down locally between checks rather than polling once a second.

```js
function mountTrialCounter(remainingMs) {
  if (remainingMs == null) return;            // owner — no clock, no badge
  const el = document.createElement("div");
  el.style.cssText = `
    position:fixed; right:18px; bottom:18px; z-index:9999;
    display:flex; gap:9px; align-items:center;
    padding:10px 16px; border-radius:999px;
    background:rgba(7,18,35,.92); border:1px solid rgba(201,169,110,.55);
    box-shadow:0 8px 22px rgba(0,0,0,.45);
    color:#fff; font:600 14px/1.2 system-ui,sans-serif;`;
  document.body.appendChild(el);

  let left = remainingMs;
  const pad = (n) => String(n).padStart(2, "0");
  const tick = () => {
    if (left <= 0) {                          // let the next verify eject them
      el.textContent = "⏱ Trial ended";
      el.style.borderColor = "rgba(233,141,130,.7)";
      return clearInterval(id);
    }
    const s = Math.floor(left / 1000);
    const hhmmss = `${pad(Math.floor(s / 3600))}:${pad(Math.floor(s / 60) % 60)}:${pad(s % 60)}`;
    el.textContent = `⏱ Trial · ${hhmmss} left`;
    // Under six hours the countdown stops being background information.
    el.style.borderColor = s < 6 * 3600 ? "rgba(232,177,76,.75)" : "rgba(201,169,110,.55)";
    left -= 1000;
  };
  tick();
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);              // re-mount on each verify result
}
```

The same badge already exists on the 4iCAD product page —
`FourICadTrialCounter` in
`lib/features/commerce/presentation/widgets/four_icad_actions.dart` — so keep
the two visually consistent if you restyle either.

Verification is the authority, not the token's own expiry: `verifyWebTrial`
re-reads Firestore each call, so a revoked trial or a refunded purchase takes
effect on the next check.

## Deploying

```bash
# 1. Create the signing key (once). Any long random string.
firebase functions:secrets:set WEB_TRIAL_SIGNING_KEY   # e.g. openssl rand -base64 48

# 2. Ship the functions and the rule for web_trials.
firebase deploy --only functions:startWebTrial,functions:verifyWebTrial
firebase deploy --only firestore:rules
```

Rotating the key invalidates every issued token immediately; visitors simply
press the button again and keep whatever is left of their window, because the
window lives in Firestore rather than in the token.

## Operating it

- **Windows:** `web_trials/{uid}` holds `startedAt`, `expiresAt`, `launchCount`
  and `email`. A visitor may read only their own document; nobody can write one
  from a browser, not even an admin — a browser that could write `startedAt`
  could grant itself an endless trial.
- **Revoking:** set `revoked: true` on the document (Firebase console or Admin
  SDK). Both `startWebTrial` and `verifyWebTrial` refuse it from that moment.
- **Extending or resetting:** delete the document. The next launch starts a
  fresh 48 hours.
- **Changing the length:** `TRIAL_WINDOW_MS` in
  `functions/src/trials/trial-policy.ts`, mirrored for copy only by
  `WebTrial.window` in `lib/data/commerce_data.dart`. Existing trials keep the
  `expiresAt` already written to their document.

## Known limit

A determined visitor can create a second account and get another 48 hours. That
is inherent to an account-bound trial and is the deliberate trade: the
alternative — a device or browser anchor — is bypassed by an incognito window,
which is strictly weaker. Tighten it by requiring a verified email in
`startWebTrial` (swap `requireAuth` for `requireVerifiedAuth`) if throwaway
signups become a real problem.
