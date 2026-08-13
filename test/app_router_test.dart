import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:four_ideas/app_router.dart';

/// Route configuration tests.
///
/// These replace the stock counter-app smoke test that shipped with the Flutter
/// template and could never pass against this app.
///
/// The point of these assertions is the deep-link contract: the 4iCAD commerce
/// routes must be addressable by URL alone, because they are pasted into
/// browsers, emailed, put on QR codes and returned to by Stripe. A route that
/// only works when navigated to from inside the app would fail all of those.
List<String> _declaredPaths(GoRouter router) {
  final paths = <String>[];
  void walk(Iterable<RouteBase> routes) {
    for (final route in routes) {
      if (route is GoRoute) paths.add(route.path);
      walk(route.routes);
    }
  }

  walk(router.configuration.routes);
  return paths;
}

void main() {
  group('4iCAD commerce routes', () {
    test('the product and success routes are declared', () {
      final paths = _declaredPaths(createAppRouter());
      expect(paths, contains('/4icad'));
      expect(paths, contains('/4icad/success'));
    });

    test('no /4icad/buy route exists — buying is an action, not a page', () {
      final paths = _declaredPaths(createAppRouter());
      expect(paths, isNot(contains('/4icad/buy')));
    });

    test('admin order detail is addressed by a stable path parameter', () {
      final paths = _declaredPaths(createAppRouter());
      // A path parameter means the page can be reloaded and linked to,
      // unlike the older extra-only admin detail routes.
      expect(paths, contains('/admin/4icad/orders/:sessionId'));
      expect(paths, contains('/admin/4icad/orders'));
      expect(paths, contains('/admin/4icad/releases'));
      expect(paths, contains('/admin/4icad/promotions'));
    });

    test('AppRoutes constants match the declared paths', () {
      expect(AppRoutes.fourICad, '/4icad');
      expect(AppRoutes.fourICadSuccess, '/4icad/success');
      expect(AppRoutes.adminProductOrderPath('cs_test_123'),
          '/admin/4icad/orders/cs_test_123');
    });

    test('the product route is a short top-level slug, not a nested namespace', () {
      // This URL goes on ads, QR codes and invoices, so its shape is a
      // deliberate decision worth pinning.
      expect(AppRoutes.fourICad.split('/').where((s) => s.isNotEmpty).length, 1);
    });
  });

  group('existing routes are preserved', () {
    test('the public site routes still exist', () {
      final paths = _declaredPaths(createAppRouter());
      for (final path in [
        '/',
        '/portfolio',
        '/portfolio/case-study/:id',
        '/services',
        '/about',
        '/contact',
        '/insights',
        '/case-studies',
        '/privacy',
        '/privacy/:slug',
        '/login',
        '/signup',
        '/profile',
        '/admin/orders',
        '/admin/privacy',
      ]) {
        expect(paths, contains(path), reason: 'route $path went missing');
      }
    });

    test('every declared path is unique', () {
      final paths = _declaredPaths(createAppRouter());
      expect(paths.toSet().length, paths.length,
          reason: 'a duplicate route path would shadow another page');
    });

    test('the router starts at home', () {
      expect(createAppRouter().configuration.routes, isNotEmpty);
      expect(AppRoutes.home, '/');
    });
  });
}
