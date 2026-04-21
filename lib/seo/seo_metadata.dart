/// Route-level SEO: titles and meta descriptions tuned for US clients, Flutter + Firebase,
/// product design, MVP delivery, and Richmond / Virginia local relevance where appropriate.
class SeoMetadata {
  const SeoMetadata({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  /// Max ~60 chars for titles; ~150–160 for descriptions (Google often shows ~155).
  static String clipDescription(String s, [int max = 158]) {
    if (s.length <= max) return s;
    final t = s.substring(0, max - 1).trimRight();
    final cut = t.lastIndexOf(' ');
    if (cut > 80) return '${t.substring(0, cut)}…';
    return '$t…';
  }
}
