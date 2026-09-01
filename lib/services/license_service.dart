import 'package:cloud_functions/cloud_functions.dart';

class LicenseDeviceView {
  const LicenseDeviceView({
    required this.installationId,
    required this.platform,
    required this.bucket,
    required this.active,
    this.deviceName,
    this.appVersion,
    this.activatedAt,
    this.lastSeenAt,
    this.deactivatedAt,
  });

  final String installationId;
  final String platform;
  final String bucket;
  final bool active;
  final String? deviceName;
  final String? appVersion;
  final DateTime? activatedAt;
  final DateTime? lastSeenAt;
  final DateTime? deactivatedAt;

  factory LicenseDeviceView.fromMap(Map<String, dynamic> map) {
    DateTime? date(String key) {
      final value = (map[key] as num?)?.toInt();
      return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
    }

    return LicenseDeviceView(
      installationId: map['installationId'] as String? ?? '',
      platform: map['platform'] as String? ?? '',
      bucket: map['bucket'] as String? ?? '',
      active: map['active'] as bool? ?? false,
      deviceName: map['deviceName'] as String?,
      appVersion: map['appVersion'] as String?,
      activatedAt: date('activatedAt'),
      lastSeenAt: date('lastSeenAt'),
      deactivatedAt: date('deactivatedAt'),
    );
  }
}

class LicenseView {
  const LicenseView({
    required this.id,
    required this.plan,
    required this.primaryPlatform,
    required this.status,
    required this.primaryDeviceLimit,
    required this.bonusOtherPlatformLimit,
    required this.totalDeviceLimit,
    required this.activePrimaryDevices,
    required this.activeBonusDevices,
  });

  final String id;
  final String plan;
  final String primaryPlatform;
  final String status;
  final int primaryDeviceLimit;
  final int bonusOtherPlatformLimit;
  final int totalDeviceLimit;
  final int activePrimaryDevices;
  final int activeBonusDevices;

  int get activeTotal => activePrimaryDevices + activeBonusDevices;

  factory LicenseView.fromMap(Map<String, dynamic> map) => LicenseView(
        id: map['id'] as String? ?? '',
        plan: map['plan'] as String? ?? '',
        primaryPlatform: map['primaryPlatform'] as String? ?? '',
        status: map['status'] as String? ?? '',
        primaryDeviceLimit: (map['primaryDeviceLimit'] as num?)?.toInt() ?? 0,
        bonusOtherPlatformLimit:
            (map['bonusOtherPlatformLimit'] as num?)?.toInt() ?? 0,
        totalDeviceLimit: (map['totalDeviceLimit'] as num?)?.toInt() ?? 0,
        activePrimaryDevices:
            (map['activePrimaryDevices'] as num?)?.toInt() ?? 0,
        activeBonusDevices: (map['activeBonusDevices'] as num?)?.toInt() ?? 0,
      );
}

class MyLicenseView {
  const MyLicenseView({this.license, this.devices = const []});

  final LicenseView? license;
  final List<LicenseDeviceView> devices;
}

/// Client wrapper for the device-license backend. Pricing and seat decisions
/// remain server-side; this class only sends the selected plan/platform and
/// renders the verified answer.
class LicenseService {
  LicenseService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<String> createCheckoutSession({
    required String plan,
    required String primaryPlatform,
  }) async {
    final result = await _functions
        .httpsCallable('createLicenseCheckoutSession')
        .call<Map<String, dynamic>>({
      'plan': plan,
      'primaryPlatform': primaryPlatform,
    });
    final url = result.data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw StateError('Stripe did not return a checkout URL.');
    }
    return url;
  }

  Future<MyLicenseView> getMyLicense() async {
    final result = await _functions
        .httpsCallable('getMyLicense')
        .call<Map<String, dynamic>>();
    final rawLicense = result.data['license'];
    final rawDevices = (result.data['devices'] as List?) ?? const [];
    return MyLicenseView(
      license: rawLicense is Map
          ? LicenseView.fromMap(rawLicense.cast<String, dynamic>())
          : null,
      devices: rawDevices
          .whereType<Map>()
          .map((m) => LicenseDeviceView.fromMap(m.cast<String, dynamic>()))
          .toList(),
    );
  }

  Future<bool> deactivateDevice(String installationId) async {
    final result = await _functions
        .httpsCallable('deactivateMyDevice')
        .call<Map<String, dynamic>>({'installationId': installationId});
    return result.data['deactivated'] as bool? ?? false;
  }
}
