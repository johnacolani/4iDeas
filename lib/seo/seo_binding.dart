import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:four_ideas/seo/seo_document.dart';
import 'package:four_ideas/seo/seo_resolver.dart';
import 'package:go_router/go_router.dart';

/// Syncs `<title>`, meta description, Open Graph, Twitter card, and canonical on Flutter Web
/// after each navigation. Non-web builds no-op.
void attachSeoToRouter(GoRouter router) {
  if (!kIsWeb) return;

  void sync() {
    final uri = router.routeInformationProvider.value.uri;
    final resolved = resolveSeoForUri(uri);
    applySeoDocument(resolved.$1, canonicalPath: resolved.$2);
  }

  router.routerDelegate.addListener(sync);
  SchedulerBinding.instance.addPostFrameCallback((_) => sync());
}
