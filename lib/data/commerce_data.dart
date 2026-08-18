import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show IconData, Icons;

/// The Windows desktop build — the product with a download behind it.
const String kFourICadWindowsKey = '4icad_windows';

/// The browser build, sold separately from the Windows installer.
const String kFourICadWebKey = '4icad_web';

/// How a platform can currently be obtained.
enum PlatformAvailability {
  /// Buyable here and now through Stripe Checkout.
  buy,

  /// Sold through Apple or Google, so the link leaves the site.
  store,

  /// Not for sale yet, but usable on the 48-hour trial.
  trial,

  /// Announced, not shippable.
  comingSoon,
}

/// One row in the "every platform" grid on the 4iCAD page.
///
/// Availability is deliberately declared per platform rather than inferred from
/// whether a price happens to exist: a half-configured product must read as
/// "coming soon", never as a Buy button that fails at checkout.
class FourICadPlatform {
  const FourICadPlatform({
    required this.key,
    required this.label,
    required this.icon,
    required this.availability,
    this.logoAsset,
    this.storeUrl,
    this.note,
  });

  /// Product key for the platforms that are sold; null for the rest.
  final String? key;
  final String label;

  /// Fallback glyph, used if the logo asset is missing at runtime.
  final IconData icon;

  /// The platform's own logo. The source files differ in both size and aspect
  /// ratio, so they are always drawn inside a fixed square box with
  /// [BoxFit.contain] — that, not the file, is what makes them look uniform.
  final String? logoAsset;
  final PlatformAvailability availability;

  /// Apple/Google listing, once there is one.
  final String? storeUrl;
  final String? note;

  bool get isSellable => availability == PlatformAvailability.buy && key != null;

  FourICadPlatform copyWith({
    PlatformAvailability? availability,
    String? storeUrl,
    String? note,
  }) {
    return FourICadPlatform(
      key: key,
      label: label,
      icon: icon,
      logoAsset: logoAsset,
      availability: availability ?? this.availability,
      storeUrl: storeUrl ?? this.storeUrl,
      note: note ?? this.note,
    );
  }

  /// Applies an override from `products/{key}`, so a platform can go on sale —
  /// or gain a store link — by writing one document, with no code change.
  ///
  /// Only an explicit `platformStatus` moves a platform; a product document
  /// that merely exists never promotes one, because the Stripe Price lives in
  /// server-only config that the browser cannot see.
  FourICadPlatform applyOverride(Map<String, dynamic>? map) {
    if (map == null) return this;
    final storeUrl = (map['storeUrl'] as String?)?.trim();
    final status = switch ((map['platformStatus'] as String?)?.trim()) {
      'buy' => PlatformAvailability.buy,
      'store' => PlatformAvailability.store,
      'trial' => PlatformAvailability.trial,
      'soon' => PlatformAvailability.comingSoon,
      _ => null,
    };
    return copyWith(
      // A store link implies the store, so a link alone is enough to open one.
      availability: status ?? (storeUrl != null && storeUrl.isNotEmpty
          ? PlatformAvailability.store
          : null),
      storeUrl: storeUrl != null && storeUrl.isNotEmpty ? storeUrl : null,
      note: (map['platformNote'] as String?)?.trim(),
    );
  }
}

/// Every platform 4iCAD is announced on, in the order the hero artwork shows
/// them. Windows and the browser build are sellable today; the rest are honest
/// about not being ready.
const List<FourICadPlatform> kFourICadPlatforms = [
  FourICadPlatform(
    key: kFourICadWindowsKey,
    label: 'Windows',
    logoAsset: 'assets/icons/Windows_logo.png',
    icon: Icons.desktop_windows_outlined,
    availability: PlatformAvailability.buy,
    note: 'Windows 10 & 11, 64-bit',
  ),
  FourICadPlatform(
    key: kFourICadWebKey,
    label: 'Web',
    logoAsset: 'assets/icons/web_logo.png',
    icon: Icons.public,
    availability: PlatformAvailability.trial,
    note: 'Runs in any modern browser',
  ),
  FourICadPlatform(
    key: null,
    label: 'iOS',
    logoAsset: 'assets/icons/ios-logo.png',
    icon: Icons.phone_iphone,
    availability: PlatformAvailability.comingSoon,
    note: 'iPhone and iPad',
  ),
  FourICadPlatform(
    key: null,
    label: 'Android',
    logoAsset: 'assets/icons/android-logo.png',
    icon: Icons.android,
    availability: PlatformAvailability.comingSoon,
    note: 'Phones and tablets',
  ),
  FourICadPlatform(
    key: null,
    label: 'macOS',
    logoAsset: 'assets/icons/macOS_logo.png',
    icon: Icons.laptop_mac,
    availability: PlatformAvailability.comingSoon,
    note: 'Apple silicon and Intel',
  ),
  FourICadPlatform(
    key: null,
    label: 'Linux',
    logoAsset: 'assets/icons/Linux-logo.png',
    icon: Icons.terminal,
    availability: PlatformAvailability.comingSoon,
    note: 'Desktop distributions',
  ),
];

/// Public-safe snapshot of the Current Windows release, denormalised onto the
/// product document by the backend. Deliberately carries no storage path — the
/// installer location never reaches a browser.
class ReleaseSummary {
  const ReleaseSummary({
    required this.releaseId,
    required this.version,
    this.publishedAt,
    this.fileSizeBytes,
    this.sha256,
    this.releaseNotes,
  });

  final String releaseId;
  final String version;
  final DateTime? publishedAt;
  final int? fileSizeBytes;
  final String? sha256;
  final String? releaseNotes;

  static ReleaseSummary? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final version = (map['version'] as String?)?.trim();
    final releaseId = (map['releaseId'] as String?)?.trim();
    if (version == null || version.isEmpty || releaseId == null) return null;
    return ReleaseSummary(
      releaseId: releaseId,
      version: version,
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate(),
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt(),
      sha256: map['sha256'] as String?,
      releaseNotes: map['releaseNotes'] as String?,
    );
  }

  /// Human-readable size, e.g. `84.2 MB`.
  String? get formattedSize {
    final bytes = fileSizeBytes;
    if (bytes == null || bytes <= 0) return null;
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 100 || unit == 0 ? 0 : 1)} ${units[unit]}';
  }
}

/// Public product display data. The Stripe Price id lives in a separate
/// server-only collection — nothing here decides what a customer is charged.
class CommerceProduct {
  const CommerceProduct({
    required this.productKey,
    required this.displayName,
    this.tagline,
    this.active = true,
    this.priceAmountMinor,
    this.priceCurrency,
    this.webAppUrl,
    this.features = const [],
    this.windowsRequirements = const [],
    this.currentRelease,
  });

  final String productKey;
  final String displayName;
  final String? tagline;
  final bool active;

  /// Display price in the currency's minor unit (cents). Advisory only.
  final int? priceAmountMinor;
  final String? priceCurrency;

  final String? webAppUrl;
  final List<String> features;
  final List<String> windowsRequirements;
  final ReleaseSummary? currentRelease;

  bool get hasPrice => priceAmountMinor != null && priceAmountMinor! > 0;

  /// Formats the advisory display price, e.g. `$49.00`.
  String? get formattedPrice {
    final minor = priceAmountMinor;
    if (minor == null || minor <= 0) return null;
    final code = (priceCurrency ?? 'usd').toUpperCase();
    final symbol = switch (code) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      _ => '',
    };
    final amount = (minor / 100).toStringAsFixed(2);
    return symbol.isEmpty ? '$amount $code' : '$symbol$amount';
  }

  factory CommerceProduct.fromMap(String id, Map<String, dynamic> map) {
    return CommerceProduct(
      productKey: id,
      displayName: (map['displayName'] as String?)?.trim().isNotEmpty == true
          ? map['displayName'] as String
          : '4iCAD for Windows',
      tagline: map['tagline'] as String?,
      active: map['active'] as bool? ?? true,
      priceAmountMinor: (map['priceAmountMinor'] as num?)?.toInt(),
      priceCurrency: map['priceCurrency'] as String?,
      webAppUrl: (map['webAppUrl'] as String?)?.trim(),
      features: (map['features'] as List?)?.whereType<String>().toList() ?? const [],
      windowsRequirements:
          (map['windowsRequirements'] as List?)?.whereType<String>().toList() ?? const [],
      currentRelease:
          ReleaseSummary.fromMap((map['currentRelease'] as Map?)?.cast<String, dynamic>()),
    );
  }

  /// Fallback used before the product document exists in Firestore, so the page
  /// still renders truthfully. Pricing stays absent until an admin sets it —
  /// the retail price is never invented here.
  static CommerceProduct fourICadFallback() => const CommerceProduct(
        productKey: kFourICadWindowsKey,
        displayName: '4iCAD for Windows',
        tagline: 'Professional CAD, designed mobile-first and shipped to the desktop.',
        webAppUrl: 'https://icad-75d53.web.app',
        features: [
          'Touch-first drafting with precision snapping',
          'Guided commands for common drafting operations',
          'DXF support for exchanging drawings',
          'Image insertion for tracing and reference',
          'Cloud files that follow you between devices',
          'Fabrication-oriented tools for real shop work',
        ],
        windowsRequirements: [
          'Windows 10 or Windows 11 (64-bit)',
          'Desktop, laptop, and Windows tablet',
        ],
      );
}

/// Where a visitor stands with the 48-hour 4iCAD web-app trial.
enum WebTrialStatus {
  /// Never launched the web app, so the clock has not started.
  notStarted,

  /// Inside the 48-hour window.
  active,

  /// The window has elapsed, or an admin revoked it.
  expired,

  /// Owns 4iCAD, so no trial applies.
  owned,
}

/// The signed-in visitor's trial window, read from `web_trials/{uid}`.
///
/// The document is written only by the backend — a browser that could write its
/// own `startedAt` could grant itself an endless trial — so everything here is
/// display state derived from a server-anchored start time.
class WebTrial {
  const WebTrial({
    required this.status,
    this.startedAt,
    this.expiresAt,
  });

  const WebTrial.notStarted() : this(status: WebTrialStatus.notStarted);
  const WebTrial.owned() : this(status: WebTrialStatus.owned);

  final WebTrialStatus status;
  final DateTime? startedAt;
  final DateTime? expiresAt;

  /// The trial length the backend enforces. Mirrored here only for copy.
  static const Duration window = Duration(hours: 48);

  bool get isActive => status == WebTrialStatus.active;
  bool get isExpired => status == WebTrialStatus.expired;
  bool get canLaunch => status != WebTrialStatus.expired;

  /// Time left, floored at zero. Null when no window applies (owner, or unstarted).
  Duration? remaining([DateTime? now]) {
    final end = expiresAt;
    if (end == null) return null;
    final left = end.difference(now ?? DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Coarse countdown for a button label — `41h left`, `35m left`.
  ///
  /// Deliberately never shows seconds: the page does not tick, so a precise
  /// figure would be a stale one.
  String? get remainingLabel {
    final left = remaining();
    if (left == null || left == Duration.zero) return null;
    if (left.inHours >= 1) return '${left.inHours}h left';
    return '${left.inMinutes.clamp(1, 59)}m left';
  }

  /// Builds trial state from the stored document.
  ///
  /// Expiry is decided from the timestamps rather than from a stored flag, so
  /// a window that lapses while the page is open reads as expired without the
  /// backend having to write anything.
  factory WebTrial.fromMap(Map<String, dynamic>? map, {DateTime? now}) {
    if (map == null) return const WebTrial.notStarted();
    final startedAt = (map['startedAt'] as Timestamp?)?.toDate();
    if (startedAt == null) return const WebTrial.notStarted();
    final expiresAt = (map['expiresAt'] as Timestamp?)?.toDate() ?? startedAt.add(window);
    final revoked = map['revoked'] as bool? ?? false;
    final elapsed = !(now ?? DateTime.now()).isBefore(expiresAt);
    return WebTrial(
      status: revoked || elapsed ? WebTrialStatus.expired : WebTrialStatus.active,
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
  }
}

/// What the backend said when a launch was requested.
class WebTrialLaunch {
  const WebTrialLaunch({required this.status, this.launchUrl, this.expiresAt});

  final WebTrialStatus status;

  /// The web-app URL with a signed access token attached. Null when refused.
  final String? launchUrl;
  final DateTime? expiresAt;

  bool get granted => launchUrl != null && launchUrl!.isNotEmpty;
}

/// A completed (or attempted) product purchase. Written only by the webhook.
class ProductOrder {
  const ProductOrder({
    required this.checkoutSessionId,
    required this.uid,
    required this.productKey,
    required this.status,
    this.customerEmail,
    this.originalAmount,
    this.amountPaid,
    this.amountDiscount,
    this.currency,
    this.promotionCode,
    this.percentOff,
    this.paymentIntentId,
    this.paymentStatus,
    this.purchasedAt,
    this.isFreeRedemption = false,
  });

  final String checkoutSessionId;
  final String uid;
  final String productKey;
  final String status;
  final String? customerEmail;
  final int? originalAmount;
  final int? amountPaid;
  final int? amountDiscount;
  final String? currency;
  final String? promotionCode;
  final num? percentOff;
  final String? paymentIntentId;
  final String? paymentStatus;
  final DateTime? purchasedAt;
  final bool isFreeRedemption;

  bool get isCompleted => status == 'completed';

  factory ProductOrder.fromMap(String id, Map<String, dynamic> map) {
    return ProductOrder(
      checkoutSessionId: (map['checkoutSessionId'] as String?) ?? id,
      uid: (map['uid'] as String?) ?? '',
      productKey: (map['productKey'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'unknown',
      customerEmail: map['customerEmail'] as String?,
      originalAmount: (map['originalAmount'] as num?)?.toInt(),
      amountPaid: (map['amountPaid'] as num?)?.toInt(),
      amountDiscount: (map['amountDiscount'] as num?)?.toInt(),
      currency: map['currency'] as String?,
      promotionCode: map['promotionCode'] as String?,
      percentOff: map['percentOff'] as num?,
      paymentIntentId: map['paymentIntentId'] as String?,
      paymentStatus: map['paymentStatus'] as String?,
      purchasedAt: (map['purchasedAt'] as Timestamp?)?.toDate(),
      isFreeRedemption: map['isFreeRedemption'] as bool? ?? false,
    );
  }

  static String formatMinor(int? minor, String? currency) {
    if (minor == null) return '—';
    final code = (currency ?? 'usd').toUpperCase();
    final symbol = switch (code) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      _ => '',
    };
    final amount = (minor / 100).toStringAsFixed(2);
    return symbol.isEmpty ? '$amount $code' : '$symbol$amount';
  }
}

/// Full release record. Admin-only — it carries the private storage path.
class ReleaseRecord {
  const ReleaseRecord({
    required this.id,
    required this.version,
    required this.platform,
    required this.storagePath,
    required this.originalFileName,
    required this.isCurrent,
    this.fileSizeBytes,
    this.releaseNotes,
    this.sha256,
    this.publishedAt,
    this.createdByEmail,
  });

  final String id;
  final String version;
  final String platform;
  final String storagePath;
  final String originalFileName;
  final bool isCurrent;
  final int? fileSizeBytes;
  final String? releaseNotes;
  final String? sha256;
  final DateTime? publishedAt;
  final String? createdByEmail;

  String? get formattedSize => ReleaseSummary(
        releaseId: id,
        version: version,
        fileSizeBytes: fileSizeBytes,
      ).formattedSize;

  factory ReleaseRecord.fromMap(String id, Map<String, dynamic> map) {
    return ReleaseRecord(
      id: id,
      version: (map['version'] as String?) ?? '',
      platform: (map['platform'] as String?) ?? 'windows',
      storagePath: (map['storagePath'] as String?) ?? '',
      originalFileName: (map['originalFileName'] as String?) ?? '',
      isCurrent: map['isCurrent'] as bool? ?? false,
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt(),
      releaseNotes: map['releaseNotes'] as String?,
      sha256: map['sha256'] as String?,
      publishedAt: (map['publishedAt'] as Timestamp?)?.toDate(),
      createdByEmail: map['createdByEmail'] as String?,
    );
  }
}
