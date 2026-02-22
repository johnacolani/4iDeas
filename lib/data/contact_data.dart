/// Contact entry for Contact Us dialog. Can be loaded from Firestore with static fallback.
class ContactEntry {
  final String id;
  final String type; // 'phone', 'email', 'link', 'navigate'
  final String label;
  final String value;
  final String? urlOrRoute; // For link: URL; for navigate: route path
  final int order;

  const ContactEntry({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    this.urlOrRoute,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'label': label,
        'value': value,
        'urlOrRoute': urlOrRoute,
        'order': order,
      };

  static ContactEntry fromMap(String docId, Map<String, dynamic> map) {
    return ContactEntry(
      id: map['id'] as String? ?? docId,
      type: map['type'] as String? ?? 'link',
      label: map['label'] as String? ?? '',
      value: map['value'] as String? ?? '',
      urlOrRoute: map['urlOrRoute'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class ContactData {
  ContactData._();

  static List<ContactEntry> get defaultEntries => [
        const ContactEntry(
          id: 'static-0',
          type: 'phone',
          label: 'Phone',
          value: '804-774-9008',
          urlOrRoute: null,
          order: 0,
        ),
        const ContactEntry(
          id: 'static-1',
          type: 'email',
          label: 'Email',
          value: 'johnacolani@gmail.com',
          urlOrRoute: null,
          order: 1,
        ),
        const ContactEntry(
          id: 'static-2',
          type: 'link',
          label: 'LinkedIn',
          value: 'View Profile',
          urlOrRoute: 'https://www.linkedin.com/in/john-colani-43344a70/',
          order: 2,
        ),
        const ContactEntry(
          id: 'static-3',
          type: 'navigate',
          label: 'Portfolio',
          value: 'View Portfolio',
          urlOrRoute: '/portfolio',
          order: 3,
        ),
      ];
}
