/// Service items for the Services screen. Can be loaded from Firestore with static fallback.
class ServiceItem {
  final String id;
  final String iconName;
  final String title;
  final String subtitle;
  final String description;
  final List<String> details;
  final int order;

  const ServiceItem({
    required this.id,
    required this.iconName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.details,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'iconName': iconName,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'details': details,
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
      details: details,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ServicesData {
  ServicesData._();

  static List<ServiceItem> get defaultServices => [
        const ServiceItem(
          id: 'static-0',
          iconName: 'design_services',
          title: 'UX Design',
          subtitle: 'User Experience Design',
          description: 'Comprehensive UX design services including user flows, wireframes, user journeys, information architecture, and interactive prototyping.',
          details: [
            'User flows & journey mapping',
            'Wireframes & low-fidelity prototypes',
            'Information architecture (IA)',
            'Usability testing & research integration',
            'Interaction design patterns',
          ],
        ),
        const ServiceItem(
          id: 'static-1',
          iconName: 'palette',
          title: 'UI Design',
          subtitle: 'Visual & Interface Design',
          description: 'High-fidelity UI design with attention to visual hierarchy, layout systems, and pixel-perfect implementation.',
          details: [
            'Visual design & layout systems',
            'High-fidelity UI components',
            'Responsive design (mobile, tablet, web)',
            'Accessibility (WCAG 2.2 compliance)',
            'Design specifications & handoff',
          ],
        ),
        const ServiceItem(
          id: 'static-2',
          iconName: 'extension',
          title: 'Design Systems',
          subtitle: 'Component Libraries & Documentation',
          description: 'Build scalable design systems with reusable components, design tokens, and comprehensive documentation.',
          details: [
            'Component libraries & patterns',
            'Design tokens (colors, typography, spacing)',
            'Design system documentation',
            'Component maintenance & governance',
            'Cross-platform design systems',
          ],
        ),
        const ServiceItem(
          id: 'static-3',
          iconName: 'psychology',
          title: 'Research & Usability Testing',
          subtitle: 'User-Centered Design Process',
          description: 'Data-driven design decisions through user research, usability testing, and iterative improvements.',
          details: [
            'User research & interviews',
            'Usability testing & analysis',
            'Research integration',
            'Iterative design improvements',
            'User-centered design methodologies',
          ],
        ),
        const ServiceItem(
          id: 'static-4',
          iconName: 'phone_android',
          title: 'Product Design',
          subtitle: 'End-to-End Product Design',
          description: 'Full product design services for web, mobile, enterprise platforms, dashboards, CMS environments, workflow tools.',
          details: [
            'Web & mobile app design',
            'Enterprise platform design',
            'Dashboard & data visualization',
            'CMS & workflow tools',
            'AI-powered product experiences',
          ],
        ),
        const ServiceItem(
          id: 'static-5',
          iconName: 'handshake',
          title: 'Engineering Collaboration',
          subtitle: 'Design-to-Development Partnership',
          description: 'Close collaboration with engineering teams to ensure accurate implementation and maintain design consistency.',
          details: [
            'Design-to-development handoff',
            'Engineering collaboration & validation',
            'Design consistency enforcement',
            'Storytelling & communication',
            'Agile design processes',
          ],
        ),
      ];
}
