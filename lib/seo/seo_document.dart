import 'package:four_ideas/seo/seo_metadata.dart';

import 'seo_document_stub.dart'
    if (dart.library.html) 'seo_document_web.dart' as impl;

/// Updates `<title>`, meta description, Open Graph, Twitter card, and canonical on Flutter Web.
void applySeoDocument(SeoMetadata meta, {required String canonicalPath}) =>
    impl.applySeoDocument(meta, canonicalPath: canonicalPath);
