/// Service items for the Services screen. Can be loaded from Firestore with static fallback.
class ServiceItem {
  final String id;
  final String iconName;
  final String title;
  final String subtitle;
  /// Core offering in plain language (how you work / what they get).
  final String description;
  /// Business outcome line—why this matters commercially.
  final String valueProposition;
  final List<String> details;
  /// Who this engagement fits—sets expectations before the call.
  final String idealClient;
  final String ctaLabel;
  final int order;

  const ServiceItem({
    required this.id,
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.valueProposition,
    required this.details,
    required this.idealClient,
    this.ctaLabel = 'Discuss your project',
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'iconName': iconName,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'valueProposition': valueProposition,
        'details': details,
        'idealClient': idealClient,
        'ctaLabel': ctaLabel,
        'order': order,
      };

  static ServiceItem fromMap(String docId, Map<String, dynamic> map) {
    final detailsList = map['details'] as List<dynamic>?;
    final details = detailsList?.map((e) => e.toString()).toList() ?? [];
    return ServiceItem(
      id: map['id'] as String? ?? docId,
      iconName: map['iconName'] as String? ?? 'design_services',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      valueProposition: map['valueProposition'] as String? ?? '',
      details: details,
      idealClient: map['idealClient'] as String? ?? '',
      ctaLabel: map['ctaLabel'] as String? ?? 'Discuss your project',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ServicesData {
  ServicesData._();

  static List<ServiceItem> get defaultServices => const [
        ServiceItem(
          id: 'hire-mvp',
          iconName: 'rocket_launch',
          title: 'MVP app development',
          subtitle: 'From idea to a ship-ready first version',
          valueProposition:
              'Reach market with a focused scope, clear milestones, and a product you can show investors or early users—not a bloated wish list.',
          description:
              'Plan and build an initial release that proves your concept: core user flows, solid Flutter implementation, and Firebase when you need auth, data, and hosting without running your own servers.',
          details: [
            'Product and technical scoping for v1',
            'UX/UI tailored to the MVP footprint',
            'Flutter for iOS, Android, and/or web from one codebase',
            'Firebase setup (Auth, Firestore, hosting, etc.) as needed',
            'TestFlight / Play tracks, build handover, and release notes',
          ],
          idealClient:
              'Early-stage founders and teams validating an idea who want one accountable partner from sketch to first release.',
          ctaLabel: 'Discuss your MVP',
        ),
        ServiceItem(
          id: 'hire-design-engineering',
          iconName: 'integration_instructions',
          title: 'Product design + engineering',
          subtitle: 'One workflow from problem to shipped code',
          valueProposition:
              'Fewer handoff gaps—design decisions stay tied to what actually ships, so you move faster with fewer development surprises.',
          description:
              'Work with one person who owns both the product experience and the Flutter build. Strategy and UX/UI stay aligned with implementation, performance, and your timeline.',
          details: [
            'Discovery, flows, and UX/UI for your product',
            'Design systems and component-level thinking',
            'Flutter implementation matched to the design',
            'Iteration with your stakeholders and realistic tradeoffs',
            'Documentation so your team can extend the product later',
          ],
          idealClient:
              'Startups and businesses that want design and engineering in sync—not separate vendors pointing at each other.',
          ctaLabel: 'Talk design and build',
        ),
        ServiceItem(
          id: 'hire-ai',
          iconName: 'auto_awesome',
          title: 'AI-enhanced app features',
          subtitle: 'Practical AI inside your product',
          valueProposition:
              'Ship AI where it improves outcomes—summaries, recommendations, or in-app help—not features users ignore because they do not work reliably.',
          description:
              'Integrate AI-assisted features into new or existing Flutter apps: clear use cases, sensible data handling, Firebase or cloud glue where it fits, and UX that sets honest expectations.',
          details: [
            'Use-case definition and feasibility review',
            'Integration with the models or APIs you choose',
            'Flutter UI for AI-driven flows, loading, and errors',
            'Backend wiring (including Firebase) as needed',
            'Guardrails and copy so users know what the system can and cannot do',
          ],
          idealClient:
              'Teams adding smart features to a product or MVP without standing up a full-time ML org.',
          ctaLabel: 'Explore AI features',
        ),
        ServiceItem(
          id: 'hire-modernize',
          iconName: 'autorenew',
          title: 'App modernization & improvement',
          subtitle: 'Stability, UX, and maintainable releases',
          valueProposition:
              'Lower the risk of slow releases and fragile code by stabilizing what you already have and improving what users notice first.',
          description:
              'Review and improve existing Flutter (or suitable) codebases: UX fixes, dependency and structure cleanup, Firebase upgrades, and a sane plan for ongoing releases.',
          details: [
            'Code and UX audit with a prioritized backlog',
            'Refactors for readability, tests where they pay off',
            'Dependency and platform updates with regression checks',
            'Performance and crash-reduction work',
            'Roadmap for the next releases—not only a one-time patch',
          ],
          idealClient:
              'Businesses with a live app that needs reliability, updates, or a design refresh—without assuming a full rewrite unless you decide you need one.',
          ctaLabel: 'Review your app',
        ),
      ];
}
