/// Portfolio data models and content for the product design showcase.
library;

class PortfolioApp {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final bool useComingSoonPlaceholder;
  /// When true, show the image (if any) with a "Coming Soon" overlay.
  final bool showComingSoonOverlay;
  final String? appStoreUrl;
  final String? playStoreUrl;
  final String? webUrl;
  /// macOS download: Mac App Store, hosted `.dmg`/`.zip`, GitHub Release, or Firebase Storage URL (not a bundled asset).
  final String? macosUrl;
  /// Windows: Microsoft Store, hosted `.exe`/`.msix`, or GitHub Release URL.
  final String? windowsUrl;
  /// When set, tapping the app card navigates to this case study (go_router) instead of opening [webUrl].
  /// Use when the product also has a full case study on this site (e.g. ASD USA → case study `asd`).
  final String? caseStudyId;

  const PortfolioApp({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.useComingSoonPlaceholder = false,
    this.showComingSoonOverlay = false,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
    this.macosUrl,
    this.windowsUrl,
    this.caseStudyId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'useComingSoonPlaceholder': useComingSoonPlaceholder,
        'showComingSoonOverlay': showComingSoonOverlay,
        'appStoreUrl': appStoreUrl,
        'playStoreUrl': playStoreUrl,
        'webUrl': webUrl,
        'macosUrl': macosUrl,
        'windowsUrl': windowsUrl,
        'caseStudyId': caseStudyId,
      };

  static PortfolioApp fromMap(String docId, Map<String, dynamic> map) {
    return PortfolioApp(
      id: map['id'] as String? ?? docId,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      useComingSoonPlaceholder: map['useComingSoonPlaceholder'] as bool? ?? false,
      showComingSoonOverlay: map['showComingSoonOverlay'] as bool? ?? false,
      appStoreUrl: map['appStoreUrl'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      webUrl: map['webUrl'] as String?,
      macosUrl: map['macosUrl'] as String?,
      windowsUrl: map['windowsUrl'] as String?,
      caseStudyId: map['caseStudyId'] as String?,
    );
  }
}

class PortfolioPublication {
  final String id;
  final String title;
  final String url;
  final int order;

  const PortfolioPublication({
    required this.id,
    required this.title,
    required this.url,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'url': url,
        'order': order,
      };

  static PortfolioPublication fromMap(String docId, Map<String, dynamic> map) {
    return PortfolioPublication(
      id: map['id'] as String? ?? docId,
      title: map['title'] as String? ?? '',
      url: map['url'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class OpenSourceItem {
  final String id;
  final String title;
  final String subtitle;
  final String url;
  /// Icon name for Icons (e.g. 'widgets_outlined', 'code').
  final String iconName;
  final int order;

  const OpenSourceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.url,
    this.iconName = 'code',
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'url': url,
        'iconName': iconName,
        'order': order,
      };

  static OpenSourceItem fromMap(String docId, Map<String, dynamic> map) {
    return OpenSourceItem(
      id: map['id'] as String? ?? docId,
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      url: map['url'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'code',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}

class PortfolioCaseStudy {
  final String id;
  final String title;
  final String subtitle;
  final String overview;
  /// Optional: design philosophy & principles applied in this case study.
  final String? designApproach;
  /// Featured case study card strip: asset path (e.g. `assets/images/...`) or `https://` URL.
  final String? heroImagePath;
  /// When non-empty, featured hero shows a horizontal strip of images (same height as single-hero); scrolls if needed.
  final List<String>? heroImagePaths;
  final List<CaseStudySection> sections;
  final int order;

  const PortfolioCaseStudy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.overview,
    this.designApproach,
    this.heroImagePath,
    this.heroImagePaths,
    required this.sections,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'overview': overview,
        'designApproach': designApproach,
        'heroImagePath': heroImagePath,
        if (heroImagePaths != null && heroImagePaths!.isNotEmpty) 'heroImagePaths': heroImagePaths,
        'sections': sections.map((s) => s.toMap()).toList(),
        'order': order,
      };

  static PortfolioCaseStudy fromMap(String docId, Map<String, dynamic> map) {
    final sectionsList = map['sections'] as List<dynamic>?;
    final sections = sectionsList != null
        ? sectionsList.map((e) => CaseStudySection.fromMap(Map<String, dynamic>.from(e as Map))).toList()
        : <CaseStudySection>[];
    final rawHeroPaths = map['heroImagePaths'];
    List<String>? heroImagePaths;
    if (rawHeroPaths is List) {
      heroImagePaths = rawHeroPaths.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList();
      if (heroImagePaths.isEmpty) heroImagePaths = null;
    }
    return PortfolioCaseStudy(
      id: map['id'] as String? ?? docId,
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      designApproach: map['designApproach'] as String?,
      heroImagePath: map['heroImagePath'] as String?,
      heroImagePaths: heroImagePaths,
      sections: sections,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  /// ASD only: place **Adaptive Platform** immediately before **Design System** (static + Firestore order).
  PortfolioCaseStudy withAdaptiveBeforeDesignSystem() {
    if (id != 'asd') return this;
    final list = List<CaseStudySection>.from(sections);
    final adaptiveI = list.indexWhere((s) => s.isAsdAdaptivePlatformSection);
    final designI = list.indexWhere((s) => s.title.trim().startsWith('Design System'));
    if (adaptiveI < 0 || designI < 0) return this;
    if (adaptiveI == designI - 1) return this;
    final adaptive = list.removeAt(adaptiveI);
    final insertAt = adaptiveI > designI ? designI : designI - 1;
    list.insert(insertAt, adaptive);
    return PortfolioCaseStudy(
      id: id,
      title: title,
      subtitle: subtitle,
      overview: overview,
      designApproach: designApproach,
      heroImagePath: heroImagePath,
      heroImagePaths: heroImagePaths,
      sections: list,
      order: order,
    );
  }
}

/// A case study image with optional caption.
/// All case study images use the same corner radius (see [CaseStudyDetailScreen]).
class CaseStudyImage {
  final String path;
  final String? description;

  const CaseStudyImage({
    required this.path,
    this.description,
  });

  Map<String, dynamic> toMap() => {
        'path': path,
        'description': description,
      };

  static CaseStudyImage fromMap(Map<String, dynamic> map) {
    return CaseStudyImage(
      path: map['path'] as String? ?? '',
      description: map['description'] as String?,
    );
  }
}

class CaseStudySection {
  final String title;
  final String content;
  final List<String>? imagePaths;
  /// When set, used instead of [imagePaths]; allows a description per image.
  final List<CaseStudyImage>? images;
  /// When true, show a control to open the full HTML design-system doc for this case study (see [PortfolioData.caseStudyHasDesignSystemDoc]).
  final bool opensDesignSystemDoc;

  const CaseStudySection({
    required this.title,
    required this.content,
    this.imagePaths,
    this.images,
    this.opensDesignSystemDoc = false,
  });

  /// Images to display: [images] if set, otherwise [imagePaths] as [CaseStudyImage] with no description.
  List<CaseStudyImage> get displayImages {
    if (images != null && images!.isNotEmpty) return images!;
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return imagePaths!.map((p) => CaseStudyImage(path: p)).toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'imagePaths': imagePaths,
        'images': images?.map((i) => i.toMap()).toList(),
        if (opensDesignSystemDoc) 'opensDesignSystemDoc': true,
      };

  static CaseStudySection fromMap(Map<String, dynamic> map) {
    final imagePaths = map['imagePaths'] as List<dynamic>?;
    final imagesList = map['images'] as List<dynamic>?;
    return CaseStudySection(
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imagePaths: imagePaths?.map((e) => e.toString()).toList(),
      images: imagesList?.map((e) => CaseStudyImage.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      opensDesignSystemDoc: map['opensDesignSystemDoc'] as bool? ?? false,
    );
  }

  /// ASD adaptive gallery section (title variants or `asd_app_adaptive` paths).
  bool get isAsdAdaptivePlatformSection {
    final t = title.trim();
    if (t == 'Adaptive Platform' ||
        t == 'Adaptive & Responsive Platform' ||
        t == 'Adaptive Platform for Fully Responsive Screens') {
      return true;
    }
    if (t.startsWith('Adaptive') && t.contains('Responsive')) return true;
    for (final p in imagePaths ?? const <String>[]) {
      if (p.toLowerCase().contains('asd_app_adaptive')) return true;
    }
    for (final i in images ?? const <CaseStudyImage>[]) {
      if (i.path.toLowerCase().contains('asd_app_adaptive')) return true;
    }
    return false;
  }

  static bool matchesAdaptivePlatformSection(String title, Iterable<String> imagePaths) {
    return CaseStudySection(
      title: title,
      content: '',
      imagePaths: imagePaths.toList(),
    ).isAsdAdaptivePlatformSection;
  }
}

/// Paths for embedded HTML design-system documents (web + Flutter asset).
class CaseStudyDesignSystemDocPaths {
  final String webRelativePath;
  final String flutterAssetPath;

  const CaseStudyDesignSystemDocPaths({
    required this.webRelativePath,
    required this.flutterAssetPath,
  });
}

class PortfolioData {
  PortfolioData._();

  /// Design-system HTML docs keyed by id.
  /// Includes case-study docs (e.g. `service-flow`) and app-level docs (e.g. `4ideas`).
  static const Map<String, CaseStudyDesignSystemDocPaths> designSystemDocsByCaseStudyId = {
    'service-flow': CaseStudyDesignSystemDocPaths(
      webRelativePath: 'docs/serviceflow-design-system.html',
      flutterAssetPath: 'assets/docs/serviceflow-design-system.html',
    ),
    '4ideas': CaseStudyDesignSystemDocPaths(
      webRelativePath: 'docs/4ideas-design-system.html',
      flutterAssetPath: 'assets/docs/4ideas-design-system.html',
    ),
  };

  static bool caseStudyHasDesignSystemDoc(String id) =>
      designSystemDocsByCaseStudyId.containsKey(id);

  static CaseStudyDesignSystemDocPaths? designSystemDocPathsForCaseStudy(String id) =>
      designSystemDocsByCaseStudyId[id];

  static const String portfolioVideoUrl =
      'https://github.com/johnhcolani/John-Colani-interactive-Portfolio-/blob/master/Portfolio-2024%20JohnColani.mp4';
  static const String mediumProfile = 'https://medium.com/@johnacolani_22987';
  static const String pubDevPackage =
      'https://pub.dev/packages/auto_scroll_image';
  static const String githubJohnacolaniRepos =
      'https://github.com/johnacolani?tab=repositories';
  static const String githubJohnhcolaniRepos =
      'https://github.com/johnhcolani?tab=repositories';
  static const String fullPortfolioUrl =
      'https://sites.google.com/view/senior-interaction-product-d/home';
  static const String githubProfile = 'https://github.com/johnhcolani';

  /// App grid order matches list order. Featured App Showcase order (first five): Service Flow → ASD USA → 4iDeas Portfolio Website → My Own Design System → Twin Scriptures; then the rest.
  static List<PortfolioApp> get apps => [
        PortfolioApp(
          id: 'service-flow',
          name: 'Service Flow',
          description:
              'Multi-tenant SaaS for field service operations: shared platform, tenant-specific configuration, role-based workflows, and a token-based design system. Case study covers tenancy model, system thinking, and the living ServiceFlow design spec.',
          imagePath: 'assets/images/4ideas/4ideas-web-app.png',
          showComingSoonOverlay: true,
          caseStudyId: 'service-flow',
        ),
        PortfolioApp(
          id: 'asdusa',
          name: 'ASD USA',
          description:
              'Multi-role operations platform for stone fabrication. Supports Admins, Sales Reps, Installers, Schedulers, and Clients. Features AI assistant Amy, role-based dashboards, and live project tracking. Owned end-to-end: strategy, UX/UI, design system, AI governance.',
          imagePath: 'assets/images/app_store/asd-app.png',
          appStoreUrl:
              'https://apps.apple.com/us/app/asdusa/id1588331742?platform=iphone',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.JohnColani.asdapp',
          webUrl: 'https://absolute-stone-design-app.web.app/',
          caseStudyId: 'asd',
        ),
        PortfolioApp(
          id: 'my-web-site',
          name: '4iDeas - Portfolio Website',
          description:
              'Portfolio site: Flutter apps, backend services, product design. Responsive showcase, order form, modern UI. Flutter Web on Firebase.',
          imagePath: 'assets/images/4ideas.png',
          appStoreUrl: null,
          playStoreUrl: null,
          webUrl: 'https://my-web-page-ef286.web.app/',
        ),
        PortfolioApp(
          id: '4ideas-design-system',
          name: 'My Own Design System',
          description:
              'A living design system built in Flutter—components, patterns, and UI primitives. Developed by John Colani.',
          imagePath: 'assets/images/design_system/design-system.png',
          webUrl: 'https://my-flutter-apps-f87ea.web.app/',
        ),
        PortfolioApp(
          id: 'twin-scriptures',
          name: 'Twin Scriptures',
          description:
              'Bilingual scripture readers comparing verses side-by-side. Persian–English and Turkish–English. Simultaneous reading for comprehension, language learning, and theological study. Supports spiritual practice and language reinforcement.',
          imagePath: 'assets/images/app_store/twin-scripture.png',
          appStoreUrl:
              'https://apps.apple.com/app/twin-scriptures/id6740755381',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.twin.scripture',
          caseStudyId: 'twin-scriptures',
        ),
        PortfolioApp(
          id: 'great-t2s',
          name: 'Great T2S',
          description:
              'Designed for people who need assistance with reading—visual challenges, learning differences, or language barriers. Converts written content into natural speech and supports foreign language learners. Accessible, simple experience that reduces cognitive load.',
          imagePath: 'assets/images/app_store/great-t2s.png',
          appStoreUrl: 'https://apps.apple.com/us/app/great-t2s/id6751081806',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johnacolani.text_to_speech',
        ),
        PortfolioApp(
          id: 'solomon-prayers',
          name: 'Solomon Prayers Compass',
          description:
              'Spiritual compass for believers who prefer to face the direction of Solomon\'s Temple while praying. Provides accurate directional guidance in a calm, respectful interface that supports worship without distraction.',
          imagePath: 'assets/images/app_store/solomon-prayer-compass.png',
          appStoreUrl:
              'https://apps.apple.com/app/solomon-prayers-compass/id6670187898',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.temple_direction',
        ),
        PortfolioApp(
          id: 'phillips-rear-vu',
          name: 'Phillips Rear-Vu',
          description:
              'For truck drivers operating large containers without rear visibility. Connects to backup camera hardware for real-time rear view. Design priority: safety, fast visual feedback, minimal interaction while driving.',
          imagePath: 'assets/images/app_store/phillips-rear-vu.png',
          appStoreUrl:
              'https://apps.apple.com/us/app/phillips-rear-vu/id1669085162',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.phillipsind.phillips_rear_vu_mobile_app',
        ),
        PortfolioApp(
          id: 'dream-whisperer',
          name: 'Dream Whisperer',
          description:
              'Explores psychology, curiosity, and AI. Users describe dreams and receive AI-generated interpretations and symbolic insights. Focuses on emotional engagement, reflective thinking, and calm nighttime-friendly UX.',
          imagePath: 'assets/images/app_store/dream-whisperer.png',
          appStoreUrl:
              'https://apps.apple.com/us/app/dream-whisperer/id6547866253?platform=iphone',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.dream_interpret',
        ),
        PortfolioApp(
          id: 'infinitenotesplus',
          name: 'InfiniteNotesPlus',
          description:
              'Folder-based architecture where each folder can contain multiple files. Supports deeper organization than traditional note apps. Personalization: color coding, custom backgrounds. Combines productivity with visual ownership.',
          imagePath: 'assets/images/app_store/infinit-note-plus.png',
          appStoreUrl:
              'https://apps.apple.com/app/infinitenotesplus/id6737788298',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.greate_note_app',
        ),
        PortfolioApp(
          id: 'twin-scripture-en-tr',
          name: 'Twin Scripture EN‑TR',
          description:
              'Turkish–English bilingual scripture reader. Side-by-side verse comparison for comprehension, language learning, and theological study.',
          imagePath: 'assets/images/app_store/twin-scripture-en-tr.png',
          appStoreUrl:
              'https://apps.apple.com/app/twin-scripture-en-tr/id6758272710',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.twin.scripture.turkish',
        ),
        PortfolioApp(
          id: 'fraction-flow',
          name: 'Fraction Flow',
          description:
              'Niche utility for sales reps in countertop fabrication. Converts fractional inch measurements into square feet for pricing and estimation. Reduces manual errors and saves time during client consultations.',
          imagePath: 'assets/images/app_store/fraction-flow.png',
          appStoreUrl:
              'https://apps.apple.com/us/app/fraction-flow/id6742278209',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.fractioflow&pcampaignid=web_share',
        ),
        PortfolioApp(
          id: 'vision-exercise',
          name: 'Vision Exercise',
          description:
              'Vision therapy app for people with crossed eyes (strabismus). Guided eye-muscle exercises to strengthen coordination and alignment. Directional focus tasks, motion tracking, progressive difficulty. Accessible home-based supplement to clinical therapy.',
          imagePath: 'assets/images/vision_exercise.png',
          useComingSoonPlaceholder: false,
          showComingSoonOverlay: true,
          appStoreUrl: null,
          playStoreUrl: null,
        ),
      ];

  /// Prefer non-empty [fromApp]; otherwise use [fromCatalog] so Firestore can override static URLs.
  static String? _mergeUrlField(String? fromApp, String? fromCatalog) {
    final t = fromApp?.trim();
    if (t != null && t.isNotEmpty) return t;
    return fromCatalog;
  }

  /// Static [apps] row that matches this Firestore (or hybrid) app: same id, same case study, or same name.
  static PortfolioApp? _catalogAppMatching(PortfolioApp app) {
    for (final a in apps) {
      if (a.id == app.id) return a;
    }
    final inferred = caseStudyIdForPortfolioAppName(app.name);
    if (inferred != null) {
      for (final a in apps) {
        if (a.caseStudyId == inferred) return a;
      }
    }
    if (app.caseStudyId != null) {
      for (final a in apps) {
        if (a.caseStudyId == app.caseStudyId) return a;
      }
    }
    for (final a in apps) {
      if (a.name == app.name) return a;
    }
    return null;
  }

  /// Firestore docs often omit [PortfolioApp.caseStudyId] and store links. Merge from static [apps] when
  /// the app matches so showcase cards keep case-study navigation and platform buttons.
  ///
  /// Previously, returning early when [caseStudyId] was set skipped merging URLs — store chips disappeared
  /// for apps like ASD USA that only had case study + web in Firestore.
  static PortfolioApp mergePortfolioAppCaseStudyFromCatalog(PortfolioApp app) {
    final catalog = _catalogAppMatching(app);
    final inferredCs = caseStudyIdForPortfolioAppName(app.name);
    final caseStudyId = app.caseStudyId ?? catalog?.caseStudyId ?? inferredCs;

    if (catalog == null) {
      if (caseStudyId != null && app.caseStudyId != caseStudyId) {
        return PortfolioApp(
          id: app.id,
          name: app.name,
          description: app.description,
          imagePath: app.imagePath,
          useComingSoonPlaceholder: app.useComingSoonPlaceholder,
          showComingSoonOverlay: app.showComingSoonOverlay,
          appStoreUrl: app.appStoreUrl,
          playStoreUrl: app.playStoreUrl,
          webUrl: app.webUrl,
          macosUrl: app.macosUrl,
          windowsUrl: app.windowsUrl,
          caseStudyId: caseStudyId,
        );
      }
      return app;
    }

    return PortfolioApp(
      id: app.id,
      name: app.name,
      description: app.description,
      imagePath: app.imagePath,
      useComingSoonPlaceholder: app.useComingSoonPlaceholder,
      showComingSoonOverlay: app.showComingSoonOverlay,
      appStoreUrl: _mergeUrlField(app.appStoreUrl, catalog.appStoreUrl),
      playStoreUrl: _mergeUrlField(app.playStoreUrl, catalog.playStoreUrl),
      webUrl: _mergeUrlField(app.webUrl, catalog.webUrl),
      macosUrl: _mergeUrlField(app.macosUrl, catalog.macosUrl),
      windowsUrl: _mergeUrlField(app.windowsUrl, catalog.windowsUrl),
      caseStudyId: caseStudyId,
    );
  }

  /// App Showcase: Service Flow → ASD USA → 4iDeas Portfolio Website → My Own Design System → Twin Scriptures; then remaining apps in their original order.
  static List<PortfolioApp> orderAppsForShowcase(List<PortfolioApp> apps) {
    int? showcaseSlot(PortfolioApp a) {
      final id = a.id.toLowerCase();
      final name = a.name.toLowerCase();
      if (id == 'service-flow' || name.contains('service flow')) return 0;
      if (id == 'asdusa' || name.contains('asd usa')) return 1;
      if (id == 'my-web-site' ||
          (name.contains('4ideas') && name.contains('portfolio website'))) {
        return 2;
      }
      if (id == '4ideas-design-system' ||
          id == 'design_system' ||
          (name.contains('my own design system'))) {
        return 3;
      }
      if (id == 'twin-scriptures') return 4;
      return null;
    }

    PortfolioApp? takeSlot(int slot) {
      for (final a in apps) {
        if (showcaseSlot(a) == slot) return a;
      }
      return null;
    }

    final placed = <String>{};
    final out = <PortfolioApp>[];
    for (var s = 0; s < 5; s++) {
      final a = takeSlot(s);
      if (a != null) {
        out.add(a);
        placed.add(a.id);
      }
    }
    for (final a in apps) {
      if (!placed.contains(a.id)) out.add(a);
    }
    return out;
  }

  /// Maps showcase app title to [PortfolioCaseStudy.id] when Firestore id does not match static data.
  static String? caseStudyIdForPortfolioAppName(String name) {
    final n = name.toLowerCase().trim();
    // Twin Scripture EN‑TR (separate app; no dedicated case study in this repo)
    if (n.contains('twin') && (n.contains('en-tr') || n.contains('en‑tr'))) {
      return null;
    }
    if (n.contains('twin scripture')) {
      return 'twin-scriptures';
    }
    if (n.contains('absolute stone') || n.contains('asd usa')) {
      return 'asd';
    }
    if (n.contains('service flow')) {
      return 'service-flow';
    }
    return null;
  }

  static List<PortfolioPublication> get publications => [
        PortfolioPublication(
          id: 'static-0',
          title: 'How Flutter Works Under the Hood',
          url:
              'https://medium.com/@johnacolani_22987/how-flutter-works-architecture-and-internals-581b629a55f3',
        ),
        PortfolioPublication(
          id: 'static-1',
          title: 'Understanding Golden Image Tests in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/understanding-golden-image-tests-in-flutter-a-step-by-step-guide-3838287c44ce',
        ),
        PortfolioPublication(
          id: 'static-2',
          title: 'Integrating Native Code in Flutter: Battery Level',
          url:
              'https://medium.com/@johnacolani_22987/integrating-native-code-in-flutter-a-step-by-step-guide-to-retrieving-battery-level-methodchannel-82604061bd35',
        ),
        PortfolioPublication(
          id: 'static-3',
          title: 'Test-Driven Development (TDD) in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/a-step-by-step-guide-to-test-driven-development-tdd-in-flutter-8d6edb3dcf2b',
        ),
        PortfolioPublication(
          id: 'static-4',
          title: 'Unit, Widget, and Integration Testing in < 3 Minutes',
          url:
              'https://medium.com/@johnacolani_22987/testing-flutter-app-in-less-than-3-minutes-1797ddf88c85',
        ),
        PortfolioPublication(
          id: 'static-5',
          title: 'Understanding Isolates in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/understanding-isolates-in-flutter-a-step-by-step-guide-79bf16db96cd',
        ),
      ];

  static List<OpenSourceItem> get openSourceItems => [
        OpenSourceItem(
          id: 'static-0',
          title: 'auto_scroll_image',
          subtitle: 'Pub.dev package',
          url: pubDevPackage,
          iconName: 'widgets_outlined',
        ),
        OpenSourceItem(
          id: 'static-1',
          title: 'johnacolani on GitHub',
          subtitle: 'All repositories',
          url: githubJohnacolaniRepos,
          iconName: 'github',
        ),
        OpenSourceItem(
          id: 'static-2',
          title: 'johnhcolani on GitHub',
          subtitle: 'All repositories',
          url: githubJohnhcolaniRepos,
          iconName: 'github',
        ),
      ];

  /// Twin Scriptures "Solution" onboarding screens for the featured card hero strip (full set).
  static const List<String> twinScripturesFeaturedHeroPaths = <String>[
    'assets/images/on_boarding_image/access_camera_10_1.png',
    'assets/images/on_boarding_image/book_mark_home_17.png',
    'assets/images/on_boarding_image/choos_fonts_15.png',
    'assets/images/on_boarding_image/christmas_image_13.png',
    'assets/images/on_boarding_image/color_theme_4.png',
    'assets/images/on_boarding_image/complete_on_boarding.png',
    'assets/images/on_boarding_image/create_new_color_4_1.png',
    'assets/images/on_boarding_image/custome_home_screen_16.png',
    'assets/images/on_boarding_image/default_app_00.png',
    'assets/images/on_boarding_image/emotional_state_14.png',
    'assets/images/on_boarding_image/fall_image_8.png',
    'assets/images/on_boarding_image/import_image_10.png',
    'assets/images/on_boarding_image/navigate_book_mark_18.png',
    'assets/images/on_boarding_image/new_year_image_11.png',
    'assets/images/on_boarding_image/nowruz_image_12.png',
    'assets/images/on_boarding_image/on_boarding_en_1.png',
    'assets/images/on_boarding_image/on_boarding_fa_2.png',
    'assets/images/on_boarding_image/on_boarding_tr_3.png',
    'assets/images/on_boarding_image/seasonal_theme_5.png',
    'assets/images/on_boarding_image/spring_image_6.png',
    'assets/images/on_boarding_image/summer_image_7.png',
    'assets/images/on_boarding_image/system_theme_4_2.png',
    'assets/images/on_boarding_image/winter_image_9.png',
  ];

  /// ASD featured-card hero: ordered by narrative sections in the featured case study.
  static const List<String> asdRoleSpecificHeroPaths = <String>[
    // Admin dashboard section
    'assets/images/admin/admin_dashboard.jpeg',
    'assets/images/admin/admin_home_screen.jpeg',
    'assets/images/admin/admin_user_management.jpeg',
    'assets/images/admin/admin_promote_to_salesRep.jpeg',
    'assets/images/admin/admin_setting.jpeg',
    // Sales representative experience
    'assets/images/sales_rep/salesRep_dashboard.png',
    'assets/images/sales_rep/salesRep_home.png',
    'assets/images/sales_rep/salesRep_client.png',
    'assets/images/sales_rep/salesRep_project.png',
    'assets/images/sales_rep/create_invoice_01.png',
    'assets/images/sales_rep/performance analytics.png',
    // Scheduler experience
    'assets/images/scheduler/Scheduler dashboard.png',
    'assets/images/scheduler/Scheduler dashboard 01.png',
    'assets/images/scheduler/Create Event.png',
    'assets/images/scheduler/Date Picker.png',
    'assets/images/scheduler/Time Picker.png',
    // Installer experience
    'assets/images/installer/installer dashboard.png',
    'assets/images/installer/installer home screen.png',
    'assets/images/installer/installer on the map.png',
    'assets/images/installer/job history.png',
    'assets/images/installer/installer profile.png',
    // AI workflow and governance
    'assets/images/admin/admin_amy_manager.jpeg',
    'assets/images/admin/admin_chat_with_amy.jpeg',
    'assets/images/admin/admin_Ai_knowledge_base.jpeg',
    // Content and material management
    'assets/images/admin/admin_trending_material.jpeg',
    'assets/images/admin/admin_new_material.jpeg',
    'assets/images/admin/admin_popular_material.jpeg',
    'assets/images/admin/admin_recommended_image.jpeg',
  ];

  /// ASD: full catalog of section images (narrative order, deduped). Used when a broader hero list is needed.
  static List<String> get asdFeaturedHeroPaths {
    const ordered = <String>[
      'assets/images/asd_app_adaptive/asd-001.jpg',
      'assets/images/asd_app_adaptive/asd-002.jpg',
      'assets/images/asd_app_adaptive/asd-003.jpg',
      'assets/images/asd_app_adaptive/asd-004.jpg',
      'assets/images/asd_app_adaptive/asd-005.jpg',
      'assets/images/asd_app_adaptive/asd-006.jpg',
      'assets/images/asd_app_adaptive/asd-007.jpg',
      'assets/images/asd_app_adaptive/asd-008.jpg',
      'assets/images/asd_app_adaptive/asd-009.jpg',
      'assets/images/asd_app_adaptive/asd-010.jpg',
      'assets/images/asd_app_adaptive/asd-011.jpg',
      'assets/images/asd_app_adaptive/asd-012.jpg',
      'assets/images/design_system/design_system_colors.png',
      'assets/images/design_system/design_system_typography.png',
      'assets/images/design_system/design_system_spacing.png',
      'assets/images/design_system/design_system_borderRadius.png',
      'assets/images/design_system/design_system_icon_grid.png',
      'assets/images/admin/admin_dashboard.jpeg',
      'assets/images/admin/admin_home_screen.jpeg',
      'assets/images/admin/admin_user_management.jpeg',
      'assets/images/admin/admin_promote_to_salesRep.jpeg',
      'assets/images/admin/admin_setting.jpeg',
      'assets/images/sales_rep/salesRep_dashboard.png',
      'assets/images/sales_rep/salesRep_home.png',
      'assets/images/installer/installer dashboard.png',
      'assets/images/installer/installer home screen.png',
      'assets/images/scheduler/Scheduler dashboard.png',
      'assets/images/scheduler/Scheduler dashboard 01.png',
      'assets/images/sales_rep/salesRep_client.png',
      'assets/images/sales_rep/salesRep_project.png',
      'assets/images/sales_rep/create_invoice_01.png',
      'assets/images/sales_rep/performance analytics.png',
      'assets/images/scheduler/Create Event.png',
      'assets/images/scheduler/Date Picker.png',
      'assets/images/scheduler/Time Picker.png',
      'assets/images/installer/installer on the map.png',
      'assets/images/installer/job history.png',
      'assets/images/installer/installer profile.png',
      'assets/images/admin/admin_amy_manager.jpeg',
      'assets/images/admin/admin_chat_with_amy.jpeg',
      'assets/images/admin/admin_Ai_knowledge_base.jpeg',
      'assets/images/admin/admin_trending_material.jpeg',
      'assets/images/admin/admin_new_material.jpeg',
      'assets/images/admin/admin_popular_material.jpeg',
      'assets/images/admin/admin_recommended_image.jpeg',
    ];
    final seen = <String>{};
    return [
      for (final p in ordered)
        if (seen.add(p)) p,
    ];
  }

  /// Rose Chat seasonal campaign assets (`assets/images/seasonal UI/`).
  /// Order: calendar flow (New Year → … → Christmas), then `01`–`03` per theme.
  /// Not in repo: `happy_new_year_eve_03.jpg` (only `_01` and `_02` exist).
  static const List<String> _roseSeasonalScreenshotFileNames = <String>[
    'happy_new_year_01.jpg',
    'happy_new_year_02.jpg',
    'happy_new_year_03.jpg',
    'happy_new_year_eve_01.jpg',
    'happy_new_year_eve_02.jpg',
    'happy_nowruz_01.jpg',
    'happy_nowruz_02.jpg',
    'happy_nowruz_03.jpg',
    'happy_spring_01.jpg',
    'happy_spring_02.jpg',
    'happy_spring_03.jpg',
    'happy_memorialday_01.jpg',
    'happy_memorial_02.jpg',
    'happy_memorial_03.jpg',
    'happy_summer_01.jpg',
    'happy_summer_02.jpg',
    'happy_summer_03.jpg',
    'happy_4th_of_july_01.jpg',
    'happy_4th_of_july_02.jpg',
    'happy_4th_of_july_03.jpg',
    'happy_labor_day_01.jpg',
    'happy_labor_day_02.jpg',
    'happy_labor_day_03.jpg',
    'happy_fall_01.jpg',
    'happy_fall_02.jpg',
    'happy_fall_03.jpg',
    'happy_haloween_01.jpg',
    'happy_haloween_02.jpg',
    'happy_haloween_03.jpg',
    'happy_thanksgiving_01.jpg',
    'happy_thanksgiving_02.jpg',
    'happy_thanksgiving_03.jpg',
    'happy_winter_01.jpg',
    'happy_winter_02.jpg',
    'happy_winter_03.jpg',
    'merry_christmass_01.jpg',
    'merry_christmass_02.jpg',
    'merry_christmass_03.jpg',
  ];

  static const String _roseSeasonalAssetDir = 'assets/images/seasonal UI';

  /// Featured-card hero strip for Rose Chat seasonal case study (same pattern as Twin Scriptures).
  static List<String> get roseChatSeasonalFeaturedHeroPaths => [
        for (final name in _roseSeasonalScreenshotFileNames) '$_roseSeasonalAssetDir/$name',
      ];

  /// Featured case studies are sorted by [PortfolioCaseStudy.order] ascending on the portfolio screen (lower = higher on the page).
  /// New featured study: add near the top here and give it the lowest `order` (e.g. 0); increase `order` on older studies if needed.
  static List<PortfolioCaseStudy> get caseStudies => [
        PortfolioCaseStudy(
          id: 'rose-chat-seasonal-campaign-engine',
          title: 'Rose AI Seasonal Experience Engine',
          subtitle: 'Designed and Built: Dynamic Campaign UX, Governance, and Rollout at Scale',
          overview:
              'A flagship Rose AI case study showing how I designed and built a backend-driven seasonal experience system at production scale. '
              'The campaign engine transforms chat with contextual greetings, seasonal themes, dynamic assets, preview controls, and safe rollout logic without app redeploys.',
          designApproach:
              'Senior product design framing for AI systems: define interaction outcomes first, then align backend controls, rollout governance, and UX states so non-engineering teams can ship and manage conversational experiences safely.',
          heroImagePath: roseChatSeasonalFeaturedHeroPaths.first,
          heroImagePaths: roseChatSeasonalFeaturedHeroPaths,
          sections: [
            CaseStudySection(
              title: 'Problem',
              content:
                  '**Origin.** I conceived and designed the Rose Chat Seasonal Campaign Engine myself as one of my first major product initiatives in the United States—built to give users a **clearer, more attractive path** through the app and a **distinct seasonal flow** they could feel every time they opened chat. The goal was simple: move beyond a generic assistant and deliver something **purpose-built for engagement**—timed to moments that matter, visually alive, and easy to trust.\n\n'
                  '**Why it mattered.** The conversational AI layer had been **static and expensive to change**. Seasonal beats, campaign messaging, and onboarding that should feel fresh were trapped behind **release cycles**—slow for the business, invisible to users who deserved a product that felt cared for. Operations needed speed; users needed **continuity and delight** without sacrificing safety.\n\n'
                  '**The gap.** There was no governed way to ship **usable, on-brand seasonal experiences** on demand—only brittle one-offs or code drops. Closing that gap meant designing a system where **special flows** for users and **controlled rollout** for the team could finally live in the same product.',
            ),
            CaseStudySection(
              title: 'Solution',
              content:
                  'Designed and shipped a backend-driven campaign engine for Rose Chat where admins can configure seasonal messaging, greetings, visual themes, dynamic assets, and rollout timing from backend controls.\n\n'
                  'The system supports preview mode, fallback behavior, and kill-switch patterns so campaign changes can be tested and released safely without app redeploys.',
            ),
            CaseStudySection(
              title: 'Seasonal campaign UI',
              content:
                  'iPhone simulator captures of the seasonal campaign experience in Rose Chat—greetings, themes, and rollout states in context. Order follows campaign theme (calendar flow) and `01`–`03` within each theme. Tap any screen to view full size.',
              imagePaths: List<String>.from(roseChatSeasonalFeaturedHeroPaths),
            ),
            CaseStudySection(
              title: 'My Role',
              content:
                  'Led product and UX strategy end-to-end: problem framing, information architecture, campaign UX flows, control-surface design for admins, and delivery alignment with engineering.\n\n'
                  'Defined design requirements for safe operations (preview, rollback, fallback), clear campaign states, and consistent conversational tone across contexts.',
            ),
            CaseStudySection(
              title: 'System Architecture',
              content:
                  'Architected a configurable backend model using Firebase services to drive campaign behavior at runtime.\n\n'
                  '• Firestore stores campaign definitions and metadata.\n'
                  '• Firebase Storage serves campaign-specific visual assets.\n'
                  '• Remote Config controls activation strategy and environment-safe rollout.\n'
                  '• Runtime fallback logic guarantees graceful defaults when campaigns are missing or invalid.\n\n'
                  'This structure enabled scalable campaign orchestration across platforms with low operational overhead.',
            ),
            CaseStudySection(
              title: 'Conversational AI Design',
              content:
                  'The experience design focused on conversational relevance, emotional timing, and brand consistency. Campaign context dynamically influences greeting patterns, visual tone, and message framing while preserving the core Rose assistant behavior.\n\n'
                  'Interaction states were intentionally designed for first-run moments, returning users, and campaign expiration so the AI experience feels intentional rather than cosmetic.',
            ),
            CaseStudySection(
              title: 'Outcome',
              content:
                  'Rose Chat became a configurable AI surface instead of a hardcoded feature. Product and operations teams can launch seasonal experiences faster, reduce engineering dependency for campaign updates, and maintain safer releases through preview and fallback controls.\n\n'
                  'The result is a stronger AI product narrative: conversational UX as a governed, scalable system.',
            ),
            CaseStudySection(
              title: 'Future Roadmap',
              content:
                  '• Campaign performance analytics by segment and context\n'
                  '• Smarter personalization rules tied to user states\n'
                  '• Expanded campaign templates for multi-market storytelling\n'
                  '• Additional governance tooling for audit and approval workflows',
            ),
          ],
          order: 0,
        ),
        PortfolioCaseStudy(
          id: 'service-flow',
          title: 'Service Flow',
          subtitle: 'Multi-tenant SaaS for field service workflows',
          overview:
              'Service Flow is a Multi-tenant SaaS case study for structuring complex operational work across field teams and office teams. '
              'The focus is clarity under pressure: predictable navigation, legible hierarchy, tenant-safe data boundaries, and a design system that keeps product and engineering aligned. '
              'Below is a concise narrative; the full **ServiceFlow design system** document (tokens, components, patterns) opens as an interactive HTML spec.',
          designApproach:
              'Systems-first IA, Multi-tenant SaaS constraints (isolation, configuration, role policy), and a single source of truth for UI tokens and components. '
              'The design system is maintained as a living document so specs stay shippable alongside the product.',
          heroImagePath: 'assets/images/design_system/design-system.png',
          sections: [
            CaseStudySection(
              title: 'Problem',
              content:
                  'Field and dispatch workflows often scatter status, actions, and context across screens and ad-hoc tools. '
                  'Technicians lose time finding “what’s next”; coordinators re-enter the same data; stakeholders lack a shared vocabulary for UI and states.\n\n'
                  '**Goal:** One coherent service experience—clear jobs, obvious next steps, and a design system that scales without one-off screens.',
            ),
            CaseStudySection(
              title: 'Context',
              content:
                  '**Users:** Field technicians, dispatchers, and account stakeholders—different devices, attention budgets, and connectivity.\n\n'
                  '**Product lens:** Mobile-first execution with desktop-friendly oversight. The same entities (jobs, visits, assets) surface differently per role without forking the mental model.',
            ),
            CaseStudySection(
              title: 'Multi-tenant SaaS model',
              content:
                  'Service Flow is designed as a **Multi-tenant SaaS**: one shared product serves many companies (tenants), while each tenant keeps isolated operational data, users, and configuration.\n\n'
                  '**How it works:**\n'
                  '• **Tenant isolation:** Data reads/writes are scoped to tenant context so one company cannot access another company\'s records.\n'
                  '• **Shared platform, configurable behavior:** Core workflows are shared, but tenant-specific policies, labels, and feature toggles adapt the experience without forking code.\n'
                  '• **Role + tenant policy:** Permissions are enforced by both role (technician/dispatcher/admin) and tenant membership.\n'
                  '• **Scalable operations:** New tenants onboard through configuration and templates rather than custom builds.\n\n'
                  'This model keeps delivery fast and maintainable while preserving security, compliance posture, and per-tenant autonomy.',
            ),
            CaseStudySection(
              title: 'Solution direction',
              content:
                  '**Information architecture** built around jobs and timelines—not feature silos. **Progressive disclosure** so critical actions stay visible while secondary detail stays one tap away.\n\n'
                  '**Design system** as the contract between design and engineering: semantic color, type scale, spacing, radii, and component states documented in one place.\n\n'
                  'The next section links to the full ServiceFlow design spec (HTML).',
            ),
            CaseStudySection(
              title: 'Design system',
              content:
                  'The ServiceFlow design system captures foundations (color, typography, spacing, elevation), components, and pattern guidance in a single scrollable document—ideal for handoff and long-term maintenance.\n\n'
                  'Use the button to open the full HTML document in-app (web: same-origin; mobile: bundled asset).',
              opensDesignSystemDoc: true,
            ),
          ],
          order: 10,
        ),
        PortfolioCaseStudy(
          id: 'asd',
          title: 'Absolute Stone Design (ASD)',
          subtitle: 'Multi‑Role Operations Platform',
          overview:
              'One system replaced phone, text, and spreadsheets: visible state, less coordination, scalable onboarding, human-governed AI. '
              'Operations platform for stone fabrication and installation. End-to-end ownership: product strategy, UX/UI, design system, AI governance, data architecture, cross-platform (iOS, Android, Web). '
              'Single data model, role-based permissions, visible workflows—config and integrations co-specified with engineering for scale.',
          designApproach:
              'Structured narrative: Problem → Context → System Complexity → Solution → Constraints & Trade-offs → Outcome & Impact. '
              'Design strategy: systems thinking, role-based IA, explicit governance (audit, human-in-the-loop AI). Partnership with engineering on data model, workflow logic, and config-driven behavior. WCAG 2.2 AA for core flows.',
          order: 10,
          heroImagePath: asdRoleSpecificHeroPaths.first,
          heroImagePaths: asdRoleSpecificHeroPaths,
          sections: [
            CaseStudySection(
              title: 'Problem',
              content:
                  'Handoffs, not a system. Phone, text, spreadsheets, ad-hoc tools. Status in people\'s heads; clients blind; installers manual; sales and scheduling decoupled from field; admins without central control.\n\n'
                  '**What was broken:** No single place for "where is my job?" or ownership. Coordination consumed hours; duplicate data, version conflicts. Adding users or changing content = manual, opaque steps; scaling added process, not capability. No structured data or governance for AI.\n\n'
                  '**Goal:** One system—unified operations, visible handoffs and state, AI with human oversight—without new process or IT overhead.',
            ),
            CaseStudySection(
              title: 'Context',
              content:
                  '**Domain:** Stone fabrication and installation—measure → fabricate → install → maintain. Work flows through stages and roles; the system models that pipeline, not just screens.\n\n'
                  '**Five roles, five surfaces:** Admin, Sales, Scheduler, Installer, Client. Different permissions, data needs, devices (desktop → mobile, often offline). Same entities serve all five; UI and backend enforce what each role sees and can do.\n\n'
                  '**Pre-system:** No source of truth. "Where is my job?" landed on people. Scope: front-end, operational logic, ownership of config and integrations.',
            ),
            CaseStudySection(
              title: 'System Complexity',
              content:
                  '**One platform, one data model, many surfaces.**\n\n'
                  'Flow: Sales creates project → Scheduler assigns Installer → Installer updates status → Client sees it live → Admin has full audit trail. Front-end maps to backend rules (read/write, notification triggers, state propagation). Flows and permission boundaries defined first; UI exposes the right slice per role.\n\n'
                  '**Shared entities:** Users, Projects, Events, Materials, Contracts, AI conversations. Permissions govern visibility and actions. Stateful workflows—status changes trigger notifications and audit. Governance (roles, content, AI) Admin-controlled, no code deploys.\n\n'
                  '**Integrations & backend:** Payments, email, GPS, hardware, offline sync. Design respected what each integration provides and where logic lives. Partnership with engineering kept workflow logic feasible and scalable.\n\n'
                  '**Cross-platform:** One codebase (iOS, Android, Web). Layout adapts by device and viewport; front-end matches backend capabilities.',
            ),
            CaseStudySection(
              title: 'Solution',
              content:
                  '**One product, one source of truth.** Single product, not separate apps—cross-role visibility, permissions, and workflows consistent. Trade-off: more upfront design for long-term clarity and scale.\n\n'
                  '**How it works:** Post-login, role-based routing and permission checks define what each user sees and can do. Backend enforces read/write; UI reflects it. Config is central: Admin promotes users, manages content and materials, configures Amy, reviews and corrects answers—no code deploys. Partnership with engineering: config-driven vs. fixed in code so the product scales without dev dependency.\n\n'
                  '**AI:** Governed assistant—first-line for common questions, escalation and human fallback. Knowledge base and responses admin-owned, versioned, auditable.\n\n'
                  '**Workflow logic:** Status → notifications and audit. Config → propagation to all surfaces. Offline sync → same data model. Built for feasibility and maintainability.\n\n'
                  '**By role:** Sales—leads, contracts, invoices, tracking. Scheduler—calendar, events, allocation. Installer—one-tap start/status, auto notifications, live GPS; mobile-first, offline-capable. Client—status, materials, appointments, invoices, Amy. Shared design system; same journeys from phone to desktop.',
            ),
            CaseStudySection(
              title: 'Adaptive Platform for Fully Responsive Screens',
              content:
                  '**Platform and viewport as two lenses.** One codebase, many surfaces. Adaptive = where the app runs. Responsive = how much room we have. Both shape hierarchy, density, and interaction.\n\n'
                  '• **Responsive**: Breakpoints aren’t decorative—they reorder information so the same task stays coherent on a narrow phone, a tablet in the field, or a wide admin desktop. Primary actions stay thumb-reachable on small screens; data-heavy views breathe on large ones. Typography and spacing scale with tokens so nothing feels “shrunk” or “stretched”—just appropriate for the context.\n\n'
                  '• **iOS & Android**: Native-feel navigation, touch-first targets, and platform idioms only where they reduce friction—not novelty for its own sake.\n\n'
                  '• **Web**: Keyboard paths, hover affordances where useful, and dashboards tuned for sustained desktop use (admin, sales) without abandoning mobile web where clients check status.\n\n'
                  '• **Shared foundation**: One design system and data layer; layout and affordances shift. No duplicate flows—just deliberate adaptation.\n\n'
                  'The screens below show the same journeys across form factors: one source of truth, intentionally responsive and platform-aware.',
              imagePaths: [
                'assets/images/asd_app_adaptive/asd-001.jpg',
                'assets/images/asd_app_adaptive/asd-002.jpg',
                'assets/images/asd_app_adaptive/asd-003.jpg',
                'assets/images/asd_app_adaptive/asd-004.jpg',
                'assets/images/asd_app_adaptive/asd-005.jpg',
                'assets/images/asd_app_adaptive/asd-006.jpg',
                'assets/images/asd_app_adaptive/asd-007.jpg',
                'assets/images/asd_app_adaptive/asd-008.jpg',
                'assets/images/asd_app_adaptive/asd-009.jpg',
                'assets/images/asd_app_adaptive/asd-010.jpg',
                'assets/images/asd_app_adaptive/asd-011.jpg',
                'assets/images/asd_app_adaptive/asd-012.jpg',
              ],
            ),
            CaseStudySection(
              title: 'Design System (v3.0.11)',
              content:
                  '**Token-based design system** across mobile and web: dark-first UI, semantic color (role-specific palettes), typography and spacing, grid, component library. Consistent patterns across platforms.\n\n'
                  '**Impact:** Faster delivery, fewer inconsistencies, less rework, single source for UI.',
              imagePaths: [
                'assets/images/design_system/design_system_colors.png',
                'assets/images/design_system/design_system_typography.png',
                'assets/images/design_system/design_system_spacing.png',
                'assets/images/design_system/design_system_borderRadius.png',
                'assets/images/design_system/design_system_icon_grid.png',
              ],
            ),
            CaseStudySection(
              title: 'Admin Dashboard',
              content:
                  '**Control layer for config and governance.**\n\n'
                  'Admins promote users, control home content and materials, configure chat and AI—no dev involvement. Config flows surfaced and guarded: what takes effect where, dependencies, failure modes. Engineering: config stored and propagated, permissions enforced.\n\n'
                  '**Outcome:** Faster onboarding, fewer support requests, safe scaling.',
              imagePaths: [
                'assets/images/admin/admin_dashboard.jpeg',
                'assets/images/admin/admin_home_screen.jpeg',
                'assets/images/admin/admin_user_management.jpeg',
                'assets/images/admin/admin_promote_to_salesRep.jpeg',
                'assets/images/admin/admin_setting.jpeg',
              ],
            ),
            CaseStudySection(
              title: 'Role‑Specific Dashboards',
              content:
                  '**One role, one dashboard.** Responsibilities and permissions drive what each sees.\n\n'
                  'Sales — Leads, contracts. Scheduler — Coordination, planning. Installer — Job execution, live tracking.',
              imagePaths: [
                'assets/images/sales_rep/salesRep_dashboard.png',
                'assets/images/sales_rep/salesRep_home.png',
                'assets/images/installer/installer dashboard.png',
                'assets/images/installer/installer home screen.png',
                'assets/images/scheduler/Scheduler dashboard.png',
                'assets/images/scheduler/Scheduler dashboard 01.png',
              ],
            ),
            CaseStudySection(
              title: 'Sales Representative Experience',
              content:
                  '**Leads, contracts, client relationships** in one place. Lead management, contracts, invoices, payment tracking, project and performance analytics.',
              imagePaths: [
                'assets/images/sales_rep/salesRep_dashboard.png',
                'assets/images/sales_rep/salesRep_home.png',
                'assets/images/sales_rep/salesRep_client.png',
                'assets/images/sales_rep/salesRep_project.png',
                'assets/images/sales_rep/create_invoice_01.png',
                'assets/images/sales_rep/performance analytics.png',
              ],
            ),
            CaseStudySection(
              title: 'Scheduler Experience',
              content:
                  '**Jobs and team schedules** in one view. Calendar scheduling, event creation, team and resource allocation, date and time pickers.',
              imagePaths: [
                'assets/images/scheduler/Scheduler dashboard.png',
                'assets/images/scheduler/Scheduler dashboard 01.png',
                'assets/images/scheduler/Create Event.png',
                'assets/images/scheduler/Date Picker.png',
                'assets/images/scheduler/Time Picker.png',
              ],
            ),
            CaseStudySection(
              title: 'Client Experience',
              content:
                  '**Full visibility** into projects, orders, and communication. Project tracking, materials, appointments, invoices, payment, direct contact with sales, Amy for quick questions.',
              // imagePaths: [
              //   'assets/images/Clients/Home/Bottom Nav/Home03.png',
              //   'assets/images/Clients/Home/Bottom Nav/Home04.png',
              //   'assets/images/Clients/CategoryButtons/My Project.png',
              //   'assets/images/Clients/CategoryButtons/Project Tracker.png',
              //   'assets/images/Clients/CategoryButtons/Book Appointment.png',
              //   'assets/images/Clients/CategoryButtons/invoice.png',
              //   'assets/images/Clients/CategoryButtons/Chat with SalesRep.png',
              // ],
            ),
            CaseStudySection(
              title: 'Installer Experience',
              content:
                  '**Field-first:** Variable environments, limited attention and connectivity. One-tap start/status, auto client notifications, live GPS. Mobile-first flows for speed and clarity.\n\n'
                  '**Result:** Fewer "where is my installer?" calls; accurate status; higher task completion.',
              imagePaths: [
                'assets/images/installer/installer dashboard.png',
                'assets/images/installer/installer home screen.png',
                'assets/images/installer/installer on the map.png',
                'assets/images/installer/job history.png',
                'assets/images/installer/installer profile.png',
              ],
            ),
            CaseStudySection(
              title: 'AI Workflow & Governance',
              content:
                  '**Governed assistant, not autonomous agent.** First-line responder with human oversight.\n\n'
                  '**Why:** Client questions overloaded sales. Constraint: AI cannot decide or misinform. Solution: AI handles common questions; complex or sensitive escalates.\n\n'
                  '**Architecture:** Knowledge base—Admin-controlled, versioned, test before prod, structured Q&A, confidence scoring. Conversation flow—common questions (materials, services, pricing), escalation triggers, human fallback when confidence low. Audit & correction—all logged, Admin flags errors, knowledge base updated.\n\n'
                  '**Governance:** Admin controls what AI says, when it responds (test vs. prod), and corrects. Zero autonomous business-critical decisions.\n\n'
                  '**Outcome:** Routine inquiries deflected to AI; repetitive sales questions down; oversight keeps the system correctable and improvable.',
              imagePaths: [
                'assets/images/admin/admin_amy_manager.jpeg',
                'assets/images/admin/admin_chat_with_amy.jpeg',
                'assets/images/admin/admin_Ai_knowledge_base.jpeg',
              ],
            ),
            CaseStudySection(
              title: 'Content & Material Management',
              content:
                  '**Config, not code.** Admins manage trending, new, and recommended materials. Content flows from Admin to all clients—no redeploy. Storage and delivery designed so content refreshes without releases.',
              imagePaths: [
                'assets/images/admin/admin_trending_material.jpeg',
                'assets/images/admin/admin_new_material.jpeg',
                'assets/images/admin/admin_popular_material.jpeg',
                'assets/images/admin/admin_recommended_image.jpeg',
              ],
            ),
            CaseStudySection(
              title: 'Accessibility & Usability',
              content:
                  '**WCAG 2.2 AA** for core flows: contrast, focus states, typography, predictable navigation and errors. Critical for field and low-attention contexts.',
            ),
            CaseStudySection(
              title: 'Shipping & Platforms',
              content:
                  '**One codebase** — iOS, Android, Web. Shared design system. QR distribution for fast onboarding. Single data layer so new features and config don\'t fragment the product. Lower maintenance; consistent behavior across roles and devices.',
            ),
            CaseStudySection(
              title: 'Constraints & Trade-offs',
              content:
                  '• **Unified vs. separate apps** — One platform, consistent data and permissions. Higher upfront complexity for long-term clarity.\n'
                  '• **AI** — Routine only; complex or sensitive escalates. Governance explicit; audit and permissions block autonomous decisions.\n'
                  '• **Offline & field** — Data model and sync support offline; UI and backend agree on offline behavior and reconciliation.\n'
                  '• **Accessibility** — WCAG 2.2 AA for field and office.\n'
                  '• **Single codebase** — One design system and data layer; layout adapts by platform. One source of truth for behavior and styling.',
            ),
            CaseStudySection(
              title: 'Outcome & Impact',
              content:
                  '**Before → After**\n\n'
                  '**Visibility** — Was: status in heads and spreadsheets, clients blind. Now: one source of truth, real-time job state, "where is my job?" in the product.\n'
                  '**Coordination** — Was: hours on phone and text. Now: workflows visible and automated, handoffs and permissions consistent.\n'
                  '**Scalability** — Was: manual, opaque steps. Now: self-service role promotion, config-driven content, onboarding from days to minutes.\n'
                  '**Trust** — Was: no record. Now: actions and AI conversations logged and reviewable.\n'
                  '**AI** — Was: no structured data or governance. Now: Amy handles routine with oversight; conversations correctable.\n\n'
                  '**Shipped:** iOS, Android, Web. One design system and data layer. QR onboarding. Integrations (payments, notifications, GPS, offline) with specified behavior and failure modes. Front-end, backend, and config co-specified from the start—single source of truth, fewer handoff failures, scalable without proportional process growth.\n\n'
                  '**Next:** Deeper analytics, installer workflows (QA, signatures, checklists), stronger scheduling automation—same system.',
            ),
            CaseStudySection(
              title: 'Next Steps',
              content:
                  '• Advanced analytics dashboards\n'
                  '• Expanded installer workflows (QA, signatures, checklists)\n'
                  '• AI feedback loops tied to performance metrics\n'
                  '• Further automation in scheduling and operations',
            ),
          ],
        ),
        PortfolioCaseStudy(
          id: 'twin-scriptures',
          title: 'Twin Scriptures',
          subtitle: 'Consumer Spiritual App',
          overview:
              'Scripture reading that feels personal and culturally respectful. Replaced long forms with visual preference selection—themes, fonts, seasons, emotions—so users shape the UI. '
              'Persian–English and Turkish–English, RTL support, multi-platform. "Show, Don\'t Ask" design strategy; high onboarding completion and strong user feedback on personalization.',
          designApproach:
              'Structured narrative: Problem → Context → System Complexity → Solution → Constraints & Trade-offs → Outcome & Impact. '
              'Design strategy: empathy-led (respect users, avoid long forms, visual choice over surveys); personalization as a system—onboarding choices drive themes, typography, and content globally. Preference model aligned with implementation. Privacy and ethics by design.',
          order: 20,
          heroImagePath: twinScripturesFeaturedHeroPaths.first,
          heroImagePaths: List<String>.from(twinScripturesFeaturedHeroPaths),
          sections: [
            CaseStudySection(
              title: 'Problem',
              content:
                  'Spiritual apps often rely on long text forms and surveys for personalization. Result: high abandonment (industry ~60%), generic experience, little emotional or cultural connection. '
                  'Users drop off before the product feels theirs; one-size-fits-all undermines trust and engagement.\n\n'
                  '**Goal:** A reading experience that feels personal and culturally respectful—without forms that users abandon.',
            ),
            CaseStudySection(
              title: 'Context',
              content:
                  '**Domain:** Scripture reading—personal, emotional, culturally sensitive. Persian–English and Turkish–English; RTL and multi-script. Users span languages, seasons, and emotional states; a single default UI would miss them.\n\n'
                  '**Pre-product:** Generic spiritual apps with text-heavy onboarding. No model for "user-designed" UI or visual preference as the driver of experience.\n\n'
                  '**Scope:** Onboarding that captures preference without friction; those preferences must drive themes, fonts, imagery, and content across the app.',
            ),
            CaseStudySection(
              title: 'System Complexity',
              content:
                  '**Personalization as a system.** User choices (seasons, emotions, holidays, fonts, colors) aren\'t decorative—they drive theme, typography, and content. One data model: what the user selected; the app reflects it everywhere.\n\n'
                  '**Multi-language and RTL.** Persian (Farsi) and Turkish with English; RTL layout and script. Visual preference selection had to work across languages without relying on long copy.\n\n'
                  '**Cross-platform.** iOS, Android, Web, desktop—same personalization logic, consistent expression across surfaces.',
            ),
            CaseStudySection(
              title: 'Solution',
              content:
                  '**"Show, Don\'t Ask."** Replace forms with visual preference selection. Users choose seasons, emotions, holidays, and fonts through image-based flows—no long surveys. Onboarding puts the UI in the user\'s hands: they define how the app looks and feels.\n\n'
                  '**Architecture:** Short onboarding → structured choices (seasonal, emotional, cultural) → themes and typography applied globally. Single preference model; UI and content respond consistently. Design and implementation aligned on the preference schema so theming and content stay in sync.\n\n'
                  'Screens below show the onboarding flows and resulting experience.',
              images: [
                CaseStudyImage(path: 'assets/images/on_boarding_image/access_camera_10_1.png', description: 'Permission to access device camera for importing personal images.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/book_mark_home_17.png', description: 'Bookmarks and home screen with quick access to saved verses.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/choos_fonts_15.png', description: 'Font selection for English and Persian to personalize reading comfort.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/christmas_image_13.png', description: 'Christmas seasonal theme option for the reading experience.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/color_theme_4.png', description: 'Color theme picker for app accent and background.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/complete_on_boarding.png', description: 'Completion screen: "Everything is Ready!" with summary of choices.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/create_new_color_4_1.png', description: 'Create a custom color for themes.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/custome_home_screen_16.png', description: 'Customizable home screen layout and preferences.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/default_app_00.png', description: 'Default app appearance before personalization.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/emotional_state_14.png', description: 'Emotional state selection (e.g. peaceful, joyful) for matching content.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/fall_image_8.png', description: 'Fall / autumn seasonal theme.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/import_image_10.png', description: 'Import personal images for backgrounds or themes.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/navigate_book_mark_18.png', description: 'Navigation to bookmarks and saved content.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/new_year_image_11.png', description: 'New Year seasonal theme option.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/nowruz_image_12.png', description: 'Nowruz (Persian New Year) cultural theme.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/on_boarding_en_1.png', description: 'Onboarding flow in English.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/on_boarding_fa_2.png', description: 'Onboarding flow in Persian (Farsi) with RTL.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/on_boarding_tr_3.png', description: 'Onboarding flow in Turkish.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/seasonal_theme_5.png', description: 'Seasonal theme selector (Spring, Summer, Fall, Winter).'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/spring_image_6.png', description: 'Spring seasonal theme.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/summer_image_7.png', description: 'Summer seasonal theme.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/system_theme_4_2.png', description: 'Follow system light/dark theme.'),
                CaseStudyImage(path: 'assets/images/on_boarding_image/winter_image_9.png', description: 'Winter seasonal theme.'),
              ],
            ),
            CaseStudySection(
              title: 'Constraints & Trade-offs',
              content:
                  '• **Forms vs. visual choice** — Long forms drive abandonment. Trade-off: invest in visual preference design so onboarding is short and completable.\n'
                  '• **Personalization vs. privacy** — Preferences drive the experience without surveillance; no long surveys, no sensitive data.\n'
                  '• **Cultural breadth** — Seasons, emotions, holidays (e.g. Nowruz, Christmas) and multi-language (Persian, Turkish, English) with RTL. One system, many expressions.\n'
                  '• **Multi-platform** — Same preference model and theming logic across iOS, Android, Web, Linux, macOS, Windows.',
            ),
            CaseStudySection(
              title: 'Outcome & Impact',
              content:
                  '**Before → After**\n\n'
                  '**Onboarding** — Was: text forms, high abandonment. Now: visual preference selection; completion far above industry (~40% baseline); users report a personal, owned experience and strong engagement with themes.\n\n'
                  '**Experience** — Was: generic. Now: themes, fonts, seasons, and emotions chosen by the user; the app reflects their choices everywhere. Personalization as a system—one preference model, consistent expression.\n\n'
                  '**Reach** — Multi-platform (iOS, Android, Web, Linux, macOS, Windows). Free, no ads, no in-app purchases—spiritual content accessible to all.',
            ),
          ],
        ),
      ];

  /// Renamed assets: `asd-app-0001.jpg` → `asd-001.jpg` (Firestore may still list old names).
  static String migrateAsdAdaptiveAssetPath(String path) {
    final m = RegExp(r'asd-app-(\d+)\.(jpg|jpeg|png)', caseSensitive: false).firstMatch(path);
    if (m == null) return path;
    final dirEnd = path.lastIndexOf('/') + 1;
    if (dirEnd <= 0) return path;
    final n = int.parse(m.group(1)!);
    final ext = m.group(2)!.toLowerCase();
    return '${path.substring(0, dirEnd)}asd-${n.toString().padLeft(3, '0')}.$ext';
  }

  /// Firestore ASD often stores an older adaptive section title/body; keep copy in sync with [caseStudies].
  static PortfolioCaseStudy mergeFirestoreAsdAdaptiveCopyFromStatic(PortfolioCaseStudy firestoreAsd) {
    if (firestoreAsd.id != 'asd') return firestoreAsd;
    PortfolioCaseStudy? staticAsd;
    for (final c in caseStudies) {
      if (c.id == 'asd') {
        staticAsd = c;
        break;
      }
    }
    if (staticAsd == null) return firestoreAsd;
    final staticAdaptiveList = staticAsd.sections.where((s) => s.isAsdAdaptivePlatformSection).toList();
    if (staticAdaptiveList.isEmpty) return firestoreAsd;
    final staticAdaptive = staticAdaptiveList.first;

    final staticPaths = staticAdaptive.imagePaths ?? const <String>[];

    final newSections = firestoreAsd.sections.map((s) {
      if (!s.isAsdAdaptivePlatformSection) return s;

      // Firestore often still has 7 old paths; static repo lists all current assets (e.g. 12).
      List<String> fromFirestore = const [];
      if (s.images != null && s.images!.isNotEmpty) {
        fromFirestore = s.images!.map((i) => migrateAsdAdaptiveAssetPath(i.path)).toList();
      } else if (s.imagePaths != null && s.imagePaths!.isNotEmpty) {
        fromFirestore = s.imagePaths!.map(migrateAsdAdaptiveAssetPath).toList();
      }

      final List<String> paths;
      if (fromFirestore.length >= staticPaths.length && fromFirestore.isNotEmpty) {
        // Admin extended list in Firestore — trust it.
        paths = fromFirestore;
      } else if (staticPaths.isNotEmpty) {
        // Repo has more (or fresher) assets than Firestore — show all bundled images.
        paths = staticPaths;
      } else {
        paths = fromFirestore;
      }

      return CaseStudySection(
        title: staticAdaptive.title,
        content: staticAdaptive.content,
        imagePaths: paths.isEmpty ? null : paths,
        images: null,
      );
    }).toList();

    final String? hero = firestoreAsd.heroImagePath?.trim();
    final String? heroResolved =
        (hero != null && hero.isNotEmpty) ? hero : staticAsd.heroImagePath?.trim();

    final rp = firestoreAsd.heroImagePaths;
    final hasRemotePaths = rp != null && rp.isNotEmpty;
    final staticHeroPaths = staticAsd.heroImagePaths;
    final heroPathsResolved = hasRemotePaths
        ? rp
        : (staticHeroPaths != null && staticHeroPaths.isNotEmpty
            ? List<String>.from(staticHeroPaths)
            : null);

    return PortfolioCaseStudy(
      id: firestoreAsd.id,
      title: firestoreAsd.title,
      subtitle: firestoreAsd.subtitle,
      overview: firestoreAsd.overview,
      designApproach: firestoreAsd.designApproach,
      heroImagePath: (heroResolved != null && heroResolved.isNotEmpty) ? heroResolved : null,
      heroImagePaths: heroPathsResolved,
      sections: newSections,
      order: firestoreAsd.order,
    );
  }

  static bool _heroPathsEqual(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// When Firestore omits [PortfolioCaseStudy.heroImagePath] or [PortfolioCaseStudy.heroImagePaths], use bundled static defaults.
  static PortfolioCaseStudy mergeHeroFromStaticIfMissing(PortfolioCaseStudy remote) {
    PortfolioCaseStudy? local;
    for (final c in caseStudies) {
      if (c.id == remote.id) {
        local = c;
        break;
      }
    }
    if (local == null) return remote;

    final remoteH = remote.heroImagePath?.trim();
    final hasRemoteHero = remoteH != null && remoteH.isNotEmpty;
    final remotePaths = remote.heroImagePaths;
    final hasRemotePaths = remotePaths != null && remotePaths.isNotEmpty;

    if (hasRemoteHero && hasRemotePaths) return remote;

    final fbH = local.heroImagePath?.trim();
    final fbP = local.heroImagePaths;

    final mergedHero =
        hasRemoteHero ? remoteH : (fbH != null && fbH.isNotEmpty ? fbH : null);
    final mergedPaths = hasRemotePaths
        ? remotePaths
        : (fbP != null && fbP.isNotEmpty ? List<String>.from(fbP) : null);

    if (mergedHero == remoteH && _heroPathsEqual(mergedPaths, remotePaths)) {
      return remote;
    }

    return PortfolioCaseStudy(
      id: remote.id,
      title: remote.title,
      subtitle: remote.subtitle,
      overview: remote.overview,
      designApproach: remote.designApproach,
      heroImagePath: mergedHero,
      heroImagePaths: mergedPaths,
      sections: remote.sections,
      order: remote.order,
    );
  }
}
