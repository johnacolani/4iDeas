class ContentArticleSection {
  const ContentArticleSection({
    required this.heading,
    required this.paragraphs,
  });

  final String heading;
  final List<String> paragraphs;
}

class ContentArticle {
  const ContentArticle({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.topic,
    required this.readTimeMinutes,
    required this.publishedAtIso,
    required this.sections,
    this.relatedSlugs = const <String>[],
  });

  final String slug;
  final String title;
  final String excerpt;
  final String topic;
  final int readTimeMinutes;
  final String publishedAtIso;
  final List<ContentArticleSection> sections;
  final List<String> relatedSlugs;
}

abstract final class ContentArticlesData {
  static const List<ContentArticle> articles = <ContentArticle>[
    ContentArticle(
      slug: 'flutter-mvp-planning-that-reduces-rework',
      title: 'Flutter MVP Planning That Reduces Rework',
      excerpt:
          'A practical framework for cutting MVP scope without cutting product credibility, from discovery through first release.',
      topic: 'MVP planning',
      readTimeMinutes: 7,
      publishedAtIso: '2026-04-20',
      sections: <ContentArticleSection>[
        ContentArticleSection(
          heading: 'Start with decision-risk, not feature lists',
          paragraphs: <String>[
            'Most MVPs fail at scope because they are planned around ideas instead of decisions. Before defining screens, identify the few product decisions that matter most: who this is for, what core action proves value, and what must be true after launch to keep investing.',
            'When those decisions are clear, Flutter becomes an execution advantage. You can ship iOS, Android, and web quickly, but only if the product shape is disciplined.',
          ],
        ),
        ContentArticleSection(
          heading: 'Use one vertical slice to test credibility',
          paragraphs: <String>[
            'A credible MVP is usually one complete workflow, not many partial workflows. Build one journey end-to-end with usable UI, basic analytics, and realistic backend behavior.',
            'That vertical slice gives you better feedback from founders, users, and investors than five half-finished areas that never connect.',
          ],
        ),
        ContentArticleSection(
          heading: 'Preserve quality where trust is won',
          paragraphs: <String>[
            'You can simplify many areas, but not onboarding clarity, core task performance, and error handling. Those are trust moments. If they feel weak, decision makers assume everything else is weak too.',
            'A tighter MVP is not a smaller app by default; it is an app where quality is concentrated in the few flows that prove value.',
          ],
        ),
      ],
      relatedSlugs: <String>[
        'firebase-architecture-for-early-stage-products',
        'from-product-design-to-flutter-delivery',
      ],
    ),
    ContentArticle(
      slug: 'from-product-design-to-flutter-delivery',
      title: 'From Product Design to Flutter Delivery Without Drift',
      excerpt:
          'How to keep UX intent and production implementation aligned when one team handles design and engineering.',
      topic: 'Product design',
      readTimeMinutes: 6,
      publishedAtIso: '2026-04-17',
      sections: <ContentArticleSection>[
        ContentArticleSection(
          heading: 'Design files are not product decisions',
          paragraphs: <String>[
            'Founders often review polished screens and assume implementation risk is mostly removed. In reality, many critical choices are unresolved: state behavior, empty states, errors, and role-based variance.',
            'Good product delivery translates intent into implementation constraints early, so design and engineering are solving the same problem.',
          ],
        ),
        ContentArticleSection(
          heading: 'Define interaction contracts before component libraries',
          paragraphs: <String>[
            'A reusable design system helps, but reuse without interaction contracts causes drift. Define what each component must do across states before scaling the component set.',
            'Flutter teams move faster when those interaction contracts are explicit, because edge cases stop being ad-hoc design debt.',
          ],
        ),
        ContentArticleSection(
          heading: 'Use milestone demos as alignment checkpoints',
          paragraphs: <String>[
            'Short milestone demos reveal mismatch faster than static handoff artifacts. They align stakeholders on behavior, not just visuals.',
            'This rhythm also improves trust with business teams: they see progress in product terms, not only engineering terms.',
          ],
        ),
      ],
      relatedSlugs: <String>[
        'flutter-mvp-planning-that-reduces-rework',
        'ai-assisted-features-with-product-governance',
      ],
    ),
    ContentArticle(
      slug: 'firebase-architecture-for-early-stage-products',
      title: 'Firebase Architecture for Early-Stage Products',
      excerpt:
          'Where Firebase accelerates MVP delivery, where teams should be careful, and how to avoid expensive rewrites.',
      topic: 'Flutter + Firebase',
      readTimeMinutes: 8,
      publishedAtIso: '2026-04-14',
      sections: <ContentArticleSection>[
        ContentArticleSection(
          heading: 'Design data around product workflows',
          paragraphs: <String>[
            'Firestore models should mirror operational workflows, not only entity lists. If your collections match how people actually work, permissions and UI state become easier to reason about.',
            'Teams that model from UI mockups alone usually pay later with hard-to-maintain rules and duplicated business logic.',
          ],
        ),
        ContentArticleSection(
          heading: 'Treat security rules as product behavior',
          paragraphs: <String>[
            'Security rules are not just backend hardening. They define what each role can do, which is part of product behavior.',
            'When role behavior and rules are planned together, you avoid the common “works in UI but denied by backend” class of bug.',
          ],
        ),
        ContentArticleSection(
          heading: 'Plan observability before scale',
          paragraphs: <String>[
            'Add basic operational visibility early: auth failures, write hotspots, and slow user-critical queries. You do not need enterprise monitoring on day one, but you do need enough signal to make decisions.',
            'Simple telemetry gives founders and product owners confidence that the app is stable enough to grow.',
          ],
        ),
      ],
      relatedSlugs: <String>[
        'flutter-mvp-planning-that-reduces-rework',
        'ai-assisted-features-with-product-governance',
      ],
    ),
    ContentArticle(
      slug: 'ai-assisted-features-with-product-governance',
      title: 'AI-Assisted App Features With Product Governance',
      excerpt:
          'How to introduce AI features that help users and still feel safe, testable, and operationally manageable.',
      topic: 'AI-assisted product features',
      readTimeMinutes: 7,
      publishedAtIso: '2026-04-11',
      sections: <ContentArticleSection>[
        ContentArticleSection(
          heading: 'Start with operational use cases',
          paragraphs: <String>[
            'The strongest AI features usually begin with operational bottlenecks: repetitive support responses, triage suggestions, or guided drafting in constrained contexts.',
            'Use cases tied to clear workflows are easier to evaluate than broad “chatbot” ambitions.',
          ],
        ),
        ContentArticleSection(
          heading: 'Separate generation from approval',
          paragraphs: <String>[
            'For business apps, AI output should often be a recommendation layer, not an autonomous action layer. Human approval boundaries improve reliability and user trust.',
            'When teams skip this boundary, product risk grows faster than product value.',
          ],
        ),
        ContentArticleSection(
          heading: 'Measure usefulness, not novelty',
          paragraphs: <String>[
            'Track whether AI features reduce time, improve consistency, or increase completion rates in key workflows. Novel interactions without measurable benefit usually become maintenance cost.',
            'Framing AI as product infrastructure, not a one-off feature, leads to healthier roadmap decisions.',
          ],
        ),
      ],
      relatedSlugs: <String>[
        'firebase-architecture-for-early-stage-products',
        'from-product-design-to-flutter-delivery',
      ],
    ),
    ContentArticle(
      slug: 'flutter-web-for-business-products-what-matters',
      title: 'Flutter Web for Business Products: What Actually Matters',
      excerpt:
          'A practical look at where Flutter Web shines for business products and what to plan early for UX, SEO, and maintainability.',
      topic: 'Flutter web',
      readTimeMinutes: 6,
      publishedAtIso: '2026-04-08',
      sections: <ContentArticleSection>[
        ContentArticleSection(
          heading: 'Use Flutter Web for product surfaces, not marketing-only pages',
          paragraphs: <String>[
            'Flutter Web is excellent for app-like experiences, authenticated workflows, and cross-platform product parity. Pure marketing pages may still benefit from static-rendered stacks when SEO snippet control is critical.',
            'The right architecture often uses Flutter for product UI and complementary static assets for high-SEO marketing content.',
          ],
        ),
        ContentArticleSection(
          heading: 'Prioritize input speed and information density',
          paragraphs: <String>[
            'Business users value speed, clarity, and error prevention over visual novelty. Keyboard flows, readable tables, and predictable state handling often matter more than animation polish.',
            'Treat desktop interaction quality as a first-class requirement if web is part of core usage.',
          ],
        ),
        ContentArticleSection(
          heading: 'Keep modules composable from day one',
          paragraphs: <String>[
            'As products grow, maintainability becomes a conversion issue too: slower delivery and regressions damage trust. Break feature areas into clear modules and keep route-level ownership explicit.',
            'Teams that invest early in composable structure ship faster and with fewer confidence-breaking bugs later.',
          ],
        ),
      ],
      relatedSlugs: <String>[
        'flutter-mvp-planning-that-reduces-rework',
        'from-product-design-to-flutter-delivery',
      ],
    ),
  ];

  static ContentArticle? bySlug(String slug) {
    for (final article in articles) {
      if (article.slug == slug) return article;
    }
    return null;
  }

  static List<ContentArticle> related(ContentArticle article) {
    if (article.relatedSlugs.isEmpty) return const <ContentArticle>[];
    return article.relatedSlugs
        .map(bySlug)
        .whereType<ContentArticle>()
        .toList(growable: false);
  }
}
