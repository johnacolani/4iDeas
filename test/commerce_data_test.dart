import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:four_ideas/data/commerce_data.dart';

/// Unit tests for the commerce value types.
///
/// These cover the pure parsing and formatting logic that the product page and
/// admin screens depend on. Anything that decides money or access lives in
/// Cloud Functions and is covered by the rules tests instead.
void main() {
  group('ReleaseSummary.fromMap', () {
    test('returns null when there is no current release', () {
      expect(ReleaseSummary.fromMap(null), isNull);
    });

    test('returns null when the version or id is missing', () {
      expect(ReleaseSummary.fromMap({'releaseId': 'r1'}), isNull);
      expect(ReleaseSummary.fromMap({'version': '1.0.8'}), isNull);
      expect(
          ReleaseSummary.fromMap({'releaseId': 'r1', 'version': '  '}), isNull);
    });

    test('parses a complete summary', () {
      final summary = ReleaseSummary.fromMap({
        'releaseId': 'r1',
        'version': '1.0.8',
        'fileSizeBytes': 88301567,
        'sha256': 'abc123',
        'releaseNotes': 'Faster snapping.',
      });
      expect(summary, isNotNull);
      expect(summary!.version, '1.0.8');
      expect(summary.sha256, 'abc123');
      expect(summary.releaseNotes, 'Faster snapping.');
    });
  });

  group('ReleaseSummary.formattedSize', () {
    ReleaseSummary sized(int? bytes) =>
        ReleaseSummary(releaseId: 'r', version: '1.0.0', fileSizeBytes: bytes);

    test('is null when the size is unknown or nonsensical', () {
      expect(sized(null).formattedSize, isNull);
      expect(sized(0).formattedSize, isNull);
      expect(sized(-5).formattedSize, isNull);
    });

    test('scales to a sensible unit', () {
      expect(sized(512).formattedSize, '512 B');
      expect(sized(2048).formattedSize, '2.0 KB');
      expect(sized(88301567).formattedSize, '84.2 MB');
    });

    test('drops the decimal once the number is large', () {
      expect(sized(120 * 1024 * 1024).formattedSize, '120 MB');
    });
  });

  group('CommerceProduct', () {
    test('falls back truthfully when no product document exists', () {
      final product = CommerceProduct.fourICadFallback();
      expect(product.productKey, kFourICadWindowsKey);
      expect(product.displayName, '4iCAD for Windows');
      expect(product.webAppUrl, 'https://icad-75d53.web.app');
      expect(product.features, isNotEmpty);
      // The retail price is never invented in the client.
      expect(product.hasPrice, isFalse);
      expect(product.formattedPrice, isNull);
      expect(product.currentRelease, isNull);
    });

    test('formats a price only when one is configured', () {
      const withPrice = CommerceProduct(
        productKey: kFourICadWindowsKey,
        displayName: '4iCAD for Windows',
        priceAmountMinor: 4900,
        priceCurrency: 'usd',
      );
      expect(withPrice.hasPrice, isTrue);
      expect(withPrice.formattedPrice, r'$49.00');

      const zero = CommerceProduct(
        productKey: kFourICadWindowsKey,
        displayName: '4iCAD for Windows',
        priceAmountMinor: 0,
      );
      expect(zero.hasPrice, isFalse);
      expect(zero.formattedPrice, isNull);
    });

    test('handles non-symbol currencies without inventing a symbol', () {
      const product = CommerceProduct(
        productKey: kFourICadWindowsKey,
        displayName: '4iCAD',
        priceAmountMinor: 12345,
        priceCurrency: 'sek',
      );
      expect(product.formattedPrice, '123.45 SEK');
    });

    test('parses a Firestore document including the current release', () {
      final product = CommerceProduct.fromMap(kFourICadWindowsKey, {
        'displayName': '4iCAD for Windows',
        'active': true,
        'priceAmountMinor': 4900,
        'priceCurrency': 'usd',
        'webAppUrl': 'https://icad-75d53.web.app',
        'features': ['DXF support', 'Cloud files', 42],
        'windowsRequirements': ['Windows 10 or 11 (64-bit)'],
        'currentRelease': {'releaseId': 'r1', 'version': '1.0.8'},
      });
      expect(product.formattedPrice, r'$49.00');
      // Non-string entries are dropped rather than crashing the page.
      expect(product.features, ['DXF support', 'Cloud files']);
      expect(product.currentRelease?.version, '1.0.8');
    });

    test('uses a sensible name when the document omits one', () {
      final product =
          CommerceProduct.fromMap(kFourICadWindowsKey, {'displayName': '  '});
      expect(product.displayName, '4iCAD for Windows');
    });
  });

  group('platform grid', () {
    FourICadPlatform byLabel(String label) =>
        kFourICadPlatforms.firstWhere((p) => p.label == label);

    test('covers every platform the hero artwork promises', () {
      expect(
        kFourICadPlatforms.map((p) => p.label),
        containsAll(['Windows', 'Web', 'iOS', 'Android', 'macOS', 'Linux']),
      );
    });

    test('every independently controlled platform carries its product key', () {
      expect(byLabel('Windows').key, kFourICadWindowsKey);
      expect(byLabel('Web').key, kFourICadWebKey);
      expect(byLabel('iOS').key, kFourICadIosKey);
      expect(byLabel('Android').key, kFourICadAndroidKey);
      expect(byLabel('macOS').key, kFourICadMacosKey);
      expect(byLabel('Linux').key, kFourICadLinuxKey);
      for (final label in ['iOS', 'Android', 'macOS', 'Linux']) {
        expect(byLabel(label).availability, PlatformAvailability.comingSoon);
        expect(byLabel(label).isSellable, isFalse);
      }
    });

    test('a platform with no override keeps its declared default', () {
      expect(byLabel('iOS').applyOverride(null).availability,
          PlatformAvailability.comingSoon);
      expect(byLabel('Windows').applyOverride(const {}).availability,
          PlatformAvailability.buy);
    });

    test('a product document alone never promotes a platform', () {
      // The Stripe Price lives in server-only config the browser cannot read,
      // so an existing product doc must not be taken as "ready to sell".
      final ios = byLabel('iOS').applyOverride(const {
        'displayName': '4iCAD for iOS',
        'active': true,
        'priceAmountMinor': 4900,
      });
      expect(ios.availability, PlatformAvailability.comingSoon);
    });

    test('an explicit status puts a platform on sale without a new build', () {
      final macos =
          byLabel('macOS').applyOverride(const {'platformStatus': 'buy'});
      expect(macos.availability, PlatformAvailability.buy);
      // Still not sellable: store products never become Stripe buy buttons.
      expect(macos.isSellable, isFalse);
    });

    test('a store link opens the store, even with no status set', () {
      final android = byLabel('Android').applyOverride(const {
        'storeUrl':
            'https://play.google.com/store/apps/details?id=com.fourideas.icad',
      });
      expect(android.availability, PlatformAvailability.store);
      expect(android.storeUrl, contains('play.google.com'));
    });

    test('all Apple and Google platforms can independently open their store',
        () {
      final listings = {
        'iOS': 'https://apps.apple.com/app/id123456789',
        'Android':
            'https://play.google.com/store/apps/details?id=com.fourideas.icad',
        'macOS': 'https://apps.apple.com/app/id987654321',
      };

      for (final entry in listings.entries) {
        final platform = byLabel(entry.key).applyOverride({
          'platformStatus': 'store',
          'storeUrl': entry.value,
        });
        expect(platform.availability, PlatformAvailability.store,
            reason: entry.key);
        expect(platform.storeUrl, entry.value, reason: entry.key);
        expect(platform.isSellable, isFalse, reason: entry.key);
      }
    });

    test('an empty store link is ignored rather than opening nothing', () {
      final ios = byLabel('iOS').applyOverride(const {'storeUrl': '   '});
      expect(ios.availability, PlatformAvailability.comingSoon);
      expect(ios.storeUrl, isNull);
    });

    test('every platform carries a logo, and the file is registered', () {
      // The tile falls back to a glyph if an asset is missing, so a typo here
      // would degrade silently rather than fail — hence asserting the paths.
      for (final platform in kFourICadPlatforms) {
        expect(platform.logoAsset, isNotNull,
            reason: '${platform.label} has no logo');
        expect(platform.logoAsset, startsWith('assets/icons/'));
      }
    });

    test('an override keeps the logo it came with', () {
      final android =
          byLabel('Android').applyOverride(const {'platformStatus': 'store'});
      expect(android.logoAsset, byLabel('Android').logoAsset);
    });

    test('a platform can be pushed back to coming soon', () {
      final windows =
          byLabel('Windows').applyOverride(const {'platformStatus': 'soon'});
      expect(windows.availability, PlatformAvailability.comingSoon);
      expect(windows.isSellable, isFalse);
    });
  });

  group('WebTrial', () {
    // The document is written only by the backend; these cover how the page
    // reads a window it cannot influence.
    Map<String, dynamic> doc(DateTime startedAt,
            {DateTime? expiresAt, bool? revoked}) =>
        {
          'startedAt': Timestamp.fromDate(startedAt),
          if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt),
          if (revoked != null) 'revoked': revoked,
        };

    test('is not started when no document exists yet', () {
      expect(WebTrial.fromMap(null).status, WebTrialStatus.notStarted);
      expect(const WebTrial.notStarted().canLaunch, isTrue);
    });

    test('treats a document without a start time as not started', () {
      expect(WebTrial.fromMap({'uid': 'u1'}).status, WebTrialStatus.notStarted);
    });

    test('is active inside the 48-hour window', () {
      final now = DateTime(2026, 8, 17, 12);
      final trial = WebTrial.fromMap(
        doc(now.subtract(const Duration(hours: 7))),
        now: now,
      );
      expect(trial.status, WebTrialStatus.active);
      expect(trial.remaining(now), const Duration(hours: 41));
    });

    test(
        'expires once the window elapses, without the backend writing anything',
        () {
      final now = DateTime(2026, 8, 17, 12);
      final trial = WebTrial.fromMap(
        doc(now.subtract(const Duration(hours: 49))),
        now: now,
      );
      expect(trial.status, WebTrialStatus.expired);
      expect(trial.canLaunch, isFalse);
      expect(trial.remaining(now), Duration.zero);
    });

    test('expires exactly at the boundary, not a moment after', () {
      final now = DateTime(2026, 8, 17, 12);
      expect(
        WebTrial.fromMap(doc(now.subtract(WebTrial.window)), now: now).status,
        WebTrialStatus.expired,
      );
      expect(
        WebTrial.fromMap(
          doc(now.subtract(WebTrial.window - const Duration(minutes: 1))),
          now: now,
        ).status,
        WebTrialStatus.active,
      );
    });

    test('honours a revoked flag even while the window is open', () {
      final now = DateTime(2026, 8, 17, 12);
      final trial = WebTrial.fromMap(
        doc(now.subtract(const Duration(hours: 1)), revoked: true),
        now: now,
      );
      expect(trial.status, WebTrialStatus.expired);
    });

    test('derives the end from the stored expiry when the backend supplies one',
        () {
      final now = DateTime(2026, 8, 17, 12);
      final trial = WebTrial.fromMap(
        doc(
          now.subtract(const Duration(hours: 40)),
          expiresAt: now.add(const Duration(hours: 2)),
        ),
        now: now,
      );
      expect(trial.status, WebTrialStatus.active);
      expect(trial.remaining(now), const Duration(hours: 2));
    });

    test('labels the countdown coarsely, never in seconds', () {
      final now = DateTime(2026, 8, 17, 12);
      final hours = WebTrial(
        status: WebTrialStatus.active,
        startedAt: now,
        expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 30)),
      );
      expect(hours.remainingLabel, '5h left');

      final minutes = WebTrial(
        status: WebTrialStatus.active,
        startedAt: now,
        expiresAt: DateTime.now().add(const Duration(minutes: 20)),
      );
      expect(minutes.remainingLabel, '20m left');

      const owner = WebTrial.owned();
      expect(owner.remainingLabel, isNull);
      expect(owner.canLaunch, isTrue);
    });
  });

  group('WebTrialLaunch', () {
    test('is granted only when the backend returned a URL', () {
      const granted = WebTrialLaunch(
        status: WebTrialStatus.active,
        launchUrl: 'https://icad-75d53.web.app/?trial=t',
      );
      expect(granted.granted, isTrue);

      const refused = WebTrialLaunch(status: WebTrialStatus.expired);
      expect(refused.granted, isFalse);
      expect(
          const WebTrialLaunch(status: WebTrialStatus.active, launchUrl: '')
              .granted,
          isFalse);
    });
  });

  group('ProductOrder', () {
    test('parses a completed paid order', () {
      final order = ProductOrder.fromMap('cs_1', {
        'uid': 'u1',
        'productKey': kFourICadWindowsKey,
        'status': 'completed',
        'customerEmail': 'buyer@example.com',
        'originalAmount': 4900,
        'amountPaid': 4410,
        'amountDiscount': 490,
        'currency': 'usd',
        'promotionCode': '4ICAD10',
        'percentOff': 10,
        'paymentIntentId': 'pi_1',
        'paymentStatus': 'paid',
      });
      expect(order.isCompleted, isTrue);
      expect(order.isFreeRedemption, isFalse);
      expect(order.promotionCode, '4ICAD10');
    });

    test('treats a fully discounted order as a real order, not a bypass', () {
      final order = ProductOrder.fromMap('cs_free', {
        'uid': 'u1',
        'productKey': kFourICadWindowsKey,
        'status': 'completed',
        'originalAmount': 4900,
        'amountPaid': 0,
        'amountDiscount': 4900,
        'currency': 'usd',
        'promotionCode': '4ICADFREE',
        'percentOff': 100,
        'paymentStatus': 'no_payment_required',
        'isFreeRedemption': true,
        // A 100%-off Checkout has no PaymentIntent, which must not break parsing.
        'paymentIntentId': null,
      });
      expect(order.isCompleted, isTrue);
      expect(order.isFreeRedemption, isTrue);
      expect(order.paymentIntentId, isNull);
      expect(order.percentOff, 100);
    });

    test('survives a sparse document without throwing', () {
      final order = ProductOrder.fromMap('cs_x', {});
      expect(order.checkoutSessionId, 'cs_x');
      expect(order.status, 'unknown');
      expect(order.isCompleted, isFalse);
    });

    test('formats minor amounts, including zero and unknown', () {
      expect(ProductOrder.formatMinor(4900, 'usd'), r'$49.00');
      expect(ProductOrder.formatMinor(0, 'usd'), r'$0.00');
      expect(ProductOrder.formatMinor(null, 'usd'), '—');
      expect(ProductOrder.formatMinor(1500, 'gbp'), '£15.00');
    });
  });

  group('ReleaseRecord', () {
    test('parses an admin release record', () {
      final record = ReleaseRecord.fromMap('rel1', {
        'version': '1.0.8',
        'platform': 'windows',
        'storagePath': 'releases/windows/1.0.8/4iCAD_Setup.exe',
        'originalFileName': '4iCAD_Setup.exe',
        'isCurrent': true,
        'fileSizeBytes': 88301567,
        'sha256': 'abc',
      });
      expect(record.isCurrent, isTrue);
      expect(record.formattedSize, '84.2 MB');
      expect(record.storagePath, startsWith('releases/windows/'));
    });

    test('defaults isCurrent to false when absent', () {
      final record = ReleaseRecord.fromMap('rel2', {'version': '1.0.7'});
      expect(record.isCurrent, isFalse);
      expect(record.formattedSize, isNull);
    });
  });
}
