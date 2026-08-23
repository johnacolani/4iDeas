# 4iCAD Linux release setup

Linux uses the same protected commerce flow as Windows: Stripe grants a
product-scoped entitlement, Firebase Storage denies direct reads, and a Cloud
Function issues a short-lived download URL only after checking ownership.

## One-time production configuration

1. Create the Linux product and one-time Price in Stripe.
2. In the server-only Firestore collection, create
   `product_config/4icad_linux`:

   ```text
   stripePriceId: "price_..."
   active: true
   ```

3. In the public-readable Firestore collection, create
   `products/4icad_linux`:

   ```text
   displayName: "4iCAD for Linux"
   tagline: "Professional CAD for the Linux desktop."
   active: true
   platformStatus: "buy"
   platformNote: "AppImage, Debian package, or archive"
   priceAmountMinor: 4900
   priceCurrency: "usd"
   ```

   `priceAmountMinor` is display-only. Checkout always uses the trusted Stripe
   Price ID from `product_config`, never a price supplied by the browser.

4. Deploy the backend and Storage rules:

   ```bash
   firebase deploy --only functions,storage
   ```

## Publishing a Linux build

1. Sign in as an administrator.
2. Open `/admin/4icad/releases`.
3. Select **Linux** in the Platform field.
4. Choose an `.AppImage`, `.deb`, or `.tar.gz` package.
5. Enter the version and release notes, then publish it as Current.

The package is uploaded beneath `releases/linux/{version}/`. It is never
publicly readable. Existing Linux customers automatically receive access to
future Current Linux releases without purchasing again.

## Recommended first-release check

- Complete a real or 100%-discounted Linux checkout with a non-admin account.
- Confirm the entitlement is `4icad_linux`.
- Confirm the Linux tile changes from **Buy** to **Download**.
- Confirm the downloaded filename and SHA-256 match the published package.
- Confirm the same account does not gain Windows or Web ownership.
