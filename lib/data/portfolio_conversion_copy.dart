/// Client-conversion copy for portfolio case studies and app cards (business context, role, outcome).
/// Keeps [PortfolioApp] / [PortfolioCaseStudy] models free of marketing-only fields.
library;

/// Extra lines for featured [PortfolioCaseStudy] rows on the portfolio page.
class CaseStudyConversionPitch {
  const CaseStudyConversionPitch({
    required this.businessContext,
    required this.myRole,
    required this.keyOutcome,
  });

  /// One line: who it serves / problem space (not art-direction fluff).
  final String businessContext;

  /// Scoped ownership—what you actually did.
  final String myRole;

  /// Proof of judgment: constraint, decision, or operational result (no fake KPIs).
  final String keyOutcome;
}

/// Map [PortfolioCaseStudy.id] → pitch. Ids without an entry use subtitle + overview only.
const Map<String, CaseStudyConversionPitch> kCaseStudyConversionPitchById = {
  'asd': CaseStudyConversionPitch(
    businessContext:
        'Stone fabrication and installation—coordination across sales, scheduling, field crews, and clients.',
    myRole: 'End-to-end product design and Flutter engineering; Firebase; governed AI.',
    keyOutcome:
        'One operational system replaced phone-tag and spreadsheets—roles, permissions, and auditability in one place.',
  ),
  'service-flow': CaseStudyConversionPitch(
    businessContext:
        'Multi-tenant field-service SaaS—tenant isolation, roles, and configurable workflows under one product.',
    myRole: 'Systems IA, UX, design system, and multi-tenant product structure with engineering.',
    keyOutcome:
        'Shared platform without forking per customer—design spec stays shippable alongside code.',
  ),
  'twin-scriptures': CaseStudyConversionPitch(
    businessContext:
        'Bilingual scripture readers for study and language reinforcement—cultural and UX sensitivity mattered.',
    myRole: 'Product and UX strategy, personalization model, Flutter across platforms.',
    keyOutcome:
        'Visual onboarding replaced long forms; RTL/i18n and thematic UX as product architecture.',
  ),
  'rose-chat-seasonal-campaign-engine': CaseStudyConversionPitch(
    businessContext:
        'AI-facing consumer product—seasonal campaigns and backend-driven conversation at scale.',
    myRole: 'Product UX for conversational flows, governance, and safe rollout patterns.',
    keyOutcome:
        'Shifted AI from one-off feature to configurable, previewable campaigns ops could run.',
  ),
};

/// Extra lines for [PortfolioApp] cards (showcase grid).
class AppShowcasePitch {
  const AppShowcasePitch({
    required this.businessContext,
    required this.myRole,
    required this.keyOutcome,
  });

  final String businessContext;
  final String myRole;
  final String keyOutcome;
}

/// Map [PortfolioApp.id] → pitch. Cards without a pitch keep the long [description] only.
const Map<String, AppShowcasePitch> kAppShowcasePitchById = {
  'asdusa': AppShowcasePitch(
    businessContext: 'Enterprise operations—multi-role dashboards and field reality, not a brochure app.',
    myRole: 'Product design, Flutter, Firebase, AI product governance.',
    keyOutcome: 'Shipped complexity: permissions, workflows, and adaptive UI across iOS, Android, web.',
  ),
  'service-flow': AppShowcasePitch(
    businessContext: 'B2B SaaS for field and office teams—clarity under operational pressure.',
    myRole: 'IA, UX/UI, living design system, tenancy-minded product structure.',
    keyOutcome: 'One codebase and one spec story—reduced UI drift between tenants and roles.',
  ),
  'twin-scriptures': AppShowcasePitch(
    businessContext: 'Consumer spiritual product—personalization without hostile forms.',
    myRole: 'UX, theming system, multi-language and RTL execution in Flutter.',
    keyOutcome: 'Higher completion through “show, don’t ask” onboarding and coherent preferences.',
  ),
  '4ideas-design-system': AppShowcasePitch(
    businessContext: 'Reusable UI foundations for real shipping—not only Figma plates.',
    myRole: 'Component library thinking, tokens, and Flutter-native patterns.',
    keyOutcome: 'Faster, more consistent builds across products that share the same craft bar.',
  ),
  'my-web-site': AppShowcasePitch(
    businessContext: 'This site—lead capture, portfolio depth, and professional first impression.',
    myRole: 'Flutter Web, information architecture, and conversion-focused UX.',
    keyOutcome: 'One stack for marketing + inquiry flow without a separate CMS sprawl.',
  ),
  'great-t2s': AppShowcasePitch(
    businessContext: 'Accessibility and learning—people who need text read aloud or language help.',
    myRole: 'Product UX for low cognitive load and trustworthy, calm UI.',
    keyOutcome: 'Simple path from input to speech with minimal configuration anxiety.',
  ),
};

CaseStudyConversionPitch? caseStudyPitchForId(String id) =>
    kCaseStudyConversionPitchById[id];

AppShowcasePitch? appShowcasePitchForId(String id) =>
    kAppShowcasePitchById[id];
