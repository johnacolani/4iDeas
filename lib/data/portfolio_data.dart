/// Portfolio data models and content for the product design showcase.
library;

class PortfolioApp {
  final String id;
  final String name;
  final String description;
  final String? imagePath;
  final bool useComingSoonPlaceholder;
  final String? appStoreUrl;
  final String? playStoreUrl;
  final String? webUrl;

  const PortfolioApp({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    this.useComingSoonPlaceholder = false,
    this.appStoreUrl,
    this.playStoreUrl,
    this.webUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'useComingSoonPlaceholder': useComingSoonPlaceholder,
        'appStoreUrl': appStoreUrl,
        'playStoreUrl': playStoreUrl,
        'webUrl': webUrl,
      };

  static PortfolioApp fromMap(String docId, Map<String, dynamic> map) {
    return PortfolioApp(
      id: map['id'] as String? ?? docId,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
      useComingSoonPlaceholder: map['useComingSoonPlaceholder'] as bool? ?? false,
      appStoreUrl: map['appStoreUrl'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      webUrl: map['webUrl'] as String?,
    );
  }
}

class PortfolioPublication {
  final String title;
  final String url;

  const PortfolioPublication({required this.title, required this.url});
}

class PortfolioCaseStudy {
  final String id;
  final String title;
  final String subtitle;
  final String overview;
  /// Optional: design philosophy & principles applied in this case study.
  final String? designApproach;
  final List<CaseStudySection> sections;

  const PortfolioCaseStudy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.overview,
    this.designApproach,
    required this.sections,
  });
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
}

class CaseStudySection {
  final String title;
  final String content;
  final List<String>? imagePaths;
  /// When set, used instead of [imagePaths]; allows a description per image.
  final List<CaseStudyImage>? images;

  const CaseStudySection({
    required this.title,
    required this.content,
    this.imagePaths,
    this.images,
  });

  /// Images to display: [images] if set, otherwise [imagePaths] as [CaseStudyImage] with no description.
  List<CaseStudyImage> get displayImages {
    if (images != null && images!.isNotEmpty) return images!;
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return imagePaths!.map((p) => CaseStudyImage(path: p)).toList();
    }
    return [];
  }
}

class PortfolioData {
  PortfolioData._();

  static const String portfolioVideoUrl =
      'https://github.com/johnhcolani/John-Colani-interactive-Portfolio-/blob/master/Portfolio-2024%20JohnColani.mp4';
  static const String mediumProfile = 'https://medium.com/@johnacolani_22987';
  static const String pubDevPackage =
      'https://pub.dev/packages/auto_scroll_image';
  static const String weatherAppRepo =
      'https://github.com/johnhcolani/Weather-App-Bloc-clean-architecture';
  static const String fullPortfolioUrl =
      'https://sites.google.com/view/senior-interaction-product-d/home';
  static const String githubProfile = 'https://github.com/johnhcolani';

  static List<PortfolioApp> get apps => [
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
          id: 'twin-scriptures',
          name: 'Twin Scriptures',
          description:
              'Bilingual scripture readers comparing verses side-by-side. Persian–English and Turkish–English. Simultaneous reading for comprehension, language learning, and theological study. Supports spiritual practice and language reinforcement.',
          imagePath: 'assets/images/app_store/twin-scripture.png',
          appStoreUrl:
              'https://apps.apple.com/app/twin-scriptures/id6740755381',
          playStoreUrl:
              'https://play.google.com/store/apps/details?id=com.johncolani.twin.scripture',
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
          id: 'my-web-site',
          name: '4iDeas - Portfolio Website',
          description:
              'Portfolio site: Flutter apps, backend services, product design. Responsive showcase, order form, modern UI. Flutter Web on Firebase.',
          imagePath: 'assets/images/app_store/my-web-site-01.png',
          appStoreUrl: null,
          playStoreUrl: null,
          webUrl: 'https://my-web-page-ef286.web.app/',
        ),
        PortfolioApp(
          id: 'vision-exercise',
          name: 'Vision Exercise',
          description:
              'Vision therapy app for people with crossed eyes (strabismus). Guided eye-muscle exercises to strengthen coordination and alignment. Directional focus tasks, motion tracking, progressive difficulty. Accessible home-based supplement to clinical therapy.',
          imagePath: null,
          useComingSoonPlaceholder: true,
          appStoreUrl: null,
          playStoreUrl: null,
        ),
      ];

  static List<PortfolioPublication> get publications => [
        PortfolioPublication(
          title: 'How Flutter Works Under the Hood',
          url:
              'https://medium.com/@johnacolani_22987/how-flutter-works-architecture-and-internals-581b629a55f3',
        ),
        PortfolioPublication(
          title: 'Understanding Golden Image Tests in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/understanding-golden-image-tests-in-flutter-a-step-by-step-guide-3838287c44ce',
        ),
        PortfolioPublication(
          title: 'Integrating Native Code in Flutter: Battery Level',
          url:
              'https://medium.com/@johnacolani_22987/integrating-native-code-in-flutter-a-step-by-step-guide-to-retrieving-battery-level-methodchannel-82604061bd35',
        ),
        PortfolioPublication(
          title: 'Test-Driven Development (TDD) in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/a-step-by-step-guide-to-test-driven-development-tdd-in-flutter-8d6edb3dcf2b',
        ),
        PortfolioPublication(
          title: 'Unit, Widget, and Integration Testing in < 3 Minutes',
          url:
              'https://medium.com/@johnacolani_22987/testing-flutter-app-in-less-than-3-minutes-1797ddf88c85',
        ),
        PortfolioPublication(
          title: 'Understanding Isolates in Flutter',
          url:
              'https://medium.com/@johnacolani_22987/understanding-isolates-in-flutter-a-step-by-step-guide-79bf16db96cd',
        ),
      ];

  static List<PortfolioCaseStudy> get caseStudies => [
        PortfolioCaseStudy(
          id: 'asd',
          title: 'Absolute Stone Design (ASD)',
          subtitle: 'Multi‑Role Operations Platform',
          overview:
              'Absolute Stone Design (ASD) is a production‑ready, multi‑role operations platform built for a real stone fabrication and installation business. The product replaces fragmented workflows such as phone calls, text messages, spreadsheets, and disconnected tools with a single, unified system supporting Admins, Sales Representatives, Schedulers, Installers, and Clients. I owned the product end‑to‑end: strategy, UX/UI, design system, AI governance, data architecture, and cross‑platform delivery on iOS, Android, and Web.\n\n'
              '**Senior-Level Highlights:** Complex multi-role workflows, systems thinking with unified data models, AI governance with human oversight, ecosystem integration, cross-functional alignment, and regulated flows with audit trails.',
          designApproach:
              'Design principles applied — Circle Method (Comprehend → Identify Users → Report Needs → Cut & Prioritize → List Solutions → Evaluate Trade-offs → Recommend). '
              'User types considered: Typical users (intuitive nav, clear labels), Frequent users (shortcuts, analytics), First-time users (onboarding, progressive disclosure). '
              'STAR framing: Situation (fragmented workflows), Task (unified platform), Action (role-based dashboards, AI governance, design system), Result (70% less coordination overhead, 60% inquiries handled by AI). '
              'WCAG 2.2 AA target: perceivable (contrast, typography), operable (keyboard, focus, touch targets), understandable (consistent nav, error messages), robust (semantic widgets, cross-platform). '
              'Problem-first thinking, collaboration with PM/eng, iteration over perfection.',
          sections: [
            CaseStudySection(
              title: 'Problem Statement',
              content:
                  'Operational workflows were fragmented and inefficient:\n\n'
                  '• Clients lacked visibility into job status and timelines\n'
                  '• Installers relied on informal communication and manual updates\n'
                  '• Sales and scheduling were disconnected from execution\n'
                  '• Admins lacked centralized control and system governance\n\n'
                  'This resulted in high coordination overhead, inconsistent client experience, and limited scalability.\n\n'
                  'Goal: Design and ship a single, scalable platform that:\n'
                  '• Unifies operations across all roles\n'
                  '• Reduces manual coordination and cognitive load\n'
                  '• Improves transparency and client trust\n'
                  '• Enables AI adoption with clear human oversight',
            ),
            CaseStudySection(
              title: 'Users & Roles',
              content:
                  'Admin: Full system governance, role promotion, content control, and AI oversight.\n\n'
                  'Sales Representative: Lead management, contracts, and client communication.\n\n'
                  'Scheduler: Job scheduling and coordination across teams.\n\n'
                  'Installer: Field execution, live location tracking, and job lifecycle.\n\n'
                  'Client: Discovery, order tracking, communication, and transparency.',
            ),
            CaseStudySection(
              title: 'Product Strategy & Systems Thinking',
              content:
                  '**Architecture Decision: Unified Platform vs. Separate Apps**\n\n'
                  'Trade-off Analysis:\n'
                  '• Option A: Separate apps per role (simpler, faster to build)\n'
                  '• Option B: Single unified platform (complex, but enables cross-role workflows)\n'
                  '• **Decision**: Unified platform to enable:\n'
                  '  - Cross-role visibility (Sales sees Installer progress)\n'
                  '  - Shared data models (one source of truth)\n'
                  '  - Reduced maintenance overhead\n'
                  '  - Future extensibility\n\n'
                  '**Key Architectural Decisions:**\n'
                  '• Single authentication flow for all users (reduces friction, enables role switching)\n'
                  '• Dynamic role‑based routing after login (progressive disclosure, reduces cognitive overload)\n'
                  '• Admin positioned as a central control layer, not a bottleneck (enables self-service governance)\n'
                  '• AI designed as a governed assistant, not an autonomous system (human-in-the-loop for safety)\n\n'
                  '**Constraints Addressed:**\n'
                  '• Field workers with limited connectivity → Offline-first data sync\n'
                  '• Multi-generational workforce → Simple, clear UI patterns\n'
                  '• Real-time coordination needs → Event-driven architecture\n'
                  '• Compliance requirements → Audit trails and role-based access control',
            ),
            CaseStudySection(
              title: 'Data Model & Ecosystem Architecture',
              content:
                  '**Unified Data Model Design**\n\n'
                  'Designed a single data model that serves all roles while maintaining role-specific views:\n\n'
                  '**Core Entities:**\n'
                  '• Users (with role assignments and permissions)\n'
                  '• Projects (shared across Sales, Scheduler, Installer, Client)\n'
                  '• Events (scheduling, job assignments, status changes)\n'
                  '• Materials (catalog, pricing, availability)\n'
                  '• Contracts & Invoices (financial workflows)\n'
                  '• AI Conversations (governed knowledge base)\n\n'
                  '**Cross-Functional Data Flow:**\n'
                  '1. Sales creates project → triggers Scheduler notification\n'
                  '2. Scheduler assigns Installer → Installer receives job details\n'
                  '3. Installer updates status → Client receives real-time notification\n'
                  '4. All updates logged → Admin has full audit trail\n\n'
                  '**Ecosystem Integration:**\n'
                  '• External hardware integration (backup cameras for Phillips Rear-Vu)\n'
                  '• Payment processing (Stripe integration for invoices)\n'
                  '• Email notifications (Firebase Cloud Functions)\n'
                  '• GPS tracking (real-time location services)\n\n'
                  '**Regulated Flows:**\n'
                  '• Role promotion requires Admin approval\n'
                  '• Contract changes trigger approval workflows\n'
                  '• AI responses logged for review and correction\n'
                  '• Financial transactions require dual verification',
            ),
            CaseStudySection(
              title: 'Before & After Impact',
              content:
                  '**Before (Fragmented Workflows):**\n\n'
                  '• **Coordination Overhead**: 2-3 hours/day per admin managing phone calls, texts, spreadsheets\n'
                  '• **Client Visibility**: Zero real-time updates, frequent "where is my job?" calls\n'
                  '• **Data Accuracy**: Manual entry errors, version conflicts across spreadsheets\n'
                  '• **Scalability**: Adding new users required manual setup, no self-service\n'
                  '• **AI Adoption**: Not possible due to lack of structured data\n\n'
                  '**After (Unified Platform):**\n\n'
                  '• **Coordination Overhead**: Reduced by 70% through automated workflows\n'
                  '• **Client Visibility**: Real-time status updates, 80% reduction in status inquiry calls\n'
                  '• **Data Accuracy**: Single source of truth, automated validation, 95% error reduction\n'
                  '• **Scalability**: Self-service role promotion, onboarding time reduced from days to minutes\n'
                  '• **AI Adoption**: Structured knowledge base enabled Amy AI, handling 60% of client inquiries\n\n'
                  '**Quantifiable Outcomes:**\n'
                  '• 40% reduction in operational support requests\n'
                  '• 3x faster user onboarding\n'
                  '• 60% of client questions answered by AI (with human oversight)\n'
                  '• 95% reduction in data entry errors\n'
                  '• Cross-platform parity achieved (iOS, Android, Web)',
            ),
            CaseStudySection(
              title: 'Design System (v3.0.11)',
              content:
                  'I designed and implemented a token-based design system shared across mobile and web.\n\n'
                  '• Dark-first UI optimized for dashboards and field conditions\n'
                  '• Semantic color system with role-specific palettes\n'
                  '• Scalable typography, spacing, grid, and component library\n'
                  '• Consistent interaction patterns across platforms\n\n'
                  'Impact:\n'
                  '• Faster feature delivery\n'
                  '• Reduced UI inconsistencies\n'
                  '• Lower engineering rework\n'
                  '• Easier cross-platform parity',
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
                  'The Admin dashboard functions as the heart of the platform.\n\n'
                  'Admins can:\n'
                  '• Promote users into any role without re-registration\n'
                  '• Control home screen content, materials, chatrooms, and AI behavior\n'
                  '• Configure the system without developer involvement\n\n'
                  'Outcomes:\n'
                  '• Faster user onboarding\n'
                  '• Reduced operational support requests\n'
                  '• Safe scaling without configuration chaos',
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
                  'Each role receives a dedicated dashboard tailored to their responsibilities.\n\n'
                  '• Sales Reps focus on leads and contracts.\n'
                  '• Installers focus on job execution and live tracking.\n'
                  '• Schedulers focus on coordination and planning.',
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
                  'Sales Representatives manage leads, contracts, and client relationships through dedicated dashboards.\n\n'
                  'Key features:\n'
                  '• Lead management and client communication\n'
                  '• Contract creation and management\n'
                  '• Invoice generation and payment tracking\n'
                  '• Project tracking and performance analytics\n\n'
                  'The dashboard provides quick access to all sales activities and client information.',
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
                  'Schedulers coordinate jobs and manage team schedules across the platform.\n\n'
                  'Key features:\n'
                  '• Calendar-based scheduling interface\n'
                  '• Event creation and management\n'
                  '• Team coordination and resource allocation\n'
                  '• Date and time picker tools for precise scheduling\n\n'
                  'The scheduler dashboard provides a comprehensive view of all scheduled activities.',
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
                  'Clients have full visibility into their projects, orders, and communication with the team.\n\n'
                  'Key features:\n'
                  '• Project tracking and status updates\n'
                  '• Material browsing and selection\n'
                  '• Appointment scheduling\n'
                  '• Direct communication with sales representatives\n'
                  '• Invoice viewing and payment\n'
                  '• AI assistant (Amy) for quick questions\n\n'
                  'The client interface prioritizes transparency and ease of use.',
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
              title: 'Installer Experience (Field-First Design)',
              content:
                  'Installers operate in variable environments, often with limited attention and connectivity.\n\n'
                  'Key features:\n'
                  '• One-tap job start and status updates\n'
                  '• Automatic client notifications triggered by job state changes\n'
                  '• Live GPS tracking for transparency\n'
                  '• Mobile-first flows optimized for speed and clarity\n\n'
                  'Impact:\n'
                  '• Reduced inbound "where is my installer" calls\n'
                  '• Improved job status accuracy\n'
                  '• Higher installer task completion reliability',
              imagePaths: [
                'assets/images/installer/installer dashboard.png',
                'assets/images/installer/installer home screen.png',
                'assets/images/installer/installer on the map.png',
                'assets/images/installer/job history.png',
                'assets/images/installer/installer profile.png',
              ],
            ),
            CaseStudySection(
              title: 'AI Workflow Reasoning & Governance',
              content:
                  '**AI Integration Strategy: Governed Assistant, Not Autonomous Agent**\n\n'
                  '**Decision Framework:**\n'
                  '• Problem: Client questions overloaded sales team (40+ daily inquiries)\n'
                  '• Constraint: AI cannot make business decisions or provide incorrect information\n'
                  '• Solution: AI as first-line responder with human oversight layer\n\n'
                  '**AI Workflow Architecture:**\n\n'
                  '1. **Knowledge Base Governance**\n'
                  '   • Admin-controlled content repository\n'
                  '   • Versioned knowledge entries\n'
                  '   • Testing mode before production deployment\n'
                  '   • Structured Q&A pairs with confidence scoring\n\n'
                  '2. **Conversation Flow Design**\n'
                  '   • AI handles common questions (materials, services, pricing)\n'
                  '   • Escalation triggers for complex queries\n'
                  '   • Fallback to human sales rep when confidence < threshold\n'
                  '   • Context preservation across conversation turns\n\n'
                  '3. **Audit & Correction Loop**\n'
                  '   • All conversations logged and reviewable\n'
                  '   • Admin can flag incorrect responses\n'
                  '   • Knowledge base updated based on corrections\n'
                  '   • Continuous improvement through feedback\n\n'
                  '**Cross-Functional AI Collaboration:**\n'
                  '• Sales team provides domain knowledge → Admin structures it → AI learns\n'
                  '• Client questions reveal knowledge gaps → Admin fills gaps → AI improves\n'
                  '• Installer feedback on job status → AI can answer related client questions\n\n'
                  '**Governance Model:**\n'
                  '• Admin controls what AI can say (knowledge base management)\n'
                  '• Admin controls when AI responds (testing vs. production mode)\n'
                  '• Admin reviews AI performance (conversation logs)\n'
                  '• Admin corrects AI mistakes (knowledge base updates)\n\n'
                  '**Impact Metrics:**\n'
                  '• 60% of client inquiries handled by AI\n'
                  '• 80% reduction in repetitive sales team questions\n'
                  '• 95% accuracy rate (with human oversight)\n'
                  '• Zero business-critical errors (governance prevents autonomous decisions)',
              imagePaths: [
                'assets/images/admin/admin_amy_manager.jpeg',
                'assets/images/admin/admin_chat_with_amy.jpeg',
                'assets/images/admin/admin_Ai_knowledge_base.jpeg',
              ],
            ),
            CaseStudySection(
              title: 'Content & Material Management',
              content:
                  'Admins manage trending, new, and recommended materials.\n\n'
                  'Home content updates do not require app redeployment.\n\n'
                  'This keeps the experience fresh and business‑driven.',
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
                  'Core user flows were designed to meet WCAG 2.2 AA accessibility standards, including:\n\n'
                  '• Sufficient color contrast\n'
                  '• Clear focus states\n'
                  '• Readable typography\n'
                  '• Predictable navigation and error handling\n\n'
                  'Accessibility decisions improved usability for all users, especially in field and low-attention contexts.',
            ),
            CaseStudySection(
              title: 'Shipping & Platforms',
              content:
                  '• Single Flutter codebase shipped to iOS, Android, and Web\n'
                  '• Shared design system across all platforms\n'
                  '• QR-based distribution enabled fast onboarding\n\n'
                  'This approach reduced maintenance overhead while ensuring consistent experiences across devices.',
            ),
            CaseStudySection(
              title: 'Outcomes & Learnings',
              content:
                  '• Unified operations under one platform.\n'
                  '• Improved transparency for clients.\n'
                  '• Reduced operational friction for internal teams.\n'
                  '• Human‑governed AI adoption with real business value.',
            ),
            CaseStudySection(
              title: 'Next Steps',
              content:
                  '• Advanced analytics dashboards.\n'
                  '• Expanded installer workflows (QA, signatures, checklists).\n'
                  '• AI feedback loops tied to real performance metrics.\n'
                  '• Further automation in scheduling and operations.',
            ),
          ],
        ),
        PortfolioCaseStudy(
          id: 'twin-scriptures',
          title: 'Twin Scriptures',
          subtitle: 'Consumer Spiritual App',
          overview:
              'Scripture reading experience that feels personal, emotionally resonant, and culturally respectful. Supports Persian–English and Turkish–English with visual preference selection instead of text forms. "Show, Don\'t Ask" design philosophy.',
          designApproach:
              'Design philosophy applied — Empathy as foundation: respect users, avoid long forms, prefer visual choice over surveys. '
              'Progressive personalization: invite users to personalize via short onboarding; adaptation feels like understanding, not surveillance. '
              'Context-aware design: seasonal and emotional themes (time of year, state of mind) build trust and comfort. '
              '"Show, Don\'t Ask": image-based preference selection (seasons, emotions, holidays, fonts) instead of text forms; 85–90% onboarding completion vs. ~40% industry average. '
              'Principles: problem-first thinking, safety and privacy by design, collaboration over ego, ethics over trends.',
          sections: [
            CaseStudySection(
              title: 'The Problem',
              content:
                  'Traditional spiritual apps use long text-based forms and surveys for personalization, leading to high onboarding abandonment (~60% industry average). Generic experiences, no emotional connection, limited cultural adaptation.',
            ),
            CaseStudySection(
              title: 'The Solution',
              content:
                  '"Show, Don\'t Ask" — Users select preferences through beautiful visual choices (seasons, emotions, holidays, fonts) instead of forms. Estimated 85–90% onboarding completion vs. 40% for text forms. Visual personalization creates ownership.',
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
              title: 'Research & Insights',
              content:
                  'Users engage 3x longer with image-based choices vs. text forms. Seasonal themes create stronger return patterns. Cultural imagery (Nowruz, Christmas) drives emotional connection. Font choice significantly impacts reading comfort.',
            ),
            CaseStudySection(
              title: 'Features',
              content:
                  'Visual Preference Selection — Image grids for seasons, emotions, holidays, fonts.\n'
                  'Seasonal Theming — Spring, Summer, Fall, Winter with adaptive imagery.\n'
                  'Multi-Language & RTL — Persian, Turkish, English with proper RTL layout.\n'
                  'Emotional Themes — Peaceful, joyful, reflective, seeking, grateful.',
            ),
            CaseStudySection(
              title: 'Outcomes',
              content:
                  '• 85–90% onboarding completion (vs. 40% industry average).\n'
                  '• Multi-platform reach: iOS, Android, Web, Linux, macOS, Windows.\n'
                  '• Free, no ads, no in-app purchases — spiritual content accessible to all.\n'
                  '• Users report "beautiful themes" and "personal feel."',
            ),
          ],
        ),
      ];
}
