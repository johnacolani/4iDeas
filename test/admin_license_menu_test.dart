import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared admin navigation exposes 4iCAD licenses', () {
    final source =
        File('lib/widgets/home_mobile_nav_menu_button.dart').readAsStringSync();

    expect(source, contains("label: '4iCAD licenses'"));
    expect(source, contains('route: AppRoutes.adminLicenses'));
    expect(source, contains('icon: Icons.card_membership_outlined'));
  });
}
