/// A privacy policy for one of the 4ideas apps, managed by admins from the app
/// (stored in Firestore) so new policies can be added without code changes.
///
/// [content] is Markdown text (the admin pastes or uploads a `.md` file); the
/// public screen renders it with `flutter_markdown`.
class PrivacyPolicy {
  /// Logical slug used in the public URL, e.g. `4icad`.
  final String slug;

  /// App this policy belongs to, e.g. `4iCAD`.
  final String appName;

  /// Human-readable effective date, e.g. `August 2, 2026`.
  final String effectiveDate;

  /// Human-readable last-updated date, e.g. `August 2, 2026`.
  final String lastUpdated;

  /// Full policy body in Markdown.
  final String content;

  const PrivacyPolicy({
    required this.slug,
    required this.appName,
    required this.content,
    this.effectiveDate = '',
    this.lastUpdated = '',
  });

  factory PrivacyPolicy.fromMap(String slug, Map<String, dynamic> data) {
    return PrivacyPolicy(
      slug: (data['slug'] as String?)?.trim().isNotEmpty == true
          ? (data['slug'] as String).trim()
          : slug,
      appName: (data['appName'] as String?)?.trim() ?? '',
      effectiveDate: (data['effectiveDate'] as String?)?.trim() ?? '',
      lastUpdated: (data['lastUpdated'] as String?)?.trim() ?? '',
      content: (data['content'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'slug': slug,
        'appName': appName,
        'effectiveDate': effectiveDate,
        'lastUpdated': lastUpdated,
        'content': content,
      };

  PrivacyPolicy copyWith({
    String? slug,
    String? appName,
    String? effectiveDate,
    String? lastUpdated,
    String? content,
  }) {
    return PrivacyPolicy(
      slug: slug ?? this.slug,
      appName: appName ?? this.appName,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      content: content ?? this.content,
    );
  }

  /// Slugify a name into a URL-safe id (mirrors the portfolio app id rule).
  static String slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
