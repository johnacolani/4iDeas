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
      expect(ReleaseSummary.fromMap({'releaseId': 'r1', 'version': '  '}), isNull);
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
      final product = CommerceProduct.fromMap(kFourICadWindowsKey, {'displayName': '  '});
      expect(product.displayName, '4iCAD for Windows');
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
