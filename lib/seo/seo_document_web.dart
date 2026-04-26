// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Prefer conditional import: this file is only compiled for `dart.library.html` web targets.
import 'dart:html' as html;

import 'package:four_ideas/seo/seo_metadata.dart';

/// Public site origin — keep in sync with [web/index.html] Open Graph URLs.
const String kSiteOrigin = 'https://4ideasapp.com';
const String kDefaultSocialImage = 'https://4ideasapp.com/icons/icon-512.png';

void applySeoDocument(SeoMetadata meta, {required String canonicalPath}) {
  final path = canonicalPath.startsWith('/') ? canonicalPath : '/$canonicalPath';
  final canonical = '$kSiteOrigin$path';
  final socialImage = meta.ogImage ?? meta.twitterImage ?? kDefaultSocialImage;

  html.document.title = meta.title;

  _upsertMetaName('title', meta.title);
  _upsertMetaName('description', meta.description);
  _upsertMetaName('robots', meta.robots);

  _setOg('type', meta.ogType);
  _setOg('title', meta.title);
  _setOg('description', meta.description);
  _setOg('url', canonical);
  _setOg('image', socialImage);

  _upsertMetaName('twitter:card', meta.twitterCard);
  _upsertMetaName('twitter:url', canonical);
  _upsertMetaName('twitter:title', meta.title);
  _upsertMetaName('twitter:description', SeoMetadata.clipDescription(meta.description, 200));
  _upsertMetaName('twitter:image', socialImage);

  html.LinkElement? link =
      html.document.querySelector('link[rel="canonical"]') as html.LinkElement?;
  link ??= html.LinkElement()..setAttribute('rel', 'canonical');
  link.setAttribute('href', canonical);
  if (link.parent == null) html.document.head?.append(link);
}

void _upsertMetaName(String name, String content) {
  html.MetaElement? el =
      html.document.querySelector('meta[name="$name"]') as html.MetaElement?;
  el ??= html.MetaElement()..setAttribute('name', name);
  el.setAttribute('content', content);
  if (el.parent == null) html.document.head?.append(el);
}

void _setOg(String property, String content) {
  html.MetaElement? el =
      html.document.querySelector('meta[property="og:$property"]') as html.MetaElement?;
  el ??= html.MetaElement()..setAttribute('property', 'og:$property');
  el.setAttribute('content', content);
  if (el.parent == null) html.document.head?.append(el);
}
