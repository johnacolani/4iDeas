import 'package:cloud_functions/cloud_functions.dart';

class AdminLicenseView {
  const AdminLicenseView({
    required this.id,
    required this.ownerUid,
    required this.plan,
    required this.primaryPlatform,
    required this.status,
    required this.primaryDeviceLimit,
    required this.bonusOtherPlatformLimit,
    required this.totalDeviceLimit,
    required this.activePrimaryDevices,
    required this.activeBonusDevices,
    this.ownerEmail,
    this.source,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerUid;
  final String? ownerEmail;
  final String plan;
  final String primaryPlatform;
  final String status;
  final String? source;
  final String? orderId;
  final int primaryDeviceLimit;
  final int bonusOtherPlatformLimit;
  final int totalDeviceLimit;
  final int activePrimaryDevices;
  final int activeBonusDevices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get activeTotal => activePrimaryDevices + activeBonusDevices;

  factory AdminLicenseView.fromMap(Map<String, dynamic> map) {
    DateTime? date(String key) {
      final value = (map[key] as num?)?.toInt();
      return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
    }

    return AdminLicenseView(
      id: map['id'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      ownerEmail: map['ownerEmail'] as String?,
      plan: map['plan'] as String? ?? '',
      primaryPlatform: map['primaryPlatform'] as String? ?? '',
      status: map['status'] as String? ?? '',
      source: map['source'] as String?,
      orderId: map['orderId'] as String?,
      primaryDeviceLimit: (map['primaryDeviceLimit'] as num?)?.toInt() ?? 0,
      bonusOtherPlatformLimit:
          (map['bonusOtherPlatformLimit'] as num?)?.toInt() ?? 0,
      totalDeviceLimit: (map['totalDeviceLimit'] as num?)?.toInt() ?? 0,
      activePrimaryDevices:
          (map['activePrimaryDevices'] as num?)?.toInt() ?? 0,
      activeBonusDevices: (map['activeBonusDevices'] as num?)?.toInt() ?? 0,
      createdAt: date('createdAt'),
      updatedAt: date('updatedAt'),
    );
  }
}

class LicenseAdminService {
  LicenseAdminService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<List<AdminLicenseView>> listLicenses() async {
    final result = await _functions
        .httpsCallable('listLicenses')
        .call<Map<String, dynamic>>();
    final rows = (result.data['licenses'] as List?) ?? const [];
    return rows
        .whereType<Map>()
        .map((m) => AdminLicenseView.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  Future<String> grantComplimentaryLicense({
    required String email,
    required String plan,
    required String primaryPlatform,
  }) async {
    final result = await _functions
        .httpsCallable('grantComplimentaryLicense')
        .call<Map<String, dynamic>>({
      'email': email,
      'plan': plan,
      'primaryPlatform': primaryPlatform,
    });
    return result.data['licenseId'] as String? ?? '';
  }

  Future<void> setLicenseStatus({
    required String ownerUid,
    required String status,
  }) async {
    await _functions.httpsCallable('setLicenseStatus').call<void>({
      'ownerUid': ownerUid,
      'status': status,
    });
  }

  Future<bool> deactivateDevice({
    required String ownerUid,
    required String installationId,
  }) async {
    final result = await _functions
        .httpsCallable('adminDeactivateDevice')
        .call<Map<String, dynamic>>({
      'ownerUid': ownerUid,
      'installationId': installationId,
    });
    return result.data['deactivated'] as bool? ?? false;
  }
}
