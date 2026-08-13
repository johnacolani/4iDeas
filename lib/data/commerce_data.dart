import 'package:cloud_firestore/cloud_firestore.dart';

/// The single product this version of the site sells.
const String kFourICadWindowsKey = '4icad_windows';

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
