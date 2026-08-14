import 'package:flutter_test/flutter_test.dart';
import 'package:four_ideas/features/commerce/presentation/widgets/four_icad_actions.dart';

/// Tests for the purchase-state decision shown in the 4iCAD UI.
///
/// This layer is a courtesy, not the control — the backend enforces both rules
/// from the verified ID token. These tests exist so the UI never *promises*
/// something the server would refuse, and never blocks something the server
/// would allow.
void main() {
  group('signed out', () {
    test('is asked to sign in, whatever else is true', () {
      expect(
        resolvePurchaseAction(signedIn: false, emailVerified: false, owns: false),
        PurchaseAction.signInToBuy,
      );
      expect(
        resolvePurchaseAction(signedIn: false, emailVerified: true, owns: false),
        PurchaseAction.signInToBuy,
      );
      // A stale ownership flag must not leak a download action to a signed-out
      // visitor; the backend would refuse it anyway.
      expect(
        resolvePurchaseAction(signedIn: false, emailVerified: true, owns: true),
        PurchaseAction.signInToBuy,
      );
    });
  });

  group('signed in, does not own it', () {
    test('unverified email is blocked from buying', () {
      expect(
        resolvePurchaseAction(signedIn: true, emailVerified: false, owns: false),
        PurchaseAction.verifyEmail,
      );
    });

    test('verified email may buy', () {
      expect(
        resolvePurchaseAction(signedIn: true, emailVerified: true, owns: false),
        PurchaseAction.buy,
      );
    });

    test('never offers Buy to an unverified account', () {
      // Mirrors requireVerifiedAuth on createCheckoutSession.
      final action =
          resolvePurchaseAction(signedIn: true, emailVerified: false, owns: false);
      expect(action, isNot(PurchaseAction.buy));
    });
  });

  group('signed in and already owns it', () {
    test('verified owner downloads', () {
      expect(
        resolvePurchaseAction(signedIn: true, emailVerified: true, owns: true),
        PurchaseAction.download,
      );
    });

    test('an owner keeps their download even if the address is unverified', () {
      // Entitlement, not verification, is the authority after purchase. This
      // mirrors getDownloadUrl, which deliberately uses requireAuth only, so a
      // paying customer who later changes to an unverified address is not
      // stranded.
      expect(
        resolvePurchaseAction(signedIn: true, emailVerified: false, owns: true),
        PurchaseAction.download,
      );
    });

    test('ownership is checked before verification', () {
      final owner =
          resolvePurchaseAction(signedIn: true, emailVerified: false, owns: true);
      final nonOwner =
          resolvePurchaseAction(signedIn: true, emailVerified: false, owns: false);
      expect(owner, PurchaseAction.download);
      expect(nonOwner, PurchaseAction.verifyEmail);
    });
  });

  group('every combination resolves to exactly one action', () {
    test('all eight input combinations are covered', () {
      final seen = <PurchaseAction>{};
      for (final signedIn in [true, false]) {
        for (final verified in [true, false]) {
          for (final owns in [true, false]) {
            final action = resolvePurchaseAction(
              signedIn: signedIn,
              emailVerified: verified,
              owns: owns,
            );
            expect(action, isA<PurchaseAction>());
            seen.add(action);
          }
        }
      }
      // All four states are reachable — none is dead code.
      expect(seen, containsAll(PurchaseAction.values));
    });
  });
}
